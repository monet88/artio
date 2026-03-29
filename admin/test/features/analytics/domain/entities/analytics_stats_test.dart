import 'package:artio_admin/features/analytics/domain/entities/analytics_stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnalyticsStats', () {
    group('freeUsers', () {
      test('returns totalUsers - premiumUsers', () {
        final stats = _stats(totalUsers: 100, premiumUsers: 30);
        expect(stats.freeUsers, 70);
      });

      test('returns 0 when all users are premium', () {
        final stats = _stats(totalUsers: 50, premiumUsers: 50);
        expect(stats.freeUsers, 0);
      });

      test('equals totalUsers when no premium users', () {
        final stats = _stats(totalUsers: 200, premiumUsers: 0);
        expect(stats.freeUsers, 200);
      });
    });

    group('DailyCount', () {
      test('stores date and count', () {
        final date = DateTime(2026, 3, 29);
        final dc = DailyCount(date: date, count: 42);
        expect(dc.date, date);
        expect(dc.count, 42);
      });
    });

    group('ModelCount', () {
      test('stores model and count', () {
        const mc = ModelCount(model: 'gemini-2.0-flash', count: 99);
        expect(mc.model, 'gemini-2.0-flash');
        expect(mc.count, 99);
      });
    });
  });
}

AnalyticsStats _stats({int totalUsers = 0, int premiumUsers = 0}) =>
    AnalyticsStats(
      totalUsers: totalUsers,
      totalJobs: 0,
      premiumUsers: premiumUsers,
      jobsToday: 0,
      dailyJobs: const [],
      topModels: const [],
    );
