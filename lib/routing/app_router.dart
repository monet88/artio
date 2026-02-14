import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/auth/presentation/view_models/auth_view_model.dart';
import '../shared/widgets/error_page.dart';
import 'routes/app_routes.dart';

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
