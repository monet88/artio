import 'package:artio/features/credits/domain/entities/credit_transaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CreditTransaction', () {
    final now = DateTime.utc(2026, 2, 19);

    test('constructs with required fields', () {
      final tx = CreditTransaction(
        id: 'tx-1',
        userId: 'u1',
        amount: -5,
        type: 'generation',
        createdAt: now,
      );
      expect(tx.id, 'tx-1');
      expect(tx.userId, 'u1');
      expect(tx.amount, -5);
      expect(tx.type, 'generation');
      expect(tx.referenceId, isNull);
    });

    test('optional referenceId is stored', () {
      final tx = CreditTransaction(
        id: 'tx-2',
        userId: 'u1',
        amount: 10,
        type: 'welcome_bonus',
        createdAt: now,
        referenceId: 'ref-abc',
      );
      expect(tx.referenceId, 'ref-abc');
    });

    test('equality works (Freezed)', () {
      final a = CreditTransaction(
        id: 'tx-1', userId: 'u1', amount: 5,
        type: 'ad_reward', createdAt: now,
      );
      final b = CreditTransaction(
        id: 'tx-1', userId: 'u1', amount: 5,
        type: 'ad_reward', createdAt: now,
      );
      final c = CreditTransaction(
        id: 'tx-2', userId: 'u1', amount: 5,
        type: 'ad_reward', createdAt: now,
      );
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('fromJson handles snake_case keys via _normalizeJson', () {
      final tx = CreditTransaction.fromJson({
        'id': 'tx-3',
        'user_id': 'u2',
        'amount': 50,
        'type': 'subscription',
        'created_at': '2026-02-19T00:00:00.000Z',
        'reference_id': 'sub-xyz',
      });
      expect(tx.userId, 'u2');
      expect(tx.referenceId, 'sub-xyz');
      expect(tx.createdAt, now);
    });

    test('fromJson handles camelCase keys', () {
      final tx = CreditTransaction.fromJson({
        'id': 'tx-4',
        'userId': 'u3',
        'amount': -10,
        'type': 'refund',
        'createdAt': '2026-02-19T00:00:00.000Z',
      });
      expect(tx.userId, 'u3');
      expect(tx.type, 'refund');
    });

    test('all transaction types are valid strings', () {
      for (final type in [
        'generation', 'welcome_bonus', 'ad_reward',
        'subscription', 'refund', 'manual',
      ]) {
        final tx = CreditTransaction(
          id: 'tx', userId: 'u', amount: 1,
          type: type, createdAt: now,
        );
        expect(tx.type, type);
      }
    });
  });
}
