import 'package:artio/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:artio/features/auth/presentation/screens/login_screen.dart';
import 'package:artio/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:artio/features/auth/presentation/screens/register_screen.dart';
import 'package:artio/features/auth/presentation/screens/splash_screen.dart';
import 'package:artio/features/create/presentation/create_screen.dart';
import 'package:artio/features/credits/presentation/screens/credit_history_screen.dart';
import 'package:artio/features/gallery/domain/entities/gallery_item.dart';
import 'package:artio/features/gallery/presentation/pages/gallery_page.dart';
import 'package:artio/features/gallery/presentation/pages/image_viewer_page.dart';
import 'package:artio/features/settings/presentation/settings_screen.dart';
import 'package:artio/features/subscription/presentation/screens/paywall_screen.dart';
import 'package:artio/features/template_engine/presentation/screens/home_screen.dart';
import 'package:artio/features/template_engine/presentation/screens/template_detail_screen.dart';
import 'package:artio/shared/widgets/main_shell.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'app_routes.g.dart';

/// Extra data for gallery image navigation
class GalleryImageExtra {
  const GalleryImageExtra({required this.items, required this.initialIndex});

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

@TypedGoRoute<OnboardingRoute>(path: '/onboarding')
class OnboardingRoute extends GoRouteData {
  const OnboardingRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const OnboardingScreen();
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
  Widget build(BuildContext context, GoRouterState state) => const HomeScreen();
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

/// Gallery viewer requires [GalleryImageExtra] in `extra` with:
/// - non-empty `items`
/// - `initialIndex` within `items` bounds
/// Invalid extras redirect to [GalleryRoute].
@TypedGoRoute<GalleryImageRoute>(path: '/gallery/viewer')
class GalleryImageRoute extends GoRouteData {
  const GalleryImageRoute({this.$extra});
  final Object? $extra;

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    final extra = $extra;
    final galleryLocation = const GalleryRoute().location;
    if (extra is! GalleryImageExtra) {
      return galleryLocation;
    }

    if (extra.items.isEmpty) {
      return galleryLocation;
    }

    if (extra.initialIndex < 0 || extra.initialIndex >= extra.items.length) {
      return galleryLocation;
    }

    return null;
  }

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final extra = $extra;
    if (extra is! GalleryImageExtra) {
      return const GalleryPage();
    }
    return ImageViewerPage(
      items: extra.items,
      initialIndex: extra.initialIndex,
    );
  }
}

@TypedGoRoute<CreditHistoryRoute>(path: '/credits/history')
class CreditHistoryRoute extends GoRouteData {
  const CreditHistoryRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CreditHistoryScreen();
}

@TypedGoRoute<PaywallRoute>(path: '/paywall')
class PaywallRoute extends GoRouteData {
  const PaywallRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const PaywallScreen();
  }
}
