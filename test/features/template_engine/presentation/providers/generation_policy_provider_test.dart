import 'package:artio/features/template_engine/data/policies/credit_check_policy.dart';
import 'package:artio/features/template_engine/domain/policies/generation_policy.dart';
import 'package:artio/features/template_engine/presentation/providers/generation_policy_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GenerationPolicyProvider', () {
    late ProviderContainer container;

    tearDown(() {
      container.dispose();
    });

    test('provides CreditCheckPolicy by default', () {
      container = ProviderContainer();
      final policy = container.read(generationPolicyProvider);

      expect(policy, isA<IGenerationPolicy>());
      expect(policy, isA<CreditCheckPolicy>());
    });

    test('can override policy in tests', () async {
      final customPolicy = _MockDeniedPolicy();
      container = ProviderContainer(
        overrides: [generationPolicyProvider.overrideWithValue(customPolicy)],
      );

      final policy = container.read(generationPolicyProvider);
      final result = await policy.canGenerate(
        userId: 'user-123',
        templateId: 'template-456',
      );

      expect(result.isDenied, true);
      expect(result.denialReason, 'No credits');
    });
  });
}

class _MockDeniedPolicy implements IGenerationPolicy {
  @override
  Future<GenerationEligibility> canGenerate({
    required String userId,
    required String templateId,
  }) async {
    return const GenerationEligibility.denied(reason: 'No credits');
  }
}
