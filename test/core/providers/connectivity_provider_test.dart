import 'package:artio/core/providers/connectivity_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('connectivity provider', () {
    test('emits true when overridden with online stream', () async {
      final container = ProviderContainer(
        overrides: [
          connectivityProvider
              .overrideWith((_) => Stream.value(true)),
        ],
      );
      addTearDown(container.dispose);

      final value = await container.read(connectivityProvider.future);
      expect(value, isTrue);
    });

    test('emits false when overridden with offline stream', () async {
      final container = ProviderContainer(
        overrides: [
          connectivityProvider
              .overrideWith((_) => Stream.value(false)),
        ],
      );
      addTearDown(container.dispose);

      final value = await container.read(connectivityProvider.future);
      expect(value, isFalse);
    });

    test('handles stream of connectivity changes', () async {
      final container = ProviderContainer(
        overrides: [
          connectivityProvider.overrideWith(
            (_) => Stream.fromIterable([true, false, true]),
          ),
        ],
      );
      addTearDown(container.dispose);

      // First value is true
      final value = await container.read(connectivityProvider.future);
      expect(value, isTrue);
    });
  });
}
