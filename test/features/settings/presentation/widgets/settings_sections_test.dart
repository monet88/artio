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
    bool isPremium = false,
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
              isPremium: isPremium,
              onResetPassword: () {},
              onSignOut: () {},
              onRestore: () {},
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

    testWidgets('shows Upgrade Plan tile when not premium', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Upgrade Plan'), findsOneWidget);
      expect(find.text('Manage Plan'), findsNothing);
    });

    testWidgets('shows Manage Plan tile when premium', (tester) async {
      await tester.pumpWidget(buildWidget(isPremium: true));
      await tester.pumpAndSettle();

      expect(find.text('Manage Plan'), findsOneWidget);
      expect(find.text('Upgrade Plan'), findsNothing);
    });

    testWidgets('hides plan tile when not logged in', (tester) async {
      await tester.pumpWidget(buildWidget(isLoggedIn: false));
      await tester.pumpAndSettle();

      expect(find.text('Upgrade Plan'), findsNothing);
      expect(find.text('Manage Plan'), findsNothing);
    });

    testWidgets('shows Restore Purchases tile when logged in', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Restore Purchases'), findsOneWidget);
    });

    testWidgets('hides Restore Purchases tile when not logged in',
        (tester) async {
      await tester.pumpWidget(buildWidget(isLoggedIn: false));
      await tester.pumpAndSettle();

      expect(find.text('Restore Purchases'), findsNothing);
    });

    // Note: the mobile-enabled path (Platform.isAndroid || Platform.isIOS == true →
    // onRestore is invoked on tap) cannot be covered here because dart:io's Platform
    // class reflects the real test-runner OS (macOS) and cannot be mocked in unit
    // tests without refactoring to use package:platform (LocalPlatform/FakePlatform).
    // TODO(test): add Restore Purchases coverage in integration_test/settings_flow_test.dart.
    testWidgets(
        'Restore Purchases tile is disabled on non-mobile (desktop test host)',
        (tester) async {
      // RevenueCat only supports Android/iOS. On the macOS test host,
      // Platform.isAndroid and Platform.isIOS are both false → tile is
      // disabled (onTap = null) so tapping it must NOT invoke the callback.
      var called = false;
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: SettingsSections(
                  email: 'test@example.com',
                  isDark: false,
                  version: '1.0.0',
                  isLoggedIn: true,
                  isPremium: false,
                  onResetPassword: () {},
                  onSignOut: () {},
                  onRestore: () {
                    called = true;
                  },
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Restore Purchases'), warnIfMissed: false);
      expect(called, isFalse);
    });
  });
}
