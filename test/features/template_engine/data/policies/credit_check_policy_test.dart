import 'package:artio/features/credits/domain/entities/credit_balance.dart';
import 'package:artio/features/credits/presentation/providers/credit_balance_provider.dart';
import 'package:artio/features/template_engine/data/policies/credit_check_policy.dart';
import 'package:artio/features/template_engine/presentation/providers/generation_policy_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CreditCheckPolicy', () {
    late ProviderContainer container;

    tearDown(() {
      container.dispose();
    });

    /// Creates a container and waits for the credit balance to settle.
    Future<CreditCheckPolicy> createPolicyWithBalance(int balance) async {
      container =
          ProviderContainer(
              overrides: [
                creditBalanceNotifierProvider.overrideWith(() {
                  return _FixedBalanceNotifier(balance);
                }),
              ],
            )
            // Listen to trigger the stream and wait for data
            ..listen(creditBalanceNotifierProvider, (_, __) {});
      // Wait for the async stream to emit
      for (var i = 0; i < 20; i++) {
        await Future<void>.delayed(Duration.zero);
        if (container.read(creditBalanceNotifierProvider).hasValue) break;
      }

      return container.read(generationPolicyProvider) as CreditCheckPolicy;
    }

    test('returns denied when balance < 4', () async {
      final policy = await createPolicyWithBalance(3);

      final result = await policy.canGenerate(
        userId: 'user-1',
        templateId: 'template-1',
      );

      expect(result.isDenied, true);
      expect(result.denialReason, 'Insufficient credits');
    });

    test('returns denied when balance is 0', () async {
      final policy = await createPolicyWithBalance(0);

      final result = await policy.canGenerate(
        userId: 'user-1',
        templateId: 'template-1',
      );

      expect(result.isDenied, true);
      expect(result.denialReason, 'Insufficient credits');
    });

    test('returns allowed when balance >= 4', () async {
      final policy = await createPolicyWithBalance(4);

      final result = await policy.canGenerate(
        userId: 'user-1',
        templateId: 'template-1',
      );

      expect(result.isAllowed, true);
    });

    test(
      'returns allowed with remainingCredits when balance is sufficient',
      () async {
        final policy = await createPolicyWithBalance(50);

        final result = await policy.canGenerate(
          userId: 'user-1',
          templateId: 'template-1',
        );

        expect(result.isAllowed, true);
        result.maybeMap(
          allowed: (a) => expect(a.remainingCredits, 50),
          orElse: () => fail('Expected allowed'),
        );
      },
    );

    test('returns allowed when balance is null (not loaded)', () async {
      // Default container without overriding the balance provider.
      // The stream provider hasn't emitted yet → valueOrNull is null.
      container = ProviderContainer();
      final policy =
          container.read(generationPolicyProvider) as CreditCheckPolicy;

      final result = await policy.canGenerate(
        userId: 'user-1',
        templateId: 'template-1',
      );

      expect(result.isAllowed, true);
      // No remainingCredits when balance unknown
      result.maybeMap(
        allowed: (a) => expect(a.remainingCredits, isNull),
        orElse: () => fail('Expected allowed'),
      );
    });
  });
}

/// A simple notifier that immediately emits a fixed balance.
class _FixedBalanceNotifier extends CreditBalanceNotifier {
  _FixedBalanceNotifier(this._balance);
  final int _balance;

  @override
  Stream<CreditBalance> build() async* {
    yield CreditBalance(
      userId: 'test-user',
      balance: _balance,
      updatedAt: DateTime(2026),
    );
  }
}
