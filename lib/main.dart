import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:artio/core/config/env_config.dart';
import 'package:artio/core/config/sentry_config.dart';
import 'package:artio/routing/app_router.dart';
import 'package:artio/theme/app_theme.dart';
import 'package:artio/theme/theme_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Requests App Tracking Transparency consent on iOS 14+ before AdMob init.
///
/// Apple requires ATT request before any tracking SDK (including AdMob).
/// Skipped on Android, Web, and Desktop — no-op on those platforms.
/// AdMob always initialises regardless of ATT result; denying just limits
/// ad personalisation (non-personalised ads still serve).
Future<void> _requestAttIfNeeded() async {
  if (kIsWeb) return;
  if (!Platform.isIOS) return;

  try {
    // Small delay to ensure the Flutter engine is ready to show system dialogs.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    // Only request if not yet determined (avoids showing dialog twice).
    if (status == TrackingStatus.notDetermined) {
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
  } on Object catch (e) {
    debugPrint('ATT request failed (non-blocking): $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const env = String.fromEnvironment('ENV', defaultValue: 'development');
  await EnvConfig.load(env);

  try {
    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      anonKey: EnvConfig.supabaseAnonKey,
    );
  } on Exception catch (e) {
    runApp(InitErrorApp(error: e.toString()));
    return;
  }

  try {
    await SentryConfig.init();
  } on Object catch (e) {
    debugPrint('Sentry init failed (non-blocking): $e');
  }

  try {
    // iOS 14+: Request App Tracking Transparency BEFORE AdMob init.
    // Apple requires ATT consent before any SDK that may track users.
    await _requestAttIfNeeded();
    await MobileAds.instance.initialize();
  } on Object catch (e) {
    debugPrint('MobileAds init failed (non-blocking): $e');
  }

  // Initialize RevenueCat SDK (skip if keys not configured or running on web)
  if (!kIsWeb) {
    final rcKey = Platform.isIOS
        ? EnvConfig.revenuecatAppleKey
        : EnvConfig.revenuecatGoogleKey;
    if (rcKey.isNotEmpty) {
      try {
        if (kDebugMode) {
          await Purchases.setLogLevel(LogLevel.debug);
        }
        await Purchases.configure(PurchasesConfiguration(rcKey));
      } on Object catch (e) {
        debugPrint('RevenueCat init failed (non-blocking): $e');
      }
    }
  }

  runApp(const ProviderScope(child: ArtioApp()));
}

class InitErrorApp extends StatelessWidget {
  const InitErrorApp({required this.error, super.key});
  final String error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Failed to initialize app',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (kDebugMode) Text(error, textAlign: TextAlign.center),
                if (!kDebugMode)
                  const Text(
                    'Please check your internet connection and try again.',
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ArtioApp extends ConsumerWidget {
  const ArtioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeModeAsync = ref.watch(themeModeNotifierProvider);

    return MaterialApp.router(
      title: 'Artio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeModeAsync.valueOrNull ?? ThemeMode.system,
      routerConfig: router,
    );
  }
}
