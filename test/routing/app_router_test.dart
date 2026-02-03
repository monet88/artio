import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:artio/routing/app_router.dart';
import 'package:artio/routing/routes/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:artio/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:artio/features/auth/presentation/state/auth_state.dart';
import 'package:artio/shared/widgets/main_shell.dart';
import 'package:artio/features/gallery/presentation/pages/gallery_page.dart';
import 'package:artio/features/gallery/domain/entities/gallery_item.dart';
import 'package:artio/features/gallery/presentation/pages/image_viewer_page.dart';
import '../core/fixtures/user_fixtures.dart';
import '../core/helpers/pump_app.dart';
import '../core/helpers/riverpod_test_utils.dart';

class _MockAuthViewModel extends AuthViewModel {
  @override
  AuthState build() => AuthState.authenticated(UserFixtures.authenticated());
}

ProviderContainer _createAuthedContainer({List<Override>? overrides}) {
  final baseOverrides = <Override>[
    authViewModelProvider.overrideWith(() => _MockAuthViewModel()),
  ];

  return ProviderContainer(
    overrides: [
      ...baseOverrides,
      ...?overrides,
    ],
  );
}

Future<GoRouter> _pumpRouter(
  WidgetTester tester,
  ProviderContainer container,
) async {
  final router = container.read(appRouterProvider);
  await tester.pumpAppWithRouter(
    router: router,
    parent: container,
  );
  await tester.pump();
  return router;
}

void _expectRedirectToGallery(WidgetTester tester) {
  expect(find.byType(MainShell), findsOneWidget);
  expect(find.byType(GalleryPage), findsOneWidget);
  expect(find.byType(ImageViewerPage), findsNothing);
}

Future<void> _disposeContainer(
  WidgetTester tester,
  ProviderContainer container,
) async {
  await tester.pumpAndSettle();
  container.dispose();
}

GalleryItem _galleryItem({required String id}) {
  return GalleryItem(
    id: id,
    jobId: 'job-$id',
    userId: 'user-$id',
    templateId: 'template-$id',
    templateName: 'Template $id',
    createdAt: DateTime(2024, 1, 1),
    status: GenerationStatus.completed,
    imageUrl: 'https://example.com/$id.png',
  );
}

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
      final route = GalleryImageRoute(
        $extra: GalleryImageExtra(items: [], initialIndex: 0),
      );
      expect(route.location, '/gallery/viewer');
    });
  });

  group('appRouter', () {
    test('creates GoRouter with required configuration', () {
      final container = createContainer();

      final router = container.read(appRouterProvider);

      // Verify router is created with essential components
      expect(router, isNotNull);
      expect(router.routerDelegate, isNotNull);
      expect(router.routeInformationParser, isNotNull);
      expect(router.routeInformationProvider, isNotNull);
    });

    test('router can build MaterialApp.router', () {
      final container = createContainer();

      final router = container.read(appRouterProvider);

      // Verify router config works with MaterialApp.router
      final app = MaterialApp.router(
        routerConfig: router,
      );

      expect(app.routerConfig, router);
    });

    test('router configuration is valid', () {
      final container = createContainer();

      final router = container.read(appRouterProvider);

      // GoRouter.configuration is the public API for accessing route config
      final config = router.configuration;
      expect(config, isNotNull);
      expect(config.routes, isNotEmpty);
    });

    testWidgets('redirects viewer route when extra is missing', (tester) async {
      final container = _createAuthedContainer();
      final router = await _pumpRouter(tester, container);
      router.go(const GalleryImageRoute().location);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      _expectRedirectToGallery(tester);
      await _disposeContainer(tester, container);
    });

    testWidgets('redirects viewer route when extra has wrong type',
        (tester) async {
      final container = _createAuthedContainer();
      final router = await _pumpRouter(tester, container);
      router.go(
        const GalleryImageRoute($extra: 'invalid-extra').location,
        extra: 'invalid-extra',
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      _expectRedirectToGallery(tester);
      await _disposeContainer(tester, container);
    });

    testWidgets('opens viewer when extra is valid', (tester) async {
      final items = [_galleryItem(id: '1'), _galleryItem(id: '2')];
      final container = _createAuthedContainer();
      final router = await _pumpRouter(tester, container);
      final route = GalleryImageRoute(
        $extra: GalleryImageExtra(items: items, initialIndex: 0),
      );
      router.go(route.location, extra: route.$extra);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(ImageViewerPage), findsOneWidget);
      await _disposeContainer(tester, container);
    });

    testWidgets('redirects viewer when items are empty', (tester) async {
      final container = _createAuthedContainer();
      final router = await _pumpRouter(tester, container);
      final route = GalleryImageRoute(
        $extra: const GalleryImageExtra(items: [], initialIndex: 0),
      );
      router.go(route.location, extra: route.$extra);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      _expectRedirectToGallery(tester);
      await _disposeContainer(tester, container);
    });

    testWidgets('redirects viewer when index is out of range', (tester) async {
      final items = [_galleryItem(id: '1')];
      final container = _createAuthedContainer();
      final router = await _pumpRouter(tester, container);
      final route = GalleryImageRoute(
        $extra: GalleryImageExtra(items: items, initialIndex: 5),
      );
      router.go(route.location, extra: route.$extra);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      _expectRedirectToGallery(tester);
      await _disposeContainer(tester, container);
    });
  });
}
