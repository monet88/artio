import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:artio/shared/widgets/main_shell.dart';

void main() {
  group('MainShell', () {
    Widget buildWidget({required Widget child}) {
      return MaterialApp(
        home: MainShell(child: child),
      );
    }

    testWidgets('renders bottom navigation bar', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          child: Container(),
        ),
      );

      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('all 4 navigation destinations are present', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          child: Container(),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Create'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('renders Home icon', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          child: Container(),
        ),
      );

      expect(find.byIcon(Icons.home), findsOneWidget);
    });

    testWidgets('renders Create icon', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          child: Container(),
        ),
      );

      expect(find.byIcon(Icons.add_circle), findsOneWidget);
    });
  });
}
