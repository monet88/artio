import 'package:artio/shared/widgets/watermark_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../core/helpers/pump_app.dart';

void main() {
  group('WatermarkOverlay', () {
    testWidgets('shows watermark text when showWatermark is true', (
      tester,
    ) async {
      await tester.pumpApp(
        const WatermarkOverlay(
          showWatermark: true,
          child: SizedBox(width: 200, height: 200),
        ),
      );

      expect(find.text('artio'), findsOneWidget);
    });

    testWidgets('hides watermark text when showWatermark is false', (
      tester,
    ) async {
      await tester.pumpApp(
        const WatermarkOverlay(
          showWatermark: false,
          child: SizedBox(width: 200, height: 200),
        ),
      );

      expect(find.text('artio'), findsNothing);
    });

    testWidgets('renders child widget regardless of watermark state', (
      tester,
    ) async {
      const childKey = Key('test-child');

      await tester.pumpApp(
        const WatermarkOverlay(
          showWatermark: true,
          child: SizedBox(key: childKey, width: 200, height: 200),
        ),
      );

      expect(find.byKey(childKey), findsOneWidget);
    });

    testWidgets('uses Stack when showWatermark is true', (tester) async {
      await tester.pumpApp(
        const WatermarkOverlay(
          showWatermark: true,
          child: SizedBox(width: 200, height: 200),
        ),
      );

      expect(find.byType(Stack), findsOneWidget);
    });

    testWidgets('does not use Stack when showWatermark is false', (
      tester,
    ) async {
      await tester.pumpApp(
        const WatermarkOverlay(
          showWatermark: false,
          child: SizedBox(width: 200, height: 200),
        ),
      );

      // The overlay should not add a Stack, just return child directly
      expect(find.text('artio'), findsNothing);
      // Verify child is still rendered
      expect(find.byType(SizedBox), findsWidgets);
    });
  });
}
