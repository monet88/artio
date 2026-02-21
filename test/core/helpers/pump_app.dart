import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Extension on [WidgetTester] to simplify widget pumping in tests
extension PumpApp on WidgetTester {
  /// Pumps a widget wrapped in [MaterialApp] and [ProviderScope]
  ///
  /// Use this in widget tests to provide the necessary dependencies
  /// for widgets that use Riverpod providers or Material widgets.
  ///
  /// ```dart
  /// await tester.pumpApp(MyWidget());
  /// ```
  Future<void> pumpApp(
    Widget widget, {
    List<Override>? overrides,
    ThemeData? theme,
  }) async {
    await pumpWidget(
      ProviderScope(
        overrides: overrides ?? [],
        child: MaterialApp(
          title: 'Test App',
          theme: theme ?? ThemeData.light(),
          home: widget,
        ),
      ),
    );
  }

  /// Pumps a widget with GoRouter navigation support
  ///
  /// Use this in tests that need to verify navigation behavior.
  Future<void> pumpAppWithRouter({
    required GoRouter router,
    List<Override>? overrides,
  }) async {
    await pumpWidget(
      ProviderScope(
        overrides: overrides ?? [],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
  }
}
