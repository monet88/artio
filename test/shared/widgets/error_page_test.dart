import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:artio/shared/widgets/error_page.dart';

void main() {
  group('ErrorPage', () {
    Widget buildWidget({Exception? error}) {
      return MaterialApp(
        home: Scaffold(
          body: ErrorPage(error: error),
        ),
      );
    }

    testWidgets('renders error message', (tester) async {
      final error = Exception('Test error message');

      await tester.pumpWidget(buildWidget(error: error));

      // Exception.toString() includes "Exception:" prefix
      expect(find.text('Exception: Test error message'), findsOneWidget);
    });

    testWidgets('renders generic message when error is null', (tester) async {
      await tester.pumpWidget(buildWidget(error: null));

      expect(find.text('Page not found'), findsOneWidget);
    });

    testWidgets('renders error icon', (tester) async {
      await tester.pumpWidget(buildWidget(error: Exception('Error')));

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('renders Go Back button', (tester) async {
      await tester.pumpWidget(buildWidget(error: Exception('Error')));

      expect(find.text('Go Back'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });
}
