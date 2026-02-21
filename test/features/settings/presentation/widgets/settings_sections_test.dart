import 'package:artio/features/settings/presentation/widgets/settings_sections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildWidget({
    String email = 'test@example.com',
    bool isDark = false,
    String? version = '1.0.0',
    bool isLoggedIn = true,
  }) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SettingsSections(
              email: email,
              isDark: isDark,
              version: version,
              isLoggedIn: isLoggedIn,
              onResetPassword: () {},
              onSignOut: () {},
            ),
          ),
        ),
      ),
    );
  }

  group('SettingsSections', () {
    testWidgets('shows Account section when logged in', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Account'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('Change Password'), findsOneWidget);
    });

    testWidgets('hides Account section when not logged in', (tester) async {
      await tester.pumpWidget(buildWidget(isLoggedIn: false));
      await tester.pumpAndSettle();

      expect(find.text('Account'), findsNothing);
      expect(find.text('Change Password'), findsNothing);
    });

    testWidgets('shows Appearance section with Theme label', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
    });

    testWidgets('shows Notifications section with toggle', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Push Notifications'), findsOneWidget);
    });

    testWidgets('shows About section with version', (tester) async {
      await tester.pumpWidget(buildWidget(version: '2.0.1'));
      await tester.pumpAndSettle();

      expect(find.text('About'), findsOneWidget);
      expect(find.text('2.0.1'), findsOneWidget);
    });

    testWidgets('shows Loading... when version is null', (tester) async {
      await tester.pumpWidget(buildWidget(version: null));
      await tester.pumpAndSettle();

      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('shows Logout button when logged in', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('hides Logout button when not logged in', (tester) async {
      await tester.pumpWidget(buildWidget(isLoggedIn: false));
      await tester.pumpAndSettle();

      expect(find.text('Logout'), findsNothing);
    });
  });
}
