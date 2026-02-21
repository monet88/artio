import 'package:artio/features/credits/domain/entities/credit_balance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CreditBalance', () {
    final now = DateTime.utc(2026, 2, 19);

    test('constructs with required fields', () {
      final balance = CreditBalance(
        userId: 'user-1',
        balance: 50,
        updatedAt: now,
      );
      expect(balance.userId, 'user-1');
      expect(balance.balance, 50);
      expect(balance.updatedAt, now);
    });

    test('equality works (Freezed)', () {
      final a = CreditBalance(userId: 'u1', balance: 10, updatedAt: now);
      final b = CreditBalance(userId: 'u1', balance: 10, updatedAt: now);
      final c = CreditBalance(userId: 'u1', balance: 20, updatedAt: now);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('copyWith creates modified copy', () {
      final original = CreditBalance(userId: 'u1', balance: 10, updatedAt: now);
      final modified = original.copyWith(balance: 99);
      expect(modified.balance, 99);
      expect(modified.userId, 'u1');
    });

    test('fromJson/toJson roundtrip', () {
      final original = CreditBalance(userId: 'u1', balance: 42, updatedAt: now);
      final json = original.toJson();
      final restored = CreditBalance.fromJson(json);
      expect(restored, equals(original));
    });

    test('fromJson maps snake_case keys', () {
      final balance = CreditBalance.fromJson({
        'user_id': 'u2',
        'balance': 100,
        'updated_at': '2026-02-19T00:00:00.000Z',
      });
      expect(balance.userId, 'u2');
      expect(balance.balance, 100);
    });
  });
}
