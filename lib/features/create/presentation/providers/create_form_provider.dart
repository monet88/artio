import 'package:artio/features/create/domain/entities/create_form_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_form_provider.g.dart';

@riverpod
class CreateFormNotifier extends _$CreateFormNotifier {
  @override
  CreateFormState build() => const CreateFormState();

  void setPrompt(String prompt) {
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

  void setModel(String modelId) {
    state = state.copyWith(modelId: modelId);
  }

  void reset() {
    state = const CreateFormState();
  }
}
