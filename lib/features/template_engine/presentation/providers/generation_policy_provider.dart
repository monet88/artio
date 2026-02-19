import 'package:artio/features/template_engine/domain/providers/free_beta_policy_provider.dart';
import 'package:artio/features/template_engine/domain/policies/generation_policy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generation_policy_provider.g.dart';

@riverpod
IGenerationPolicy generationPolicy(Ref ref) {
  return const FreeBetaPolicy();
}
