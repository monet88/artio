import 'package:artio_admin/features/revenue/domain/entities/revenue_stats.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for revenue provider client-side aggregation logic.
///
/// The provider accesses Supabase.instance.client (static singleton) directly.
/// We test the pure computation logic here using the same algorithms extracted
/// from revenue_stats_provider.dart.
void main() {
  group('null subscription_tier → free', () {
    test('null tier is mapped to "free" in tier breakdown', () {
      final profilesRaw = <Map<String, dynamic>>[
        {'subscription_tier': null}, // null → free
        {'subscription_tier': null},
        {'subscription_tier': 'premium'},
      ];

      final tierMap = <String, int>{};
      for (final row in profilesRaw) {
        final tier = (row['subscription_tier'] as String?) ?? 'free';
        tierMap[tier] = (tierMap[tier] ?? 0) + 1;
      }

      expect(tierMap['free'], equals(2));
      expect(tierMap['premium'], equals(1));
      expect(tierMap.containsKey(null), isFalse);
    });

    test('all null tiers produce only "free" entries', () {
      final profilesRaw = <Map<String, dynamic>>[
        {'subscription_tier': null},
        {'subscription_tier': null},
      ];

      final tierMap = <String, int>{};
      for (final row in profilesRaw) {
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
          .toList();

      expect(tierBreakdown, hasLength(1));
      expect(tierBreakdown.first.tier, equals('free'));
      expect(tierBreakdown.first.count, equals(2));
    });
  });

  group('null userEmail (profile deleted)', () {
    test('null profiles map → userEmail is null, no crash', () {
      final row = <String, dynamic>{
        'user_id': 'deleted-user-id',
        'profiles': null, // profile deleted
        'amount': 100,
        'type': 'purchase',
        'reference_id': null,
        'created_at': '2026-03-31T10:00:00.000Z',
      };

      final profileData = row['profiles'] as Map<String, dynamic>?;
      final tx = RevenueTransaction(
        userId: row['user_id'] as String,
        userEmail: profileData?['email'] as String?,
        amount: (row['amount'] as num).toInt(),
        type: row['type'] as String,
        referenceId: row['reference_id'] as String?,
        createdAt: DateTime.parse(row['created_at'] as String).toUtc(),
      );

      expect(tx.userEmail, isNull);
      expect(tx.userId, equals('deleted-user-id'));
      expect(tx.amount, equals(100));
    });
  });

  group('7-day UTC boundary', () {
    test('transaction at now-6d is included, now-8d is excluded', () {
      final now = DateTime.now().toUtc();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));

      // 6 days ago: inside 7-day window (>= sevenDaysAgo)
      final sixDaysAgo = now.subtract(const Duration(days: 6));
      expect(
        sixDaysAgo.isAfter(sevenDaysAgo) ||
            sixDaysAgo.isAtSameMomentAs(sevenDaysAgo),
        isTrue,
        reason: '6 days ago should be within the 7-day window',
      );

      // 8 days ago: outside window
      final eightDaysAgo = now.subtract(const Duration(days: 8));
      expect(
        eightDaysAgo.isBefore(sevenDaysAgo),
        isTrue,
        reason: '8 days ago should be outside the 7-day window',
      );
    });

    test('sevenDaysAgo is UTC', () {
      final now = DateTime.now().toUtc();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      expect(sevenDaysAgo.isUtc, isTrue);
    });
  });

  group('empty transactions', () {
    test('subscriptionsToday = 0 with empty list', () {
      final stats = RevenueStats(
        recentTransactions: const [],
        dailyRevenue: const [],
        tierBreakdown: const [],
      );

      expect(stats.subscriptionsToday, equals(0));
    });

    test('subscriptionsThisWeek = 0 with empty list', () {
      final stats = RevenueStats(
        recentTransactions: const [],
        dailyRevenue: const [],
        tierBreakdown: const [],
      );

      expect(stats.subscriptionsThisWeek, equals(0));
    });

    test('totalPremiumUsers = 0 with empty tierBreakdown', () {
      final stats = RevenueStats(
        recentTransactions: const [],
        dailyRevenue: const [],
        tierBreakdown: const [],
      );

      expect(stats.totalPremiumUsers, equals(0));
    });
  });

  group('daily revenue zero-fill', () {
    test('produces exactly 7 entries', () {
      final now = DateTime.now().toUtc();
      final dailyMap = <String, ({int count, int credits})>{};

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

      expect(dailyRevenue, hasLength(7));
      expect(dailyRevenue.every((d) => d.transactionCount == 0), isTrue);
      expect(dailyRevenue.every((d) => d.creditAmount == 0), isTrue);
    });

    test('entry with data shows correct count and credits', () {
      final now = DateTime.now().toUtc();
      final today = DateTime.utc(now.year, now.month, now.day);
      final todayKey =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final dailyMap = <String, ({int count, int credits})>{
        todayKey: (count: 3, credits: 300),
      };

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

      expect(dailyRevenue.last.transactionCount, equals(3));
      expect(dailyRevenue.last.creditAmount, equals(300));
      expect(
        dailyRevenue.sublist(0, 6).every((d) => d.transactionCount == 0),
        isTrue,
      );
    });
  });

  group('tier breakdown sort', () {
    test('sorted descending by count', () {
      final profilesRaw = <Map<String, dynamic>>[
        {'subscription_tier': 'free'},
        {'subscription_tier': 'free'},
        {'subscription_tier': 'free'},
        {'subscription_tier': 'premium'},
        {'subscription_tier': 'premium'},
        {'subscription_tier': 'basic'},
      ];

      final tierMap = <String, int>{};
      for (final row in profilesRaw) {
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

      expect(tierBreakdown.first.tier, equals('free'));
      expect(tierBreakdown.first.count, equals(3));
      expect(tierBreakdown[1].tier, equals('premium'));
      expect(tierBreakdown[1].count, equals(2));
    });
  });
}
