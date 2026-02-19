import 'dart:async';

import 'package:artio/features/credits/data/repositories/credit_repository.dart';
import 'package:artio/features/credits/domain/entities/credit_balance.dart';
import 'package:artio/features/credits/presentation/providers/credit_balance_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCreditRepository extends Mock implements CreditRepository {}

void main() {
  late MockCreditRepository mockRepository;

  setUp(() {
    mockRepository = MockCreditRepository();
  });

  ProviderContainer createContainer({
    required Stream<CreditBalance> balanceStream,
  }) {
    when(() => mockRepository.watchBalance())
        .thenAnswer((_) => balanceStream);

    return ProviderContainer(
      overrides: [
        creditRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  }

  group('CreditBalanceNotifier', () {
    test('emits balance from repository stream', () async {
      final balance = CreditBalance(
        userId: 'user-1',
        balance: 100,
        updatedAt: DateTime(2026),
      );

      final container = createContainer(
        balanceStream: Stream.value(balance),
      );
      addTearDown(container.dispose);

      final result = await container.read(creditBalanceNotifierProvider.future);

      expect(result.balance, 100);
      expect(result.userId, 'user-1');
    });

    test('handles repository stream errors as AsyncError', () async {
      final controller = StreamController<CreditBalance>()
        ..addError(Exception('Stream error'));

      final container = createContainer(
        balanceStream: controller.stream,
      );
      addTearDown(() {
        container.dispose();
        controller.close();
      });

      // Wait for the error to propagate
      await expectLater(
        container.read(creditBalanceNotifierProvider.future),
        throwsA(isA<Exception>()),
      );
    });

    test('currentBalance returns null when no data', () {
      final controller = StreamController<CreditBalance>();

      final container = createContainer(
        balanceStream: controller.stream,
      );
      addTearDown(() {
        container.dispose();
        controller.close();
      });

      final notifier = container.read(creditBalanceNotifierProvider.notifier);

      expect(notifier.currentBalance, isNull);
    });

    test('currentBalance returns balance value after data arrives', () async {
      final balance = CreditBalance(
        userId: 'user-1',
        balance: 42,
        updatedAt: DateTime(2026),
      );

      final container = createContainer(
        balanceStream: Stream.value(balance),
      );
      addTearDown(container.dispose);

      await container.read(creditBalanceNotifierProvider.future);
      final notifier = container.read(creditBalanceNotifierProvider.notifier);

      expect(notifier.currentBalance, 42);
    });
  });
}
