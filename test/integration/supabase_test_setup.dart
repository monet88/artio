import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Integration test setup for real Supabase instance.
///
/// Uses SupabaseClient directly (no Supabase.initialize) to avoid
/// SharedPreferences plugin dependency in flutter test environment.
///
/// Configuration priority:
/// 1. Environment variables (for CI/CD)
/// 2. `.env.test` file (for local development)
///
/// Required variables:
/// - SUPABASE_URL
/// - SUPABASE_ANON_KEY
/// - TEST_USER_EMAIL (for authenticated tests)
/// - TEST_USER_PASSWORD (for authenticated tests)
class SupabaseTestSetup {
  static late SupabaseClient client;
  static bool _initialized = false;
  static bool _dotenvLoaded = false;

  static Future<void> init() async {
    if (_initialized) return;

    await _loadDotenv();

    final url = _getEnv('SUPABASE_URL');
    final anonKey = _getEnv('SUPABASE_ANON_KEY');

    if (url == null || anonKey == null) {
      throw StateError(
        'Missing SUPABASE_URL or SUPABASE_ANON_KEY. '
        'Set via environment variables or .env.test file.',
      );
    }

    // Use SupabaseClient directly to avoid SharedPreferences dependency
    client = SupabaseClient(url, anonKey);
    _initialized = true;
  }

  static Future<void> signInTestUser() async {
    final email = _getEnv('TEST_USER_EMAIL');
    final password = _getEnv('TEST_USER_PASSWORD');

    if (email == null || password == null) {
      throw StateError(
        'Missing TEST_USER_EMAIL or TEST_USER_PASSWORD. '
        'Set via environment variables or .env.test file.',
      );
    }

    await client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  static Future<void> cleanup() async {
    await signOut();
  }

  /// Load .env.test for local dev (ignore if missing for CI).
  static Future<void> _loadDotenv() async {
    if (_dotenvLoaded) return;
    try {
      final file = File('.env.test');
      if (file.existsSync()) {
        dotenv.testLoad(fileInput: file.readAsStringSync());
        _dotenvLoaded = true;
      }
    } catch (_) {
      // .env.test not found, will use Platform.environment
    }
  }

  /// Get env var from Platform.environment first, fallback to dotenv.
  static String? _getEnv(String key) {
    return Platform.environment[key] ??
        (_dotenvLoaded ? dotenv.env[key] : null);
  }
}
