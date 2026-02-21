import 'package:freezed_annotation/freezed_annotation.dart';

part 'generation_policy.freezed.dart';

// ignore: one_member_abstracts, intentional DI interface
abstract class IGenerationPolicy {
  Future<GenerationEligibility> canGenerate({
    required String userId,
    required String templateId,
  });
}

@freezed
class GenerationEligibility with _$GenerationEligibility {
  const GenerationEligibility._();

  const factory GenerationEligibility.allowed({int? remainingCredits}) =
      _Allowed;

  const factory GenerationEligibility.denied({required String reason}) =
      _Denied;

  bool get isAllowed => this is _Allowed;
  bool get isDenied => this is _Denied;

  String? get denialReason =>
      maybeMap(denied: (d) => d.reason, orElse: () => null);
}
