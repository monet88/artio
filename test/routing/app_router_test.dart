import 'package:artio/features/gallery/domain/entities/gallery_item.dart';
import 'package:artio/features/gallery/presentation/pages/image_viewer_page.dart';
import 'package:artio/routing/app_router.dart';
import 'package:artio/routing/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../core/helpers/riverpod_test_utils.dart';

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

    test('GalleryImageRoute has correct path', () {
      const route = GalleryImageRoute(
        $extra: GalleryImageExtra(items: [], initialIndex: 0),
      );
      expect(route.location, '/gallery/viewer');
    });
  });

  group('appRouter', () {
    test('creates GoRouter with required configuration', () {
      final container = createContainer();

      final router = container.read(appRouterProvider);

      expect(router, isNotNull);
      expect(router.routerDelegate, isNotNull);
      expect(router.routeInformationParser, isNotNull);
      expect(router.routeInformationProvider, isNotNull);
    });

    test('router can build MaterialApp.router', () {
      final container = createContainer();

      final router = container.read(appRouterProvider);

      final app = MaterialApp.router(routerConfig: router);

      expect(app.routerConfig, router);
    });

    test('router configuration is valid', () {
      final container = createContainer();

      final router = container.read(appRouterProvider);

      final config = router.configuration;
      expect(config, isNotNull);
      expect(config.routes, isNotEmpty);
    });
  });

  group('GalleryImageRoute redirect logic', () {
    // Test the redirect method directly — no widget rendering needed
    test('redirects when extra is null', () {
      final context = _FakeBuildContext();
      final state = _FakeGoRouterState();
      const route = GalleryImageRoute();

      final result = route.redirect(context, state);

      expect(result, const GalleryRoute().location);
    });

    test('redirects when extra has wrong type', () {
      final context = _FakeBuildContext();
      final state = _FakeGoRouterState();
      const route = GalleryImageRoute($extra: 'invalid');

      final result = route.redirect(context, state);

      expect(result, const GalleryRoute().location);
    });

    test('redirects when items are empty', () {
      final context = _FakeBuildContext();
      final state = _FakeGoRouterState();
      const route = GalleryImageRoute(
        $extra: GalleryImageExtra(items: [], initialIndex: 0),
      );

      final result = route.redirect(context, state);

      expect(result, const GalleryRoute().location);
    });

    test('redirects when index is out of range', () {
      final context = _FakeBuildContext();
      final state = _FakeGoRouterState();
      final items = [_galleryItem(id: '1')];
      final route = GalleryImageRoute(
        $extra: GalleryImageExtra(items: items, initialIndex: 5),
      );

      final result = route.redirect(context, state);

      expect(result, const GalleryRoute().location);
    });

    test('allows navigation when extra is valid', () {
      final context = _FakeBuildContext();
      final state = _FakeGoRouterState();
      final items = [_galleryItem(id: '1'), _galleryItem(id: '2')];
      final route = GalleryImageRoute(
        $extra: GalleryImageExtra(items: items, initialIndex: 0),
      );

      final result = route.redirect(context, state);

      expect(result, isNull);
    });

    test('builds ImageViewerPage when extra is valid', () {
      final context = _FakeBuildContext();
      final state = _FakeGoRouterState();
      final items = [_galleryItem(id: '1'), _galleryItem(id: '2')];
      final route = GalleryImageRoute(
        $extra: GalleryImageExtra(items: items, initialIndex: 0),
      );

      final widget = route.build(context, state);

      expect(widget, isA<ImageViewerPage>());
    });
  });
}

GalleryItem _galleryItem({required String id}) {
  return GalleryItem(
    id: id,
    jobId: 'job-$id',
    userId: 'user-$id',
    templateId: 'template-$id',
    templateName: 'Template $id',
    createdAt: DateTime(2024),
    status: GenerationStatus.completed,
    imageUrl: 'https://example.com/$id.png',
  );
}

// Minimal fake implementations for unit-testing route redirect logic
class _FakeBuildContext extends Fake implements BuildContext {}

class _FakeGoRouterState extends Fake implements GoRouterState {
  @override
  String get matchedLocation => '/gallery/viewer';
}
