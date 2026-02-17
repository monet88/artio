import 'package:artio/features/template_engine/data/policies/free_beta_policy.dart';
import 'package:artio/features/template_engine/domain/policies/generation_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FreeBetaPolicy', () {
    late FreeBetaPolicy policy;

    setUp(() {
      policy = const FreeBetaPolicy();
    });

    group('canGenerate', () {
      test('always returns allowed for any user', () async {
        final result = await policy.canGenerate(
          userId: 'user-123',
          templateId: 'template-456',
        );

        expect(result.isAllowed, true);
        expect(result.isDenied, false);
      });

      test('returns allowed with 999 remaining credits', () async {
        final result = await policy.canGenerate(
          userId: 'any-user',
          templateId: 'any-template',
        );

        result.maybeMap(
          allowed: (allowed) {
            expect(allowed.remainingCredits, 999);
          },
          orElse: () => fail('Expected allowed result'),
        );
      });

      test('works with empty userId', () async {
        final result = await policy.canGenerate(
          userId: '',
          templateId: 'template-123',
        );

        expect(result.isAllowed, true);
      });

      test('works with empty templateId', () async {
        final result = await policy.canGenerate(
          userId: 'user-123',
          templateId: '',
        );

        expect(result.isAllowed, true);
      });

      test('denialReason is null for allowed result', () async {
        final result = await policy.canGenerate(
          userId: 'user-123',
          templateId: 'template-456',
        );

        expect(result.denialReason, isNull);
      });
    });

    group('GenerationEligibility', () {
      test('allowed factory creates allowed state', () {
        const eligibility = GenerationEligibility.allowed(remainingCredits: 10);

        expect(eligibility.isAllowed, true);
        expect(eligibility.isDenied, false);
      });

      test('denied factory creates denied state', () {
        const eligibility = GenerationEligibility.denied(
          reason: 'No credits remaining',
        );

        expect(eligibility.isAllowed, false);
        expect(eligibility.isDenied, true);
        expect(eligibility.denialReason, 'No credits remaining');
      });

      test('allowed with null credits', () {
        const eligibility = GenerationEligibility.allowed();

        expect(eligibility.isAllowed, true);
      });
    });
  });
}
