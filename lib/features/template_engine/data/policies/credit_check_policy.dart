import 'package:artio/core/state/credit_balance_state_provider.dart';
import 'package:artio/features/template_engine/domain/policies/generation_policy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreditCheckPolicy implements IGenerationPolicy {
  const CreditCheckPolicy(this._ref);
  final Ref _ref;

  static const _minimumCost = 4;

  @override
  Future<GenerationEligibility> canGenerate({
    required String userId,
    required String templateId,
  }) async {
    final balance = _ref
        .read(creditBalanceNotifierProvider)
        .valueOrNull
        ?.balance;

    // Not loaded yet — allow and let server enforce
    if (balance == null) {
      return const GenerationEligibility.allowed();
    }

    if (balance < _minimumCost) {
      return const GenerationEligibility.denied(reason: 'Insufficient credits');
    }

    return GenerationEligibility.allowed(remainingCredits: balance);
  }
}
