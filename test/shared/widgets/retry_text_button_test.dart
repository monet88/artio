import 'package:artio/shared/widgets/retry_text_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RetryTextButton', () {
    testWidgets('renders icon and default label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: RetryTextButton(onPressed: () {})),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
    });

    testWidgets('fires onPressed on tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RetryTextButton(onPressed: () => tapped = true),
          ),
        ),
      );

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('accepts custom label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RetryTextButton(
              onPressed: () {},
              label: 'Try Again',
            ),
          ),
        ),
      );

      expect(find.text('Try Again'), findsOneWidget);
      expect(find.text('Retry'), findsNothing);
    });
  });
}
