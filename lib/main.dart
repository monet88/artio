import 'dart:io';

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

  await SentryConfig.init();
  await MobileAds.instance.initialize();

  // Initialize RevenueCat SDK (skip if keys not configured or running on web)
  if (!kIsWeb) {
    final rcKey = Platform.isIOS
        ? EnvConfig.revenuecatAppleKey
        : EnvConfig.revenuecatGoogleKey;
    if (rcKey.isNotEmpty) {
      if (kDebugMode) {
        await Purchases.setLogLevel(LogLevel.debug);
      }
      await Purchases.configure(PurchasesConfiguration(rcKey));
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
