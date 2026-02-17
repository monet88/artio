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

    test('setModel resets unsupported aspect ratio to first supported value', () {
      container.read(createFormNotifierProvider.notifier)
        ..setAspectRatio('16:9')
        ..setModel('gpt-image/1.5-text-to-image');

      final state = container.read(createFormNotifierProvider);
      expect(state.modelId, 'gpt-image/1.5-text-to-image');
      expect(state.aspectRatio, '1:1');
    });

    test('setModel keeps aspect ratio when it is supported', () {
      container.read(createFormNotifierProvider.notifier)
        ..setAspectRatio('2:3')
        ..setModel('gpt-image/1.5-text-to-image');

      final state = container.read(createFormNotifierProvider);
      expect(state.aspectRatio, '2:3');
    });
  });
}
