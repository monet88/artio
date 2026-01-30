import 'package:artio_admin/features/auth/presentation/pages/login_page.dart';
import 'package:artio_admin/features/auth/providers/admin_auth_provider.dart';
import 'package:artio_admin/features/templates/presentation/pages/template_editor_page.dart';
import 'package:artio_admin/features/templates/presentation/pages/templates_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@riverpod
Raw<GoRouter> goRouter(Ref ref) {
  // AdminAuth implements Listenable, use it directly for router refresh
  final authNotifier = ref.watch(adminAuthProvider.notifier);

  return GoRouter(
    initialLocation: '/templates',
    debugLogDiagnostics: true,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authState = ref.read(adminAuthProvider);
      final isLoading = authState.isLoading;
      final isLoggedIn = authState.valueOrNull != null;
      final isLoggingIn = state.uri.path == '/login';

      if (isLoading) {
        return null;
      }

      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      if (isLoggedIn && isLoggingIn) {
        return '/templates';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/templates',
        builder: (context, state) => const TemplatesPage(),
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) => const TemplateEditorPage(),
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return TemplateEditorPage(templateId: id);
            },
          ),
        ],
      ),
    ],
  );
}
