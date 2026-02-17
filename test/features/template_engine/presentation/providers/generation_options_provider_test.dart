import 'package:artio/features/template_engine/presentation/providers/generation_options_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GenerationOptionsProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state has default values', () {
      final state = container.read(generationOptionsProvider);

      expect(state.aspectRatio, '1:1');
      expect(state.imageCount, 1);
      expect(state.outputFormat, 'jpg');
      expect(state.modelId, 'google/imagen4');
      expect(state.otherIdeas, '');
    });

    test('updateAspectRatio changes aspectRatio', () {
      container.read(generationOptionsProvider.notifier).updateAspectRatio('16:9');

      final state = container.read(generationOptionsProvider);
      expect(state.aspectRatio, '16:9');
    });

    test('updateImageCount changes imageCount', () {
      container.read(generationOptionsProvider.notifier).updateImageCount(3);

      final state = container.read(generationOptionsProvider);
      expect(state.imageCount, 3);
    });

    test('updateOutputFormat changes outputFormat', () {
      container.read(generationOptionsProvider.notifier).updateOutputFormat('png');

      final state = container.read(generationOptionsProvider);
      expect(state.outputFormat, 'png');
    });

    test('updateModel changes modelId', () {
      container.read(generationOptionsProvider.notifier).updateModel('google/imagen4-ultra');

      final state = container.read(generationOptionsProvider);
      expect(state.modelId, 'google/imagen4-ultra');
    });

    test('updateOtherIdeas changes otherIdeas', () {
      container.read(generationOptionsProvider.notifier).updateOtherIdeas('Add more contrast');

      final state = container.read(generationOptionsProvider);
      expect(state.otherIdeas, 'Add more contrast');
    });

    test('reset restores default values', () {
      // Change all values, then reset
      container.read(generationOptionsProvider.notifier)
        ..updateAspectRatio('16:9')
        ..updateImageCount(4)
        ..updateOutputFormat('png')
        ..updateModel('flux-2/pro-text-to-image')
        ..updateOtherIdeas('Some ideas')
        ..reset();

      final state = container.read(generationOptionsProvider);
      expect(state.aspectRatio, '1:1');
      expect(state.imageCount, 1);
      expect(state.outputFormat, 'jpg');
      expect(state.modelId, 'google/imagen4');
      expect(state.otherIdeas, '');
    });

    test('multiple updates preserve other fields', () {
      container.read(generationOptionsProvider.notifier)
        ..updateAspectRatio('4:3')
        ..updateImageCount(2);

      final state = container.read(generationOptionsProvider);
      expect(state.aspectRatio, '4:3');
      expect(state.imageCount, 2);
      expect(state.outputFormat, 'jpg'); // unchanged
      expect(state.modelId, 'google/imagen4'); // unchanged
    });
  });
}
