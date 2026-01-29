import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:artio/features/auth/presentation/screens/login_screen.dart';

/// Creates a test app widget for integration testing
///
/// This wraps the app in necessary providers without requiring
/// actual Supabase connection for UI flow tests.
Widget createTestApp({Widget? home}) {
  return ProviderScope(
    child: MaterialApp(
      title: 'Artio Test',
      theme: ThemeData.light(useMaterial3: true),
      home: home ?? const LoginScreen(),
    ),
  );
}

/// Creates a test app with authenticated state
///
/// Use this when testing flows that require authenticated user.
Widget createAuthenticatedTestApp({required Widget home}) {
  return ProviderScope(
    child: MaterialApp(
      title: 'Artio Test',
      theme: ThemeData.light(useMaterial3: true),
      home: home,
    ),
  );
}
