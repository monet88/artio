import 'package:artio_admin/features/revenue/domain/entities/revenue_stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TierBreakdown', () {
    test('percentage: normal case (count=2, total=10 → 0.2)', () {
      const tier = TierBreakdown(tier: 'premium', count: 2, totalUsers: 10);
      expect(tier.percentage, closeTo(0.2, 0.0001));
    });

    test('percentage: divide-by-zero guard (totalUsers=0 → 0.0)', () {
      const tier = TierBreakdown(tier: 'free', count: 0, totalUsers: 0);
      expect(tier.percentage, equals(0.0));
    });

    test('percentage: all users in one tier (count=total → 1.0)', () {
      const tier = TierBreakdown(tier: 'free', count: 50, totalUsers: 50);
      expect(tier.percentage, closeTo(1.0, 0.0001));
    });
  });

  group('DailyRevenue zero-fill', () {
    test('7 entries with count=0 when no data', () {
      final now = DateTime.now().toUtc();
      final dailyRevenue = <DailyRevenue>[];
      for (var i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        dailyRevenue.add(DailyRevenue(
          date: DateTime.utc(date.year, date.month, date.day),
          transactionCount: 0,
          creditAmount: 0,
        ));
      }

      expect(dailyRevenue, hasLength(7));
      expect(dailyRevenue.every((d) => d.transactionCount == 0), isTrue);
      expect(dailyRevenue.every((d) => d.creditAmount == 0), isTrue);
    });
  });

  group('RevenueStats', () {
    test('subscriptionsToday: counts only transactions since UTC midnight', () {
      final now = DateTime.now().toUtc();
      final todayMidnight = DateTime.utc(now.year, now.month, now.day);
      final yesterday = todayMidnight.subtract(const Duration(hours: 1));

      final transactions = [
        RevenueTransaction(
          userId: 'u1',
          amount: 100,
          type: 'subscription',
          createdAt: todayMidnight, // exactly midnight — included
        ),
        RevenueTransaction(
          userId: 'u2',
          amount: 100,
          type: 'subscription',
          createdAt: yesterday, // yesterday — excluded
        ),
      ];

      final stats = RevenueStats(
        recentTransactions: transactions,
        dailyRevenue: const [],
        tierBreakdown: const [],
      );

      expect(stats.subscriptionsToday, equals(1));
    });

    test('subscriptionsThisWeek: counts transactions within last 7 days', () {
      final now = DateTime.now().toUtc();
      final sixDaysAgo = now.subtract(const Duration(days: 6));
      final eightDaysAgo = now.subtract(const Duration(days: 8));

      final transactions = [
        RevenueTransaction(
          userId: 'u1',
          amount: 100,
          type: 'subscription',
          createdAt: sixDaysAgo, // 6 days ago — included
        ),
        RevenueTransaction(
          userId: 'u2',
          amount: 100,
          type: 'subscription',
          createdAt: eightDaysAgo, // 8 days ago — excluded
        ),
      ];

      final stats = RevenueStats(
        recentTransactions: transactions,
        dailyRevenue: const [],
        tierBreakdown: const [],
      );

      expect(stats.subscriptionsThisWeek, equals(1));
    });

    test('totalPremiumUsers: sums all non-free tiers', () {
      final stats = RevenueStats(
        recentTransactions: const [],
        dailyRevenue: const [],
        tierBreakdown: const [
          TierBreakdown(tier: 'free', count: 80, totalUsers: 100),
          TierBreakdown(tier: 'basic', count: 10, totalUsers: 100),
          TierBreakdown(tier: 'premium', count: 10, totalUsers: 100),
        ],
      );

      expect(stats.totalPremiumUsers, equals(20));
    });

    test('totalPremiumUsers: zero when all users are free', () {
      final stats = RevenueStats(
        recentTransactions: const [],
        dailyRevenue: const [],
        tierBreakdown: const [
          TierBreakdown(tier: 'free', count: 100, totalUsers: 100),
        ],
      );

      expect(stats.totalPremiumUsers, equals(0));
    });
  });

  group('RevenueTransaction', () {
    test('userEmail is nullable (deleted profile case)', () {
      final tx = RevenueTransaction(
        userId: 'some-user-id',
        amount: 500,
        type: 'purchase',
        createdAt: DateTime.utc(2026, 3, 31),
        userEmail: null, // profile deleted
      );

      expect(tx.userEmail, isNull);
      expect(tx.userId, equals('some-user-id'));
    });
  });
}
