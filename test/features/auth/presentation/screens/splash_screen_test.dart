import 'package:artio/features/auth/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SplashScreen', () {
    Widget buildWidget() {
      return const MaterialApp(
        home: Scaffold(
          body: SplashScreen(),
        ),
      );
    }

    testWidgets('renders app logo/name', (tester) async {
      await tester.pumpWidget(buildWidget());
      // Pump past initial animation delays (200ms settle + 400ms logo)
      await tester.pump(const Duration(milliseconds: 700));

      // Branded logo text 'Artio' displayed via GradientText
      expect(find.text('Artio'), findsOneWidget);
    });

    testWidgets('shows loading indicator', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows tagline', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.text('Art Made Simple'), findsOneWidget);
    });
  });
}
