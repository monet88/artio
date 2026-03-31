import 'package:artio_admin/core/utils/retry.dart';
import 'package:artio_admin/features/analytics/domain/entities/analytics_stats.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'analytics_stats_provider.g.dart';

/// Fetches and aggregates analytics data from Supabase.
///
/// Data sources:
/// - `profiles`: user counts (total, premium)
/// - `generation_jobs`: job counts + 7-day breakdown + top models
@riverpod
Future<AnalyticsStats> analyticsStats(Ref ref) async {
  final client = Supabase.instance.client;

  // 1. All profiles — small dataset, used for user KPIs
  final profilesRaw = await retry(
    () => client.from('profiles').select('id, is_premium'),
  ) as List;
  final totalUsers = profilesRaw.length;
  final premiumUsers =
      profilesRaw.where((p) => p['is_premium'] == true).length;

  // 2. Total job count — select id only
  final jobIdsRaw = await retry(
    () => client.from('generation_jobs').select('id'),
  ) as List;
  final totalJobs = jobIdsRaw.length;

  // 3. Jobs from last 7 days — for charts, today count, top models
  // Use UTC to match Supabase storage format (avoids timezone boundary errors)
  final now = DateTime.now().toUtc();
  final sevenDaysAgo = now.subtract(const Duration(days: 7));
  final recentJobsRaw = await retry(
    () => client
        .from('generation_jobs')
        .select('model_id, created_at')
        .gte('created_at', sevenDaysAgo.toIso8601String()),
  ) as List;

  // Today count — UTC boundary
  final todayStart = DateTime.utc(now.year, now.month, now.day);
  final jobsToday = recentJobsRaw.where((j) {
    final createdAt = DateTime.parse(j['created_at'] as String).toUtc();
    return !createdAt.isBefore(todayStart);
  }).length;

  // Daily breakdown — build 7-bucket map using UTC dates
  final dailyMap = <String, int>{};
  for (final job in recentJobsRaw) {
    final dt = DateTime.parse(job['created_at'] as String).toUtc();
    final key =
        '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    dailyMap[key] = (dailyMap[key] ?? 0) + 1;
  }

  // Fill all 7 days (including zero-count days), oldest → newest, UTC dates
  final dailyJobs = <DailyCount>[];
  for (var i = 6; i >= 0; i--) {
    final date = now.subtract(Duration(days: i));
    final normalized = DateTime.utc(date.year, date.month, date.day);
    final key =
        '${normalized.year}-${normalized.month.toString().padLeft(2, '0')}-${normalized.day.toString().padLeft(2, '0')}';
    dailyJobs.add(DailyCount(date: normalized, count: dailyMap[key] ?? 0));
  }

  // Top models — group by model_id, sort descending, take top 5
  final modelMap = <String, int>{};
  for (final job in recentJobsRaw) {
    final model = (job['model_id'] as String?) ?? 'unknown';
    modelMap[model] = (modelMap[model] ?? 0) + 1;
  }
  final topModels = modelMap.entries
      .map((e) => ModelCount(model: e.key, count: e.value))
      .toList()
    ..sort((a, b) => b.count.compareTo(a.count));

  return AnalyticsStats(
    totalUsers: totalUsers,
    totalJobs: totalJobs,
    premiumUsers: premiumUsers,
    jobsToday: jobsToday,
    dailyJobs: dailyJobs,
    topModels: topModels.take(5).toList(),
  );
}
