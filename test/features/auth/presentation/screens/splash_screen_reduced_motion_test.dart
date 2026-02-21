import 'package:artio/features/auth/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SplashScreen reduced-motion', () {
    Widget buildWithMotionSetting({required bool disableAnimations}) {
      return MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: const MaterialApp(home: Scaffold(body: SplashScreen())),
      );
    }

    /// Find the FadeTransition that is an ancestor of the 'Artio' text
    Finder findLogoFade() => find.ancestor(
      of: find.text('Artio'),
      matching: find.byType(FadeTransition),
    );

    testWidgets(
      'logo and tagline visible immediately when reduced-motion is enabled',
      (tester) async {
        await tester.pumpWidget(
          buildWithMotionSetting(disableAnimations: true),
        );
        await tester.pump();

        expect(find.text('Artio'), findsOneWidget);
        expect(find.text('Art Made Simple'), findsOneWidget);

        final logoFade = tester.widget<FadeTransition>(findLogoFade().first);
        expect(logoFade.opacity.value, 1.0);
      },
    );

    testWidgets('logo starts hidden when reduced-motion is disabled', (
      tester,
    ) async {
      await tester.pumpWidget(buildWithMotionSetting(disableAnimations: false));
      // Single pump — check before animation progresses
      await tester.pump();

      final logoFade = tester.widget<FadeTransition>(findLogoFade().first);
      expect(logoFade.opacity.value, 0.0);

      // Pump past delayed timers (200ms + 400ms) to prevent "pending timer" error
      // Cannot use pumpAndSettle because _pulseController.repeat() never settles
      await tester.pump(const Duration(seconds: 1));
    });
  });
}
