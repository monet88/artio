import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:artio/routing/app_router.dart';

void main() {
  group('AppRoutes', () {
    test('has all route path constants', () {
      expect(AppRoutes.splash, '/');
      expect(AppRoutes.login, '/login');
      expect(AppRoutes.register, '/register');
      expect(AppRoutes.forgotPassword, '/forgot-password');
      expect(AppRoutes.home, '/home');
      expect(AppRoutes.create, '/create');
      expect(AppRoutes.gallery, '/gallery');
      expect(AppRoutes.galleryImage, '/gallery/:id');
      expect(AppRoutes.settings, '/settings');
      expect(AppRoutes.templateDetail, '/template/:id');
    });

    test('templateDetailPath generates correct path', () {
      const id = 'abc123';
      final path = AppRoutes.templateDetailPath(id);

      expect(path, '/template/abc123');
    });

    test('galleryImagePath generates correct path', () {
      const id = 'img456';
      final path = AppRoutes.galleryImagePath(id);

      expect(path, '/gallery/img456');
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
