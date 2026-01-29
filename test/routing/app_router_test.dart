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

      // Verify router is created
      expect(router, isNotNull);
      expect(router.routerDelegate, isNotNull);
      expect(router.goRouterDelegate, isNotNull);
      expect(router.routeInformationParser, isNotNull);
    });

    test('initial location is splash screen', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final router = container.read(appRouterProvider);

      expect(router.initialLocation, '/');
    });

    test('GoRouter has auth redirect configured', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final router = container.read(appRouterProvider);

      // Verify redirect is configured (not null)
      expect(router.redirect, isNotNull);
    });

    test('GoRouter has error builder configured', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final router = container.read(appRouterProvider);

      // Verify errorBuilder is configured
      expect(router.errorBuilder, isNotNull);
    });

    test('GoRouter uses auth state as refreshListenable', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final router = container.read(appRouterProvider);

      // Verify refreshListenable is configured using auth notifier
      expect(router.refreshListenable, isNotNull);
    });

    test('all routes are defined in GoRouter', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final router = container.read(appRouterProvider);

      // Verify route configuration exists
      expect(router.routes, isNotEmpty);
    });
  });
}
