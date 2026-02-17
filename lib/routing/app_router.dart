import 'package:artio/core/design_system/app_animations.dart';
import 'package:artio/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:artio/routing/routes/app_routes.dart';
import 'package:artio/shared/widgets/error_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  final authNotifier = ref.watch(authViewModelProvider.notifier);

  return GoRouter(
    debugLogDiagnostics: kDebugMode,
    initialLocation: const SplashRoute().location,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      return authNotifier.redirect(currentPath: state.matchedLocation);
    },
    routes: $appRoutes,
    errorBuilder: (context, state) => ErrorPage(error: state.error),
  );
}

// ── Custom Page Builders for GoRouter ─────────────────────────────────────

/// Fade transition — for tab switches
CustomTransitionPage<T> fadeTransitionPage<T>({
  required Widget child,
  required GoRouterState state,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    reverseTransitionDuration: AppAnimations.fast,
    transitionsBuilder: AppAnimations.fadeTransitionBuilder,
  );
}

/// Slide-up transition — for detail screens
CustomTransitionPage<T> slideUpTransitionPage<T>({
  required Widget child,
  required GoRouterState state,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: AppAnimations.slideUpTransitionBuilder,
  );
}

/// Fade-through transition — for auth flow
CustomTransitionPage<T> fadeThroughTransitionPage<T>({
  required Widget child,
  required GoRouterState state,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    reverseTransitionDuration: AppAnimations.fast,
    transitionsBuilder: AppAnimations.fadeThroughTransitionBuilder,
  );
}
