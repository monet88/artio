import 'package:artio/shared/widgets/error_illustration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ErrorIllustration', () {
    Widget buildWidget({
      IconData icon = Icons.wifi_off_rounded,
      Color color = Colors.orange,
      bool isDark = true,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: ErrorIllustration(
            icon: icon,
            color: color,
            isDark: isDark,
          ),
        ),
      );
    }

    testWidgets('renders the provided icon', (tester) async {
      await tester.pumpWidget(buildWidget(icon: Icons.cloud_off_rounded));

      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
    });

    testWidgets('renders without errors in dark mode', (tester) async {
      await tester.pumpWidget(buildWidget(isDark: true));

      expect(find.byType(ErrorIllustration), findsOneWidget);
    });

    testWidgets('renders without errors in light mode', (tester) async {
      await tester.pumpWidget(buildWidget(isDark: false));

      expect(find.byType(ErrorIllustration), findsOneWidget);
    });
  });
}
