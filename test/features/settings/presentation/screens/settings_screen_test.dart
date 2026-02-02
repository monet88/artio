import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:artio/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:artio/features/auth/presentation/state/auth_state.dart';
import 'package:artio/features/settings/data/notifications_provider.dart';
import 'package:artio/features/settings/presentation/settings_screen.dart';
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
    testWidgets('renders app bar with Settings title', (tester) async {
      await tester.pumpApp(
        const SettingsScreen(),
        overrides: [
          authViewModelProvider.overrideWith(() => _FakeAuthViewModel()),
          notificationsNotifierProvider.overrideWith(() => _FakeNotificationsNotifier()),
        ],
      );
      await tester.pump();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('renders Scaffold', (tester) async {
      await tester.pumpApp(
        const SettingsScreen(),
        overrides: [
          authViewModelProvider.overrideWith(() => _FakeAuthViewModel()),
          notificationsNotifierProvider.overrideWith(() => _FakeNotificationsNotifier()),
        ],
      );
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('displays user email when authenticated', (tester) async {
      await tester.pumpApp(
        const SettingsScreen(),
        overrides: [
          authViewModelProvider.overrideWith(() => _FakeAuthViewModel()),
          notificationsNotifierProvider.overrideWith(() => _FakeNotificationsNotifier()),
        ],
      );
      await tester.pump();

      expect(find.textContaining('test@example.com'), findsOneWidget);
    });

    testWidgets('renders Account section with expected items', (tester) async {
      await tester.pumpApp(
        const SettingsScreen(),
        overrides: [
          authViewModelProvider.overrideWith(() => _FakeAuthViewModel()),
          notificationsNotifierProvider.overrideWith(() => _FakeNotificationsNotifier()),
        ],
      );
      await tester.pump();

      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Change Password'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('renders Appearance section', (tester) async {
      await tester.pumpApp(
        const SettingsScreen(),
        overrides: [
          authViewModelProvider.overrideWith(() => _FakeAuthViewModel()),
          notificationsNotifierProvider.overrideWith(() => _FakeNotificationsNotifier()),
        ],
      );
      await tester.pump();

      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
    });

    testWidgets('renders About section with version', (tester) async {
      await tester.pumpApp(
        const SettingsScreen(),
        overrides: [
          authViewModelProvider.overrideWith(() => _FakeAuthViewModel()),
          notificationsNotifierProvider.overrideWith(() => _FakeNotificationsNotifier()),
        ],
      );
      // Wait for widget to build and PackageInfo to load
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
}
