import 'package:artio_admin/core/utils/retry.dart';
import 'package:artio_admin/features/revenue/domain/entities/revenue_stats.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'revenue_stats_provider.g.dart';

@riverpod
Future<RevenueStats> revenueStats(Ref ref) async {
  final client = Supabase.instance.client;
  final now = DateTime.now().toUtc();
  final sevenDaysAgo = now.subtract(const Duration(days: 7));

  // 3 independent queries — run in parallel
  final results = await Future.wait([
    // Query 1: Recent transactions feed (LIMIT 50 for display)
    retry(
      () => client
          .from('credit_transactions')
          .select('*, profiles(email)')
          .inFilter('type', ['subscription', 'purchase'])
          .order('created_at', ascending: false)
          .limit(50),
    ),

    // Query 2: 7-day window for daily aggregation (bounded by date, no LIMIT)
    retry(
      () => client
          .from('credit_transactions')
          .select('created_at, amount, type')
          .inFilter('type', ['subscription', 'purchase'])
          .gte('created_at', sevenDaysAgo.toIso8601String()),
    ),

    // Query 3: All profiles for tier breakdown
    retry(
      () => client.from('profiles').select('subscription_tier'),
    ),
  ]);

  final transactionsRaw = results[0] as List;
  final weeklyRaw = results[1] as List;
  final profilesRaw = results[2] as List;

  // ── Recent Transactions ────────────────────────────────────────────────
  final recentTransactions = transactionsRaw.map((row) {
    final profileData = row['profiles'] as Map<String, dynamic>?;
    final createdAtStr = row['created_at'] as String;
    return RevenueTransaction(
      userId: row['user_id'] as String,
      userEmail: profileData?['email'] as String?,
      amount: (row['amount'] as num).toInt(),
      type: row['type'] as String,
      referenceId: row['reference_id'] as String?,
      createdAt: DateTime.parse(createdAtStr).toUtc(),
    );
  }).toList();

  // ── Daily Revenue — client-side aggregation ────────────────────────────
  final dailyMap = <String, ({int count, int credits})>{};
  for (final row in weeklyRaw) {
    final dt = DateTime.parse(row['created_at'] as String).toUtc();
    final key =
        '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    final current = dailyMap[key] ?? (count: 0, credits: 0);
    dailyMap[key] = (
      count: current.count + 1,
      credits: current.credits + ((row['amount'] as num).toInt()),
    );
  }

  // Zero-fill all 7 days, oldest → newest, UTC
  final dailyRevenue = <DailyRevenue>[];
  for (var i = 6; i >= 0; i--) {
    final date = now.subtract(Duration(days: i));
    final normalized = DateTime.utc(date.year, date.month, date.day);
    final key =
        '${normalized.year}-${normalized.month.toString().padLeft(2, '0')}-${normalized.day.toString().padLeft(2, '0')}';
    final entry = dailyMap[key];
    dailyRevenue.add(DailyRevenue(
      date: normalized,
      transactionCount: entry?.count ?? 0,
      creditAmount: entry?.credits ?? 0,
    ));
  }

  // ── Tier Breakdown ─────────────────────────────────────────────────────
  final tierMap = <String, int>{};
  for (final row in profilesRaw) {
    // null subscription_tier → 'free'
    final tier = (row['subscription_tier'] as String?) ?? 'free';
    tierMap[tier] = (tierMap[tier] ?? 0) + 1;
  }
  final totalUsers = profilesRaw.length;
  final tierBreakdown = tierMap.entries
      .map((e) => TierBreakdown(
            tier: e.key,
            count: e.value,
            totalUsers: totalUsers,
          ))
      .toList()
    ..sort((a, b) => b.count.compareTo(a.count));

  return RevenueStats(
    recentTransactions: recentTransactions,
    dailyRevenue: dailyRevenue,
    tierBreakdown: tierBreakdown,
  );
}
