import 'package:artio/features/create/presentation/providers/create_form_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CreateFormNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test(
      'setModel keeps aspect ratio when universally supported',
      () {
        // All models share the universal aspect ratio list;
        // server-side mapping handles model-specific restrictions (e.g. GPT)
        container.read(createFormNotifierProvider.notifier)
          ..setAspectRatio('16:9')
          ..setModel('gpt-image/1.5-text-to-image');

        final state = container.read(createFormNotifierProvider);
        expect(state.modelId, 'gpt-image/1.5-text-to-image');
        expect(state.aspectRatio, '16:9');
      },
    );

    test('setModel keeps aspect ratio when switching models', () {
      container.read(createFormNotifierProvider.notifier)
        ..setAspectRatio('3:4')
        ..setModel('gpt-image/1.5-text-to-image');

      final state = container.read(createFormNotifierProvider);
      expect(state.aspectRatio, '3:4');
    });
  });
}
