import 'package:artio/shared/widgets/error_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ErrorStateWidget reduced-motion', () {
    Widget buildWithMotionSetting({required bool disableAnimations}) {
      return MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: const MaterialApp(
          home: Scaffold(
            body: ErrorStateWidget(message: 'Test error'),
          ),
        ),
      );
    }

    testWidgets('immediately visible when reduced-motion is enabled',
        (tester) async {
      await tester.pumpWidget(buildWithMotionSetting(disableAnimations: true));
      await tester.pump();

      // Find FadeTransition that is a descendant of ErrorStateWidget
      final fadeFinder = find.descendant(
        of: find.byType(ErrorStateWidget),
        matching: find.byType(FadeTransition),
      );
      expect(fadeFinder, findsOneWidget);

      final fade = tester.widget<FadeTransition>(fadeFinder);
      expect(fade.opacity.value, 1.0);

      // Content should be visible
      expect(find.text('Test error'), findsOneWidget);
    });

    testWidgets('starts faded when reduced-motion is disabled',
        (tester) async {
      await tester.pumpWidget(buildWithMotionSetting(disableAnimations: false));
      await tester.pump();

      final fadeFinder = find.descendant(
        of: find.byType(ErrorStateWidget),
        matching: find.byType(FadeTransition),
      );
      expect(fadeFinder, findsOneWidget);

      final fade = tester.widget<FadeTransition>(fadeFinder);
      expect(fade.opacity.value, lessThan(1.0));
    });
  });
}
