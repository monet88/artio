import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:artio/routing/app_router.dart';
import 'package:artio/routing/routes/app_routes.dart';

void main() {
  group('TypedGoRoute', () {
    test('SplashRoute has correct path', () {
      const route = SplashRoute();
      expect(route.location, '/');
    });

    test('LoginRoute has correct path', () {
      const route = LoginRoute();
      expect(route.location, '/login');
    });

    test('RegisterRoute has correct path', () {
      const route = RegisterRoute();
      expect(route.location, '/register');
    });

    test('ForgotPasswordRoute has correct path', () {
      const route = ForgotPasswordRoute();
      expect(route.location, '/forgot-password');
    });

    test('HomeRoute has correct path', () {
      const route = HomeRoute();
      expect(route.location, '/home');
    });

    test('CreateRoute has correct path', () {
      const route = CreateRoute();
      expect(route.location, '/create');
    });

    test('GalleryRoute has correct path', () {
      const route = GalleryRoute();
      expect(route.location, '/gallery');
    });

    test('SettingsRoute has correct path', () {
      const route = SettingsRoute();
      expect(route.location, '/settings');
    });

    test('TemplateDetailRoute has correct path with id', () {
      const route = TemplateDetailRoute(id: 'abc123');
      expect(route.location, '/template/abc123');
    });

    test('GalleryImageRoute has correct path with id', () {
      final route = GalleryImageRoute(
        id: 'img456',
        $extra: GalleryImageExtra(items: [], initialIndex: 0),
      );
      expect(route.location, '/gallery/img456');
    });
  });

  group('appRouter', () {
    test('creates GoRouter with required configuration', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final router = container.read(appRouterProvider);

      // Verify router is created with essential components
      expect(router, isNotNull);
      expect(router.routerDelegate, isNotNull);
      expect(router.routeInformationParser, isNotNull);
      expect(router.routeInformationProvider, isNotNull);
    });

    test('router can build MaterialApp.router', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final router = container.read(appRouterProvider);

      // Verify router config works with MaterialApp.router
      final app = MaterialApp.router(
        routerConfig: router,
      );

      expect(app.routerConfig, router);
    });

    test('router configuration is valid', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final router = container.read(appRouterProvider);

      // GoRouter.configuration is the public API for accessing route config
      final config = router.configuration;
      expect(config, isNotNull);
      expect(config.routes, isNotEmpty);
    });
  });
}
