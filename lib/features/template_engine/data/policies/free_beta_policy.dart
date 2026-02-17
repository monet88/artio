import 'package:artio/features/template_engine/domain/policies/generation_policy.dart';

class FreeBetaPolicy implements IGenerationPolicy {
  const FreeBetaPolicy();

  @override
  Future<GenerationEligibility> canGenerate({
    required String userId,
    required String templateId,
  }) async {
    return const GenerationEligibility.allowed(remainingCredits: 999);
  }
}
