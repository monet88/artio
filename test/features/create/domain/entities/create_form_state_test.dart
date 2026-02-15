import 'package:flutter_test/flutter_test.dart';
import 'package:artio/features/create/domain/entities/create_form_state.dart';

void main() {
  group('CreateFormState', () {
    test('defaults are set', () {
      const state = CreateFormState();

      expect(state.prompt, '');
      expect(state.negativePrompt, '');
      expect(state.aspectRatio, '1:1');
      expect(state.imageCount, 1);
      expect(state.outputFormat, 'jpg');
      expect(state.modelId, 'google/imagen4');
    });

    test('isValid true when prompt length >= 3', () {
      const state = CreateFormState(prompt: 'abcd');
      expect(state.isValid, true);
    });

    test('isValid false when prompt length < 3', () {
      const state = CreateFormState(prompt: 'ab');
      expect(state.isValid, false);
    });

    test('toGenerationParams returns merged prompt', () {
      const state = CreateFormState(
        prompt: 'A sunset',
        negativePrompt: 'blur',
        aspectRatio: '16:9',
        imageCount: 2,
      );

      final params = state.toGenerationParams();

      expect(params.templateId, 'free-text');
      expect(params.prompt, 'A sunset\n\nNegative: blur');
      expect(params.aspectRatio, '16:9');
      expect(params.imageCount, 2);
    });

    test('toGenerationParams trims prompt and negative prompt', () {
      const state = CreateFormState(
        prompt: '  Tree  ',
        negativePrompt: '  noise ',
      );

      final params = state.toGenerationParams();

      expect(params.prompt, 'Tree\n\nNegative: noise');
    });

    test('toGenerationParams without negative prompt keeps original prompt', () {
      const state = CreateFormState(prompt: 'Portrait', negativePrompt: '  ');

      final params = state.toGenerationParams();

      expect(params.prompt, 'Portrait');
    });
  });
}
