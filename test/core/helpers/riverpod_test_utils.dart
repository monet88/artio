import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Creates a [ProviderContainer] for testing Riverpod providers
///
/// The container is automatically disposed after the test via [addTearDown].
///
/// ```dart
/// test('provider test', () {
///   final container = createContainer();
///   final value = container.read(myProvider);
///   expect(value, 'expected');
/// });
/// ```
ProviderContainer createContainer({
  List<Override>? overrides,
  ProviderContainer? parent,
}) {
  final container = ProviderContainer(
    overrides: overrides ?? [],
    parent: parent,
  );
  addTearDown(container.dispose);
  return container;
}

/// Matcher for [AsyncLoading] state
Matcher isAsyncLoading<T>() => isA<AsyncLoading<T>>();

/// Matcher for [AsyncData] state
Matcher isAsyncData<T>() => isA<AsyncData<T>>();

/// Matcher for [AsyncError] state
Matcher isAsyncError<T>() => isA<AsyncError<T>>();

/// Returns a matcher that checks if AsyncValue has data
Matcher hasData<T>(T expected) =>
    isA<AsyncData<T>>().having((d) => d.value, 'value', expected);

/// Returns a matcher that checks if AsyncValue has an error
Matcher hasError<T>() => isA<AsyncError<T>>();
