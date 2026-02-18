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

        when(() => mockRepository.fetchBalance())
            .thenAnswer((_) async => balance);

        final result = await mockRepository.fetchBalance();

        expect(result.userId, 'user-1');
        expect(result.balance, 50);
      });

      test('throws AppException.network on error', () async {
        when(() => mockRepository.fetchBalance())
            .thenThrow(const AppException.network(message: 'DB error'));

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

        when(() => mockRepository.watchBalance())
            .thenAnswer((_) => controller.stream);

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

        when(() => mockRepository.fetchTransactions())
            .thenAnswer((_) async => transactions);

        final result = await mockRepository.fetchTransactions();

        expect(result, hasLength(2));
        expect(result[0].type, 'generation');
        expect(result[0].amount, -5);
        expect(result[1].type, 'welcome_bonus');
      });

      test('returns empty list when no transactions', () async {
        when(() => mockRepository.fetchTransactions())
            .thenAnswer((_) async => []);

        final result = await mockRepository.fetchTransactions();

        expect(result, isEmpty);
      });

      test('throws AppException.network on error', () async {
        when(() => mockRepository.fetchTransactions())
            .thenThrow(const AppException.network(message: 'DB error'));

        expect(
          () => mockRepository.fetchTransactions(),
          throwsA(isA<NetworkException>()),
        );
      });
    });
  });
}
