import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/auth/presentation/view_models/auth_view_model.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/create/ui/create_screen.dart';
import '../features/gallery/ui/gallery_screen.dart';
import '../features/settings/ui/settings_screen.dart';
import '../features/template_engine/presentation/screens/home_screen.dart';
import '../features/template_engine/presentation/screens/template_detail_screen.dart';
import '../shared/widgets/error_page.dart';
import '../shared/widgets/main_shell.dart';

part 'app_router.g.dart';

abstract class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const home = '/home';
  static const create = '/create';
  static const gallery = '/gallery';
  static const settings = '/settings';
  static const templateDetail = '/template/:id';

  static String templateDetailPath(String id) => '/template/$id';
}

@riverpod
GoRouter appRouter(Ref ref) {
  final authNotifier = ref.watch(authViewModelProvider.notifier);

  return GoRouter(
    debugLogDiagnostics: kDebugMode,
    initialLocation: AppRoutes.splash,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      return authNotifier.redirect(currentPath: state.matchedLocation);
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.create,
            builder: (context, state) => const CreateScreen(),
          ),
          GoRoute(
            path: AppRoutes.gallery,
            builder: (context, state) => const GalleryScreen(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.templateDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TemplateDetailScreen(templateId: id);
        },
      ),
    ],
    errorBuilder: (context, state) => ErrorPage(error: state.error),
  );
}
