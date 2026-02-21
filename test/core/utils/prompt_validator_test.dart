import 'package:artio/core/exceptions/app_exception.dart';
import 'package:artio/core/utils/prompt_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('validateGenerationPrompt', () {
    test('returns trimmed prompt for valid input', () {
      final result = validateGenerationPrompt('  hello world  ');
      expect(result, equals('hello world'));
    });

    test('returns prompt at exact minimum length', () {
      final result = validateGenerationPrompt('abc');
      expect(result, equals('abc'));
    });

    test('returns prompt at exact maximum length', () {
      final longPrompt = 'a' * kMaxPromptLength;
      final result = validateGenerationPrompt(longPrompt);
      expect(result, equals(longPrompt));
    });

    test('throws for empty string', () {
      expect(() => validateGenerationPrompt(''), throwsA(isA<AppException>()));
    });

    test('throws for whitespace-only string', () {
      expect(
        () => validateGenerationPrompt('   '),
        throwsA(isA<AppException>()),
      );
    });

    test('throws for prompt shorter than minimum', () {
      expect(
        () => validateGenerationPrompt('ab'),
        throwsA(
          isA<AppException>().having(
            (e) => e.toString(),
            'message',
            contains('at least $kMinPromptLength'),
          ),
        ),
      );
    });

    test('throws for prompt exceeding maximum length', () {
      final tooLong = 'a' * (kMaxPromptLength + 1);
      expect(
        () => validateGenerationPrompt(tooLong),
        throwsA(
          isA<AppException>().having(
            (e) => e.toString(),
            'message',
            contains('at most $kMaxPromptLength'),
          ),
        ),
      );
    });

    test('trims leading whitespace before length check', () {
      // 2 chars + leading spaces = still too short after trim
      expect(
        () => validateGenerationPrompt('   ab'),
        throwsA(isA<AppException>()),
      );
    });

    test('trims trailing whitespace before length check', () {
      final result = validateGenerationPrompt('abc   ');
      expect(result, equals('abc'));
    });
  });
}
