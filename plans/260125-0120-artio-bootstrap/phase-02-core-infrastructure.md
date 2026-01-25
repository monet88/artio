---
title: "Phase 2: Core Infrastructure"
status: completed
effort: 6h
---

# Phase 2: Core Infrastructure

## Context Links

- [go_router docs](https://pub.dev/packages/go_router)
- [flex_color_scheme playground](https://rydmike.com/flexcolorscheme/themesplayground-latest/)
- [Q Agency: go_router + Riverpod auth](https://q.agency/blog/handling-authentication-state-with-go_router-and-riverpod/)

## Overview

Set up routing with auth guards, theming with dark mode, exception handling, and Dio HTTP client.

## Key Insights

- **AuthNotifier must implement Listenable** for go_router's refreshListenable
- go_router's `redirect` callback determines navigation based on auth state
- flex_color_scheme provides 50+ predefined themes with Material 3 support
- Custom colors can be defined for brand identity

## Requirements

### Functional
- Router with auth-based redirects
- Light/dark theme with custom brand colors
- Global exception handling
- Configured Dio with interceptors

### Non-Functional
- Type-safe routes via go_router_builder
- Theme persisted in SharedPreferences
- Centralized error logging

## Architecture

### Router Flow
```
App Start → checkIfAuthenticated() →
  ├─ Authenticated → HomePage
  └─ Unauthenticated → LoginPage

Route Access →
  ├─ Protected route + not logged in → LoginPage
  └─ Login route + logged in → HomePage
```

### Theme System
```
ThemeMode (system/light/dark) ← stored in SharedPreferences
     ↓
FlexColorScheme.light/dark()
     ↓
MaterialApp.theme / darkTheme
```

## Related Code Files

### Create
- `lib/core/router/app_router.dart` - GoRouter provider
- `lib/core/router/app_routes.dart` - Route definitions
- `lib/core/router/route_names.dart` - Route name constants
- `lib/core/theme/app_theme.dart` - Theme configuration
- `lib/core/theme/theme_provider.dart` - Theme state management
- `lib/core/theme/app_colors.dart` - Brand color definitions
- `lib/core/exceptions/app_exception.dart` - Exception classes
- `lib/core/exceptions/exception_handler.dart` - Global handler
- `lib/core/utils/dio_client.dart` - Configured Dio instance
- `lib/core/utils/logger_service.dart` - Logging wrapper

## Implementation Steps

### 1. Route Names Constants
```dart
// lib/core/router/route_names.dart
abstract class RouteNames {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const create = '/create';
  static const gallery = '/gallery';
  static const settings = '/settings';
  static const subscription = '/subscription';
  static const template = '/template/:id';
}
```

### 2. App Router with Auth Guards
```dart
// lib/core/router/app_router.dart
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../features/auth/domain/auth_notifier.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authNotifier = ref.watch(authNotifierProvider.notifier);

  return GoRouter(
    debugLogDiagnostics: kDebugMode,
    initialLocation: RouteNames.splash,
    refreshListenable: authNotifier,
    redirect: (context, state) => authNotifier.redirect(
      currentPath: state.matchedLocation,
    ),
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterPage(),
      ),
      // Shell route for authenticated pages with bottom nav
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.home,
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: RouteNames.create,
            builder: (context, state) => const CreatePage(),
          ),
          GoRoute(
            path: RouteNames.gallery,
            builder: (context, state) => const GalleryPage(),
          ),
          GoRoute(
            path: RouteNames.settings,
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.template,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TemplateDetailPage(templateId: id);
        },
      ),
    ],
    errorBuilder: (context, state) => ErrorPage(error: state.error),
  );
}
```

### 3. Brand Colors
```dart
// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

abstract class AppColors {
  // Brand colors
  static const primaryCta = Color(0xFF3DD598);  // Mint green
  static const accent = Color(0xFF9B87F5);      // Purple

  // Light theme
  static const lightBackground = Color(0xFFFFFFFF);
  static const lightCard = Colors.white;

  // Dark theme
  static const darkBackground = Color(0xFF0D1025);
  static const darkCard = Color(0xFF1E2342);

  // Semantic
  static const error = Color(0xFFE53935);
  static const success = Color(0xFF43A047);
  static const warning = Color(0xFFFFA726);
}
```

### 4. Theme Configuration
```dart
// lib/core/theme/app_theme.dart
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class AppTheme {
  static const _fontFamily = 'Inter';
  static const _borderRadius = 14.0;

  static ThemeData get light => FlexThemeData.light(
    colors: const FlexSchemeColor(
      primary: AppColors.primaryCta,
      secondary: AppColors.accent,
      tertiary: AppColors.accent,
    ),
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 7,
    subThemesData: const FlexSubThemesData(
      defaultRadius: _borderRadius,
      cardRadius: _borderRadius,
      inputDecoratorRadius: _borderRadius,
      buttonRadius: _borderRadius,
    ),
    fontFamily: _fontFamily,
    useMaterial3: true,
  );

  static ThemeData get dark => FlexThemeData.dark(
    colors: const FlexSchemeColor(
      primary: AppColors.primaryCta,
      secondary: AppColors.accent,
      tertiary: AppColors.accent,
    ),
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 13,
    darkIsTrueBlack: false,
    subThemesData: const FlexSubThemesData(
      defaultRadius: _borderRadius,
      cardRadius: _borderRadius,
      inputDecoratorRadius: _borderRadius,
      buttonRadius: _borderRadius,
    ),
    fontFamily: _fontFamily,
    useMaterial3: true,
  ).copyWith(
    scaffoldBackgroundColor: AppColors.darkBackground,
    cardColor: AppColors.darkCard,
  );
}
```

### 5. Theme Provider
```dart
// lib/core/theme/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_provider.g.dart';

@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    _loadFromPrefs();
    return ThemeMode.system;
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    if (value != null) {
      state = ThemeMode.values.firstWhere(
        (e) => e.name == value,
        orElse: () => ThemeMode.system,
      );
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }
}
```

### 6. Exception Classes
```dart
// lib/core/exceptions/app_exception.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_exception.freezed.dart';

@freezed
sealed class AppException with _$AppException implements Exception {
  const factory AppException.network({
    required String message,
    int? statusCode,
  }) = NetworkException;

  const factory AppException.auth({
    required String message,
    String? code,
  }) = AuthException;

  const factory AppException.storage({
    required String message,
  }) = StorageException;

  const factory AppException.payment({
    required String message,
    String? code,
  }) = PaymentException;

  const factory AppException.generation({
    required String message,
    String? jobId,
  }) = GenerationException;

  const factory AppException.unknown({
    required String message,
    Object? originalError,
  }) = UnknownException;
}
```

### 7. Dio Client
```dart
// lib/core/utils/dio_client.dart
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'dio_client.g.dart';

@riverpod
Dio dioClient(DioClientRef ref) {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      // Add auth token if available
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        options.headers['Authorization'] = 'Bearer ${session.accessToken}';
      }
      handler.next(options);
    },
    onError: (error, handler) {
      // Log errors
      // Transform to AppException if needed
      handler.next(error);
    },
  ));

  return dio;
}
```

### 8. Update main.dart
```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

class ArtioApp extends ConsumerWidget {
  const ArtioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeNotifierProvider);

    return MaterialApp.router(
      title: 'Artio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
```

## Todo List

- [x] Create route_names.dart with all route paths
- [x] Implement app_router.dart with ShellRoute for bottom nav
- [x] Create app_colors.dart with brand colors
- [x] Configure flex_color_scheme in app_theme.dart
- [x] Implement theme_provider.dart with persistence
- [x] Create app_exception.dart with Freezed
- [x] Set up dio_client.dart with auth interceptor
- [x] Create logger_service.dart wrapper
- [x] Update main.dart with router and theme
- [x] Create placeholder pages (Splash, Login, Home, etc.)
- [x] Run build_runner and verify

## Success Criteria

- Navigation works with redirect based on auth state
- Theme switches between light/dark/system
- Theme persists across app restarts
- Dio client includes auth headers

## Risk Assessment

| Risk | Mitigation |
|------|------------|
| Router not refreshing on auth change | Verify Listenable implementation |
| Theme flickering on load | Load theme preference before MaterialApp |

## Security Considerations

- Auth tokens added via interceptor, not hardcoded
- Error messages sanitized before display

## Next Steps

→ Phase 3: Auth Feature (Supabase auth integration)
