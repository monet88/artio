import 'package:artio/features/template_engine/data/policies/credit_check_policy.dart';
import 'package:artio/features/template_engine/domain/policies/generation_policy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generation_policy_provider.g.dart';

@riverpod
IGenerationPolicy generationPolicy(Ref ref) {
  return CreditCheckPolicy(ref);
}
