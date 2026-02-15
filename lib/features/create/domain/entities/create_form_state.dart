import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_form_state.freezed.dart';
part 'create_form_state.g.dart';

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

  factory CreateFormState.fromJson(Map<String, dynamic> json) =>
      _$CreateFormStateFromJson(json);

  bool get isValid => prompt.trim().length >= 3;

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
      templateId: 'free-text',
    );
  }
}
