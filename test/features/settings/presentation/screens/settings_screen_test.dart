import 'package:flutter_test/flutter_test.dart';

import 'package:artio/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:artio/features/auth/presentation/state/auth_state.dart';
import 'package:artio/features/settings/ui/settings_screen.dart';
import '../../../../core/fixtures/fixtures.dart';
import '../../../../core/helpers/pump_app.dart';

void main() {
  group('SettingsScreen', () {
    testWidgets('renders app bar with Settings title', (tester) async {
      await tester.pumpApp(
        const SettingsScreen(),
        overrides: [authViewModelProvider.overrideWith(() => _FakeAuthViewModel())],
      );
      await tester.pump();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('renders Scaffold', (tester) async {
      await tester.pumpApp(
        const SettingsScreen(),
        overrides: [authViewModelProvider.overrideWith(() => _FakeAuthViewModel())],
      );
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('displays user email when authenticated', (tester) async {
      await tester.pumpApp(
        const SettingsScreen(),
        overrides: [authViewModelProvider.overrideWith(() => _FakeAuthViewModel())],
      );
      await tester.pump();

      expect(find.textContaining('test@example.com'), findsOneWidget);
    });

    testWidgets('renders Account section with expected items', (tester) async {
      await tester.pumpApp(
        const SettingsScreen(),
        overrides: [authViewModelProvider.overrideWith(() => _FakeAuthViewModel())],
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
        overrides: [authViewModelProvider.overrideWith(() => _FakeAuthViewModel())],
      );
      await tester.pump();

      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
    });

    testWidgets('renders About section with version', (tester) async {
      await tester.pumpApp(
        const SettingsScreen(),
        overrides: [authViewModelProvider.overrideWith(() => _FakeAuthViewModel())],
      );
      await tester.pump();

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
