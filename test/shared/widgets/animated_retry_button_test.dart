import 'package:artio/shared/widgets/animated_retry_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnimatedRetryButton', () {
    Widget buildWidget({required VoidCallback onPressed}) {
      return MaterialApp(
        home: Scaffold(
          body: AnimatedRetryButton(
            onPressed: onPressed,
            color: Colors.orange,
          ),
        ),
      );
    }

    testWidgets('renders "Try Again" label', (tester) async {
      await tester.pumpWidget(buildWidget(onPressed: () {}));

      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('renders refresh icon', (tester) async {
      await tester.pumpWidget(buildWidget(onPressed: () {}));

      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
    });

    testWidgets('fires onPressed callback after animation', (tester) async {
      var pressed = false;
      await tester.pumpWidget(buildWidget(onPressed: () => pressed = true));

      await tester.tap(find.byType(OutlinedButton));
      // Wait for the 800ms spin animation to complete
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });

    testWidgets('shows "Retrying..." during animation', (tester) async {
      await tester.pumpWidget(buildWidget(onPressed: () {}));

      await tester.tap(find.byType(OutlinedButton));
      // Pump a frame to see the retrying state
      await tester.pump();

      expect(find.text('Retrying...'), findsOneWidget);
    });
  });
}
