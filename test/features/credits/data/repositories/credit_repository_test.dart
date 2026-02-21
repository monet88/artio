import 'dart:async';

import 'package:artio/core/exceptions/app_exception.dart';
import 'package:artio/features/credits/domain/entities/credit_balance.dart';
import 'package:artio/features/credits/domain/entities/credit_transaction.dart';
import 'package:artio/features/credits/domain/repositories/i_credit_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCreditRepository extends Mock implements ICreditRepository {}

void main() {
  late MockCreditRepository mockRepository;

  setUp(() {
    mockRepository = MockCreditRepository();
  });

  group('ICreditRepository', () {
    group('fetchBalance', () {
      test('returns CreditBalance on success', () async {
        final balance = CreditBalance(
          userId: 'user-1',
          balance: 50,
          updatedAt: DateTime(2026),
        );

        when(
          () => mockRepository.fetchBalance(),
        ).thenAnswer((_) async => balance);

        final result = await mockRepository.fetchBalance();

        expect(result.userId, 'user-1');
        expect(result.balance, 50);
      });

      test('throws AppException.network on error', () async {
        when(
          () => mockRepository.fetchBalance(),
        ).thenThrow(const AppException.network(message: 'DB error'));

        expect(
          () => mockRepository.fetchBalance(),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('watchBalance', () {
      test('emits CreditBalance updates', () async {
        final controller = StreamController<CreditBalance>();
        final balance1 = CreditBalance(
          userId: 'user-1',
          balance: 50,
          updatedAt: DateTime(2026),
        );
        final balance2 = CreditBalance(
          userId: 'user-1',
          balance: 45,
          updatedAt: DateTime(2026, 1, 2),
        );

        when(
          () => mockRepository.watchBalance(),
        ).thenAnswer((_) => controller.stream);

        final stream = mockRepository.watchBalance();

        controller
          ..add(balance1)
          ..add(balance2);

        await expectLater(
          stream,
          emitsInOrder([
            predicate<CreditBalance>((b) => b.balance == 50),
            predicate<CreditBalance>((b) => b.balance == 45),
          ]),
        );

        await controller.close();
      });
    });

    group('fetchTransactions', () {
      test('returns list of transactions', () async {
        final transactions = [
          CreditTransaction(
            id: 'tx-1',
            userId: 'user-1',
            amount: -5,
            type: 'generation',
            createdAt: DateTime(2026),
          ),
          CreditTransaction(
            id: 'tx-2',
            userId: 'user-1',
            amount: 50,
            type: 'welcome_bonus',
            createdAt: DateTime(2026),
          ),
        ];

        when(
          () => mockRepository.fetchTransactions(),
        ).thenAnswer((_) async => transactions);

        final result = await mockRepository.fetchTransactions();

        expect(result, hasLength(2));
        expect(result[0].type, 'generation');
        expect(result[0].amount, -5);
        expect(result[1].type, 'welcome_bonus');
      });

      test('returns empty list when no transactions', () async {
        when(
          () => mockRepository.fetchTransactions(),
        ).thenAnswer((_) async => []);

        final result = await mockRepository.fetchTransactions();

        expect(result, isEmpty);
      });

      test('throws AppException.network on error', () async {
        when(
          () => mockRepository.fetchTransactions(),
        ).thenThrow(const AppException.network(message: 'DB error'));

        expect(
          () => mockRepository.fetchTransactions(),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('rewardAdCredits', () {
      test('returns reward result on success', () async {
        when(
          () => mockRepository.rewardAdCredits(nonce: 'test-nonce'),
        ).thenAnswer(
          (_) async => (creditsAwarded: 5, newBalance: 55, adsRemaining: 7),
        );

        final result = await mockRepository.rewardAdCredits(
          nonce: 'test-nonce',
        );

        expect(result.creditsAwarded, 5);
        expect(result.newBalance, 55);
        expect(result.adsRemaining, 7);
      });

      test('throws AppException.validation when daily limit reached', () async {
        when(
          () => mockRepository.rewardAdCredits(nonce: 'test-nonce'),
        ).thenThrow(
          const AppException.network(
            message: 'Daily ad limit reached (10/day)',
            statusCode: 429,
          ),
        );

        expect(
          () => mockRepository.rewardAdCredits(nonce: 'test-nonce'),
          throwsA(isA<NetworkException>()),
        );
      });

      test('throws AppException.network on server error', () async {
        when(
          () => mockRepository.rewardAdCredits(nonce: 'test-nonce'),
        ).thenThrow(const AppException.network(message: 'Server error'));

        expect(
          () => mockRepository.rewardAdCredits(nonce: 'test-nonce'),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('requestAdNonce', () {
      test('returns nonce string on success', () async {
        when(
          () => mockRepository.requestAdNonce(),
        ).thenAnswer((_) async => 'abc-123-nonce');

        final result = await mockRepository.requestAdNonce();

        expect(result, 'abc-123-nonce');
      });

      test('throws AppException on error', () async {
        when(() => mockRepository.requestAdNonce()).thenThrow(
          const AppException.network(message: 'Failed to request nonce'),
        );

        expect(
          () => mockRepository.requestAdNonce(),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('fetchAdsRemainingToday', () {
      test('returns 10 when no ads watched today', () async {
        when(
          () => mockRepository.fetchAdsRemainingToday(),
        ).thenAnswer((_) async => 10);

        final result = await mockRepository.fetchAdsRemainingToday();

        expect(result, 10);
      });

      test('returns remaining count when some ads watched', () async {
        when(
          () => mockRepository.fetchAdsRemainingToday(),
        ).thenAnswer((_) async => 7);

        final result = await mockRepository.fetchAdsRemainingToday();

        expect(result, 7);
      });

      test('returns 0 when daily limit reached', () async {
        when(
          () => mockRepository.fetchAdsRemainingToday(),
        ).thenAnswer((_) async => 0);

        final result = await mockRepository.fetchAdsRemainingToday();

        expect(result, 0);
      });
    });
  });
}
