import 'package:artio/core/constants/ai_models.dart';
import 'package:artio/features/create/domain/entities/create_form_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_form_provider.g.dart';

@riverpod
class CreateFormNotifier extends _$CreateFormNotifier {
  bool _hasInteracted = false;

  /// Whether the user has interacted with the prompt field.
  ///
  /// Used to suppress validation errors before the user starts typing,
  /// preventing a "Prompt too short" error on initial render.
  bool get hasInteracted => _hasInteracted;

  @override
  CreateFormState build() {
    _hasInteracted = false;
    return const CreateFormState();
  }

  void setPrompt(String prompt) {
    _hasInteracted = true;
    state = state.copyWith(prompt: prompt);
  }

  void setNegativePrompt(String negativePrompt) {
    state = state.copyWith(negativePrompt: negativePrompt);
  }

  void setAspectRatio(String aspectRatio) {
    state = state.copyWith(aspectRatio: aspectRatio);
  }

  void setImageCount(int imageCount) {
    state = state.copyWith(imageCount: imageCount);
  }

  void setOutputFormat(String outputFormat) {
    state = state.copyWith(outputFormat: outputFormat);
  }

  /// Sets the model and validates aspect ratio compatibility.
  ///
  /// If the currently selected aspect ratio is not supported by the new model,
  /// it is automatically reset to the first supported ratio for that model.
  void setModel(String modelId) {
    final model = AiModels.getById(modelId);
    final supportedRatios =
        model?.supportedAspectRatios ?? AiModels.supportedAspectRatios;

    // If current aspect ratio is not supported by the new model, reset it
    final newAspectRatio = supportedRatios.contains(state.aspectRatio)
        ? state.aspectRatio
        : supportedRatios.first;

    state = state.copyWith(modelId: modelId, aspectRatio: newAspectRatio);
  }

  void reset() {
    _hasInteracted = false;
    state = const CreateFormState();
  }
}
