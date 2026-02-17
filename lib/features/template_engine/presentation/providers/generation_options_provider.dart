import 'package:artio/features/template_engine/domain/entities/generation_options_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generation_options_provider.g.dart';

@riverpod
class GenerationOptions extends _$GenerationOptions {
  @override
  GenerationOptionsModel build() {
    return const GenerationOptionsModel();
  }

  void updateAspectRatio(String aspectRatio) {
    state = state.copyWith(aspectRatio: aspectRatio);
  }

  void updateImageCount(int imageCount) {
    state = state.copyWith(imageCount: imageCount);
  }

  void updateOutputFormat(String outputFormat) {
    state = state.copyWith(outputFormat: outputFormat);
  }

  void updateModel(String modelId) {
    state = state.copyWith(modelId: modelId);
  }

  void updateOtherIdeas(String otherIdeas) {
    state = state.copyWith(otherIdeas: otherIdeas);
  }

  void reset() {
    state = const GenerationOptionsModel();
  }
}
