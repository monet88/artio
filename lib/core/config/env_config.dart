import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration manager.
/// Loads environment-specific .env files based on build-time ENV flag.
class EnvConfig {
  static String? _environment;

  /// Current environment name (development, staging, production)
  static String get environment => _environment ?? 'development';

  /// Whether running in production mode
  static bool get isProduction => environment == 'production';

  /// Whether running in development mode
  static bool get isDevelopment => environment == 'development';

  /// Load environment configuration.
  /// Uses --dart-define=ENV=xxx to determine which .env file to load.
  static Future<void> load(String env) async {
    _environment = env;
    final fileName = '.env.$env';
    await dotenv.load(fileName: fileName);
    _validateRequiredEnvVars();
  }

  static void _validateRequiredEnvVars() {
    if (supabaseUrl.isEmpty) {
      throw Exception('Missing SUPABASE_URL in .env file');
    }
    if (supabaseAnonKey.isEmpty) {
      throw Exception('Missing SUPABASE_ANON_KEY in .env file');
    }
  }

  // Supabase
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // Sentry (production only)
  static String get sentryDsn => dotenv.env['SENTRY_DSN'] ?? '';

  // AI APIs
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static String get kieApiKey => dotenv.env['KIE_API_KEY'] ?? '';

  // RevenueCat
  static String get revenuecatAppleKey =>
      dotenv.env['REVENUECAT_APPLE_KEY'] ?? '';
  static String get revenuecatGoogleKey =>
      dotenv.env['REVENUECAT_GOOGLE_KEY'] ?? '';
  static String get revenuecatWebKey => dotenv.env['REVENUECAT_WEB_KEY'] ?? '';

  // Stripe
  static String get stripePublishableKey =>
      dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
}
