import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:artio/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:artio/features/auth/presentation/state/auth_state.dart';
import 'package:artio/features/settings/data/notifications_provider.dart';
import 'package:artio/features/settings/presentation/settings_screen.dart';
import 'package:artio/theme/theme_provider.dart';
import '../../../../core/fixtures/fixtures.dart';
import '../../../../core/helpers/pump_app.dart';

void main() {
  setUpAll(() {
    PackageInfo.setMockInitialValues(
      appName: 'Test App',
      packageName: 'com.test.app',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  group('SettingsScreen', () {
    final overrides = [
      authViewModelProvider.overrideWith(() => _FakeAuthViewModel()),
      notificationsNotifierProvider
          .overrideWith(() => _FakeNotificationsNotifier()),
      themeModeNotifierProvider.overrideWith(() => _FakeThemeModeNotifier()),
    ];

    testWidgets('renders app bar with Settings title', (tester) async {
      await tester.pumpApp(
        const SettingsScreen(),
        overrides: overrides,
      );
      await tester.pump();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('renders Scaffold', (tester) async {
      await tester.pumpApp(
        const SettingsScreen(),
        overrides: overrides,
      );
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('displays user email when authenticated', (tester) async {
      await tester.pumpApp(
        const SettingsScreen(),
        overrides: overrides,
      );
      await tester.pump();

      // Email appears in UserProfileCard AND Account section Email tile
      // Use findsAtLeastNWidgets since it may appear multiple times
      expect(find.text('test@example.com'), findsAtLeastNWidgets(1));
    });

    testWidgets('renders Account section with expected items', (tester) async {
      await tester.pumpApp(
        const SettingsScreen(),
        overrides: overrides,
      );
      await tester.pump();

      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Change Password'), findsOneWidget);
    });

    testWidgets('renders Logout button (scrolled)', (tester) async {
      await tester.pumpApp(
        const SettingsScreen(),
        overrides: overrides,
      );
      await tester.pumpAndSettle();

      // Logout button is at the bottom, may need to scroll
      await tester.scrollUntilVisible(
        find.text('Logout'),
        200.0,
      );

      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('renders Appearance section', (tester) async {
      await tester.pumpApp(
        const SettingsScreen(),
        overrides: overrides,
      );
      await tester.pump();

      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
    });

    testWidgets('renders About section with version', (tester) async {
      await tester.pumpApp(
        const SettingsScreen(),
        overrides: overrides,
      );
      await tester.pumpAndSettle();

      // Scroll to find the Version text
      await tester.scrollUntilVisible(
        find.text('Version'),
        200.0,
      );

      expect(find.text('About'), findsOneWidget);
      expect(find.text('Version'), findsOneWidget);
    });
  });
}

class _FakeAuthViewModel extends AuthViewModel {
  @override
  AuthState build() {
    return AuthState.authenticated(UserFixtures.authenticated());
  }
}

class _FakeNotificationsNotifier extends NotificationsNotifier {
  @override
  bool build() {
    return true;
  }

  @override
  Future<void> init() async {}
}

class _FakeThemeModeNotifier extends ThemeModeNotifier {
  @override
  Future<ThemeMode> build() async {
    return ThemeMode.system;
  }
}
