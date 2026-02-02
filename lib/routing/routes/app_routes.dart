import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/create/presentation/create_screen.dart';
import '../../features/gallery/domain/entities/gallery_item.dart';
import '../../features/gallery/presentation/pages/gallery_page.dart';
import '../../features/gallery/presentation/pages/image_viewer_page.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/template_engine/presentation/screens/home_screen.dart';
import '../../features/template_engine/presentation/screens/template_detail_screen.dart';
import '../../shared/widgets/main_shell.dart';

part 'app_routes.g.dart';

/// Extra data for gallery image navigation
class GalleryImageExtra {
  const GalleryImageExtra({
    required this.items,
    required this.initialIndex,
  });

  final List<GalleryItem> items;
  final int initialIndex;
}

@TypedGoRoute<SplashRoute>(path: '/')
class SplashRoute extends GoRouteData {
  const SplashRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SplashScreen();
}

@TypedGoRoute<LoginRoute>(path: '/login')
class LoginRoute extends GoRouteData {
  const LoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const LoginScreen();
}

@TypedGoRoute<RegisterRoute>(path: '/register')
class RegisterRoute extends GoRouteData {
  const RegisterRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const RegisterScreen();
}

@TypedGoRoute<ForgotPasswordRoute>(path: '/forgot-password')
class ForgotPasswordRoute extends GoRouteData {
  const ForgotPasswordRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ForgotPasswordScreen();
}

@TypedShellRoute<MainShellRoute>(
  routes: [
    TypedGoRoute<HomeRoute>(path: '/home'),
    TypedGoRoute<CreateRoute>(path: '/create'),
    TypedGoRoute<GalleryRoute>(path: '/gallery'),
    TypedGoRoute<SettingsRoute>(path: '/settings'),
  ],
)
class MainShellRoute extends ShellRouteData {
  const MainShellRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return MainShell(child: navigator);
  }
}

class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const HomeScreen();
}

class CreateRoute extends GoRouteData {
  const CreateRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CreateScreen();
}

class GalleryRoute extends GoRouteData {
  const GalleryRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const GalleryPage();
}

class SettingsRoute extends GoRouteData {
  const SettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SettingsScreen();
}

@TypedGoRoute<TemplateDetailRoute>(path: '/template/:id')
class TemplateDetailRoute extends GoRouteData {
  const TemplateDetailRoute({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      TemplateDetailScreen(templateId: id);
}

@TypedGoRoute<GalleryImageRoute>(path: '/gallery/:id')
class GalleryImageRoute extends GoRouteData {
  const GalleryImageRoute({required this.id, required this.$extra});

  final String id;
  final GalleryImageExtra $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) => ImageViewerPage(
        items: $extra.items,
        initialIndex: $extra.initialIndex,
      );
}
