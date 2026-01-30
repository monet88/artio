import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Integration test setup for real Supabase instance.
///
/// Requires `.env.test` file with:
/// - SUPABASE_URL
/// - SUPABASE_ANON_KEY
/// - TEST_USER_EMAIL
/// - TEST_USER_PASSWORD
class SupabaseTestSetup {
  static late SupabaseClient client;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    await dotenv.load(fileName: '.env.test');

    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (url == null || anonKey == null) {
      throw StateError('Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env.test');
    }

    await Supabase.initialize(url: url, anonKey: anonKey);
    client = Supabase.instance.client;
    _initialized = true;
  }

  static Future<void> signInTestUser() async {
    final email = dotenv.env['TEST_USER_EMAIL'];
    final password = dotenv.env['TEST_USER_PASSWORD'];

    if (email == null || password == null) {
      throw StateError('Missing TEST_USER_EMAIL or TEST_USER_PASSWORD in .env.test');
    }

    await client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  static Future<void> cleanup() async {
    await signOut();
  }
}
