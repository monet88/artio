import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:artio/features/auth/presentation/screens/login_screen.dart';
import 'package:artio/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:artio/features/auth/presentation/state/auth_state.dart';

import '../../../../core/helpers/pump_app.dart';

/// Mock AuthViewModel that returns unauthenticated state without Supabase
class MockAuthViewModel extends AuthViewModel {
  @override
  AuthState build() => const AuthState.unauthenticated();
}

void main() {
  final overrides = <Override>[
    authViewModelProvider.overrideWith(() => MockAuthViewModel()),
  ];

  group('LoginScreen', () {
    testWidgets('renders email and password fields', (tester) async {
      await tester.pumpApp(const LoginScreen(), overrides: overrides);

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('renders Welcome to Artio header', (tester) async {
      await tester.pumpApp(const LoginScreen(), overrides: overrides);

      expect(find.text('Welcome to Artio'), findsOneWidget);
      expect(find.text('Art Made Simple'), findsOneWidget);
    });

    testWidgets('renders Sign In button', (tester) async {
      await tester.pumpApp(const LoginScreen(), overrides: overrides);

      // Auth screens use _GradientButton wrapping InkWell, not FilledButton
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.byType(InkWell), findsWidgets);
    });

    testWidgets('shows error on empty email submission', (tester) async {
      await tester.pumpApp(const LoginScreen(), overrides: overrides);

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('shows error on invalid email format', (tester) async {
      await tester.pumpApp(const LoginScreen(), overrides: overrides);

      await tester.enterText(
        find.byType(TextFormField).first,
        'invalidemail',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('shows error on empty password', (tester) async {
      await tester.pumpApp(const LoginScreen(), overrides: overrides);

      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('shows error on short password', (tester) async {
      await tester.pumpApp(const LoginScreen(), overrides: overrides);

      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        '12345',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('renders Forgot Password link', (tester) async {
      await tester.pumpApp(const LoginScreen(), overrides: overrides);

      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('renders Sign Up navigation link', (tester) async {
      await tester.pumpApp(const LoginScreen(), overrides: overrides);

      expect(find.text("Don't have an account?"), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('toggles password visibility', (tester) async {
      await tester.pumpApp(const LoginScreen(), overrides: overrides);

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });
  });
}
