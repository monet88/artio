import 'package:artio/core/utils/date_time_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('safeParseDateTime', () {
    test('parses valid ISO 8601 string', () {
      final result = safeParseDateTime('2026-01-15T10:30:00.000Z');
      expect(result, isNotNull);
      expect(result!.year, 2026);
      expect(result.month, 1);
      expect(result.day, 15);
    });

    test('returns fallback on invalid string', () {
      final fallback = DateTime(2000);
      final result = safeParseDateTime('not-a-date', fallback: fallback);
      expect(result, equals(fallback));
    });

    test('returns null on null input without fallback', () {
      final result = safeParseDateTime(null);
      expect(result, isNull);
    });

    test('returns fallback on null input', () {
      final fallback = DateTime(2000);
      final result = safeParseDateTime(null, fallback: fallback);
      expect(result, equals(fallback));
    });

    test('returns fallback on empty string', () {
      final fallback = DateTime(2000);
      final result = safeParseDateTime('', fallback: fallback);
      expect(result, equals(fallback));
    });

    test('returns null on empty string without fallback', () {
      final result = safeParseDateTime('');
      expect(result, isNull);
    });
  });
}
