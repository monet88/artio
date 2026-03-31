import 'package:artio_admin/features/analytics/domain/entities/analytics_stats.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for analytics provider client-side aggregation logic.
///
/// The provider accesses Supabase.instance.client (static singleton) directly.
/// We test the pure computation logic here using the same algorithms.
void main() {
  group('7-day window UTC boundary', () {
    test('sevenDaysAgo is computed in UTC, not local time', () {
      // Provider uses: DateTime.now().toUtc().subtract(const Duration(days: 7))
      // This test verifies the UTC computation produces the correct boundary.
      final now = DateTime.now().toUtc();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));

      // sevenDaysAgo must be UTC
      expect(sevenDaysAgo.isUtc, isTrue);

      // Must be exactly 7 days before now (within 1 second for test latency)
      final diff = now.difference(sevenDaysAgo);
      expect(diff.inHours, equals(168)); // 7 * 24
    });

    test('todayStart is UTC midnight, not local midnight', () {
      final now = DateTime.now().toUtc();
      final todayStart = DateTime.utc(now.year, now.month, now.day);

      expect(todayStart.isUtc, isTrue);
      expect(todayStart.hour, 0);
      expect(todayStart.minute, 0);
    });
  });

  group('zero-fill daily jobs', () {
    test('produces 7 entries for 7-day window', () {
      final now = DateTime.now().toUtc();
      final dailyMap = <String, int>{}; // empty — no data

      final dailyJobs = <DailyCount>[];
      for (var i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final normalized = DateTime.utc(date.year, date.month, date.day);
        final key =
            '${normalized.year}-${normalized.month.toString().padLeft(2, '0')}-${normalized.day.toString().padLeft(2, '0')}';
        dailyJobs.add(DailyCount(date: normalized, count: dailyMap[key] ?? 0));
      }

      expect(dailyJobs, hasLength(7));
      expect(dailyJobs.every((d) => d.count == 0), isTrue);
    });

    test('oldest day is index 0, newest is index 6', () {
      final now = DateTime.now().toUtc();
      final today = DateTime.utc(now.year, now.month, now.day);
      final sixDaysAgo = today.subtract(const Duration(days: 6));

      final dailyJobs = <DailyCount>[];
      for (var i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final normalized = DateTime.utc(date.year, date.month, date.day);
        dailyJobs.add(DailyCount(date: normalized, count: 0));
      }

      expect(dailyJobs.first.date, equals(sixDaysAgo));
      expect(dailyJobs.last.date, equals(today));
    });

    test('days with data show correct count', () {
      final now = DateTime.now().toUtc();
      final today = DateTime.utc(now.year, now.month, now.day);
      final todayKey =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final dailyMap = {todayKey: 5}; // 5 jobs today

      final dailyJobs = <DailyCount>[];
      for (var i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final normalized = DateTime.utc(date.year, date.month, date.day);
        final key =
            '${normalized.year}-${normalized.month.toString().padLeft(2, '0')}-${normalized.day.toString().padLeft(2, '0')}';
        dailyJobs.add(DailyCount(date: normalized, count: dailyMap[key] ?? 0));
      }

      expect(dailyJobs.last.count, equals(5)); // today = last entry
      // All other days are zero
      expect(dailyJobs.sublist(0, 6).every((d) => d.count == 0), isTrue);
    });
  });

  group('top-5 models sort', () {
    test('returns top 5 models sorted descending by count', () {
      final rawJobs = [
        {'model_id': 'model-a'},
        {'model_id': 'model-a'},
        {'model_id': 'model-a'},
        {'model_id': 'model-b'},
        {'model_id': 'model-b'},
        {'model_id': 'model-c'},
        {'model_id': 'model-d'},
        {'model_id': 'model-e'},
        {'model_id': 'model-f'}, // 6th model — should be excluded
      ];

      final modelMap = <String, int>{};
      for (final job in rawJobs) {
        final model = (job['model_id'] as String?) ?? 'unknown';
        modelMap[model] = (modelMap[model] ?? 0) + 1;
      }
      final topModels = modelMap.entries
          .map((e) => ModelCount(model: e.key, count: e.value))
          .toList()
        ..sort((a, b) => b.count.compareTo(a.count));
      final top5 = topModels.take(5).toList();

      expect(top5, hasLength(5));
      expect(top5.first.model, equals('model-a'));
      expect(top5.first.count, equals(3));
      // model-f excluded (6th)
      expect(top5.map((m) => m.model), isNot(contains('model-f')));
    });

    test('empty job list returns empty top models', () {
      final rawJobs = <Map<String, dynamic>>[];
      final modelMap = <String, int>{};
      for (final job in rawJobs) {
        final model = (job['model_id'] as String?) ?? 'unknown';
        modelMap[model] = (modelMap[model] ?? 0) + 1;
      }
      final topModels = modelMap.entries
          .map((e) => ModelCount(model: e.key, count: e.value))
          .toList()
        ..sort((a, b) => b.count.compareTo(a.count));

      expect(topModels, isEmpty);
    });
  });
}
