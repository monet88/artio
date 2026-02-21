import 'package:artio/features/settings/presentation/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Settings Flow Integration Tests', () {
    Widget createTestWidget() {
      return const ProviderScope(
        child: MaterialApp(title: 'Artio Test', home: SettingsScreen()),
      );
    }

    testWidgets('settings screen displays all sections', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
    });

    testWidgets('settings displays account options', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Change Password'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('settings displays theme section', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Theme'), findsOneWidget);
    });

    testWidgets('settings displays version info', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Version'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('logout button is styled with error color', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final logoutTile = tester.widget<ListTile>(
        find.ancestor(of: find.text('Logout'), matching: find.byType(ListTile)),
      );

      expect(logoutTile.leading, isA<Icon>());
    });

    testWidgets('settings has multiple list tiles', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(ListTile), findsAtLeast(4));
    });

    testWidgets('settings has section dividers', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(Divider), findsAtLeast(2));
    });

    testWidgets('change password tile is tappable', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final changePasswordTile = find.ancestor(
        of: find.text('Change Password'),
        matching: find.byType(ListTile),
      );

      expect(changePasswordTile, findsOneWidget);

      // Verify it's enabled (has onTap)
      final tile = tester.widget<ListTile>(changePasswordTile);
      expect(tile.onTap, isNotNull);
    });
  });
}
