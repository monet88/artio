import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/policies/generation_policy.dart';
import '../../data/policies/free_beta_policy.dart';

part 'generation_policy_provider.g.dart';

@riverpod
IGenerationPolicy generationPolicy(GenerationPolicyRef ref) {
  return const FreeBetaPolicy();
}
