import 'package:artio/shared/widgets/loading_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoadingStateWidget reduced-motion', () {
    Widget buildWithMotionSetting({required bool disableAnimations}) {
      return MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: const MaterialApp(
          home: Scaffold(body: LoadingStateWidget()),
        ),
      );
    }

    testWidgets('shows static logo when reduced-motion is enabled',
        (tester) async {
      await tester.pumpWidget(buildWithMotionSetting(disableAnimations: true));
      await tester.pump();

      // In reduced-motion, _buildStaticLogo() is used — no Transform.scale
      final transformCount = find.descendant(
        of: find.byType(LoadingStateWidget),
        matching: find.byType(Transform),
      );
      expect(transformCount, findsNothing);
    });

    testWidgets('shows animated pulse when reduced-motion is disabled',
        (tester) async {
      await tester.pumpWidget(buildWithMotionSetting(disableAnimations: false));
      await tester.pump();

      // In normal mode, AnimatedBuilder + Transform.scale is used for pulse
      final transformCount = find.descendant(
        of: find.byType(LoadingStateWidget),
        matching: find.byType(Transform),
      );
      expect(transformCount, findsOneWidget);
    });
  });
}
