import 'package:artio/core/constants/generation_constants.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_form_state.freezed.dart';

@freezed
class CreateFormState with _$CreateFormState {
  const factory CreateFormState({
    @Default('') String prompt,
    @Default('') String negativePrompt,
    @Default('1:1') String aspectRatio,
    @Default(1) int imageCount,
    @Default('jpg') String outputFormat,
    @Default('google/imagen4') String modelId,
  }) = _CreateFormState;

  const CreateFormState._();

  bool get isValid => prompt.trim().length >= 3;

  /// Returns generation parameters for the API call.
  ///
  /// Note: Negative prompt is appended with "\n\nNegative: " prefix.
  /// This is the expected prompt engineering format — the downstream API
  /// (Kie/Gemini) receives a single prompt string. There is no separate
  /// `negative_prompt` field in the Edge Function.
  /// See: supabase/functions/generate-image/index.ts
  ({
    String prompt,
    String aspectRatio,
    int imageCount,
    String templateId,
  }) toGenerationParams() {
    final trimmedPrompt = prompt.trim();
    final trimmedNegative = negativePrompt.trim();
    final fullPrompt = trimmedNegative.isEmpty
        ? trimmedPrompt
        : '$trimmedPrompt\n\nNegative: $trimmedNegative';

    return (
      prompt: fullPrompt,
      aspectRatio: aspectRatio,
      imageCount: imageCount,
      templateId: kFreeTextTemplateId,
    );
  }
}
