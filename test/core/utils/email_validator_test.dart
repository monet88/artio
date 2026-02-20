import 'package:artio/core/utils/email_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EmailValidator', () {
    test('returns null for valid email', () {
      expect(EmailValidator.validate('user@example.com'), isNull);
    });

    test('returns error for empty string', () {
      expect(EmailValidator.validate(''), isNotNull);
    });

    test('returns error for null', () {
      expect(EmailValidator.validate(null), isNotNull);
    });

    test('returns error for whitespace only', () {
      expect(EmailValidator.validate('   '), isNotNull);
    });

    test('returns error for missing @', () {
      expect(EmailValidator.validate('userexample.com'), isNotNull);
    });

    test('returns error for missing TLD', () {
      expect(EmailValidator.validate('user@example'), isNotNull);
    });

    test('returns error for single-char TLD', () {
      expect(EmailValidator.validate('user@example.c'), isNotNull);
    });

    test('accepts multi-part domain', () {
      expect(EmailValidator.validate('user@sub.example.com'), isNull);
    });

    test('accepts email with dots in local part', () {
      expect(EmailValidator.validate('first.last@example.com'), isNull);
    });

    test('accepts email with plus sign', () {
      expect(EmailValidator.validate('user+tag@example.com'), isNull);
    });

    test('returns error for missing local part', () {
      expect(EmailValidator.validate('@example.com'), isNotNull);
    });
  });
}
