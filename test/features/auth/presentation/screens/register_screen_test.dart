import 'package:artio/features/auth/presentation/screens/register_screen.dart';
import 'package:artio/features/auth/presentation/state/auth_state.dart';
import 'package:artio/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../core/helpers/pump_app.dart';

/// Mock AuthViewModel that returns unauthenticated state without Supabase
class MockAuthViewModel extends AuthViewModel {
  @override
  AuthState build() => const AuthState.unauthenticated();
}

void main() {
  final overrides = <Override>[
    authViewModelProvider.overrideWith(MockAuthViewModel.new),
  ];

  group('RegisterScreen', () {
    testWidgets('renders email, password, and confirm password fields',
        (tester) async {
      await tester.pumpApp(const RegisterScreen(), overrides: overrides);

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(3));
    });

    testWidgets('renders Create Account header', (tester) async {
      await tester.pumpApp(const RegisterScreen(), overrides: overrides);

      // "Create Account" appears twice: GradientText header + _GradientButton text
      expect(find.text('Create Account'), findsAtLeastNWidgets(1));
      expect(find.text('Start creating amazing art'), findsOneWidget);
    });

    testWidgets('renders Create Account button', (tester) async {
      await tester.pumpApp(const RegisterScreen(), overrides: overrides);

      // GradientText header + _GradientButton label
      expect(find.text('Create Account'), findsNWidgets(2));
      // Auth screens use _GradientButton not FilledButton
      expect(find.byType(InkWell), findsWidgets);
    });

    testWidgets('shows error on empty email', (tester) async {
      await tester.pumpApp(const RegisterScreen(), overrides: overrides);

      // Find and tap the Create Account button by text
      final buttons = find.text('Create Account');
      // Tap the button instance (last one is the button, first is the header)
      await tester.tap(buttons.last);
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('shows error on invalid email format', (tester) async {
      await tester.pumpApp(const RegisterScreen(), overrides: overrides);

      await tester.enterText(
        find.byType(TextFormField).first,
        'invalidemail',
      );
      await tester.tap(find.text('Create Account').last);
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('shows error on empty password', (tester) async {
      await tester.pumpApp(const RegisterScreen(), overrides: overrides);

      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.tap(find.text('Create Account').last);
      await tester.pumpAndSettle();

      expect(find.text('Please enter a password'), findsOneWidget);
    });

    testWidgets('shows error on short password', (tester) async {
      await tester.pumpApp(const RegisterScreen(), overrides: overrides);

      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        '12345',
      );
      await tester.tap(find.text('Create Account').last);
      await tester.pumpAndSettle();

      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('shows error on password mismatch', (tester) async {
      await tester.pumpApp(const RegisterScreen(), overrides: overrides);

      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'password123',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'differentpassword',
      );
      await tester.tap(find.text('Create Account').last);
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('shows error on empty confirm password', (tester) async {
      await tester.pumpApp(const RegisterScreen(), overrides: overrides);

      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'password123',
      );
      await tester.tap(find.text('Create Account').last);
      await tester.pumpAndSettle();

      expect(find.text('Please confirm your password'), findsOneWidget);
    });

    testWidgets('renders Sign In navigation link', (tester) async {
      await tester.pumpApp(const RegisterScreen(), overrides: overrides);

      expect(find.text('Already have an account?'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('renders back button', (tester) async {
      await tester.pumpApp(const RegisterScreen(), overrides: overrides);

      // Back button icon changed to rounded variant
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });

    testWidgets('toggles password visibility', (tester) async {
      await tester.pumpApp(const RegisterScreen(), overrides: overrides);

      // Both password fields have visibility toggles
      expect(find.byIcon(Icons.visibility_outlined), findsNWidgets(2));

      await tester.tap(find.byIcon(Icons.visibility_outlined).first);
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });
  });
}
