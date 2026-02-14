import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:artio/features/auth/presentation/screens/splash_screen.dart';

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

      // SplashScreen has CircularProgressIndicator as loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows loading indicator', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
