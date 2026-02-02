import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/env_config.dart';
import 'routing/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment config based on --dart-define=ENV=xxx
  const env = String.fromEnvironment('ENV', defaultValue: 'development');
  await EnvConfig.load(env);

  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
  );

  runApp(const ProviderScope(child: ArtioApp()));
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
