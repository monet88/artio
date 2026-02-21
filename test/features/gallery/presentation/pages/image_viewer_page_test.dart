import 'package:artio/features/gallery/data/repositories/gallery_repository.dart';
import 'package:artio/features/gallery/domain/entities/gallery_item.dart';
import 'package:artio/features/gallery/presentation/pages/image_viewer_page.dart';
import 'package:artio/features/subscription/data/repositories/subscription_repository.dart';
import 'package:artio/features/subscription/domain/entities/subscription_status.dart';
import 'package:artio/features/auth/presentation/state/auth_state.dart';
import 'package:artio/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../core/fixtures/fixtures.dart';

class MockGalleryRepository extends Mock implements GalleryRepository {}
class MockSubscriptionRepository extends Mock implements SubscriptionRepository {}

class _FakeAuthViewModel extends AuthViewModel {
  @override
  AuthState build() => const AuthState.unauthenticated();
}

void main() {
  group('ImageViewerPage', () {
    late MockGalleryRepository mockRepository;
    late MockSubscriptionRepository mockSubscriptionRepository;

    setUp(() {
      mockRepository = MockGalleryRepository();
      mockSubscriptionRepository = MockSubscriptionRepository();
    });

    Widget createTestWidget({
      required List<GalleryItem> items,
      int initialIndex = 0,
      SubscriptionStatus? subscriptionStatus,
    }) {
      final status = subscriptionStatus ?? const SubscriptionStatus();
      when(() => mockSubscriptionRepository.getStatus())
          .thenAnswer((_) async => status);
      when(() => mockSubscriptionRepository.getOfferings())
          .thenAnswer((_) async => []);
      return ProviderScope(
        overrides: [
          galleryRepositoryProvider.overrideWithValue(mockRepository),
          subscriptionRepositoryProvider
              .overrideWithValue(mockSubscriptionRepository),
          authViewModelProvider.overrideWith(
            () => _FakeAuthViewModel(),
          ),
        ],
        child: MaterialApp(
          home: ImageViewerPage(
            items: items.cast(),
            initialIndex: initialIndex,
          ),
        ),
      );
    }

    testWidgets('renders with Scaffold', (tester) async {
      final items = [GalleryItemFixtures.completed()];

      await tester.pumpWidget(createTestWidget(items: items));
      // Pump beyond the 3-second indicator auto-hide timer
      await tester.pump(const Duration(seconds: 4));

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('displays share button in app bar', (tester) async {
      final items = [GalleryItemFixtures.completed()];

      await tester.pumpWidget(createTestWidget(items: items));
      await tester.pump(const Duration(seconds: 4));

      expect(find.byIcon(Icons.share_rounded), findsOneWidget);
    });

    testWidgets('displays download button in app bar', (tester) async {
      final items = [GalleryItemFixtures.completed()];

      await tester.pumpWidget(createTestWidget(items: items));
      await tester.pump(const Duration(seconds: 4));

      expect(find.byIcon(Icons.download_rounded), findsOneWidget);
    });

    testWidgets('displays delete button in app bar', (tester) async {
      final items = [GalleryItemFixtures.completed()];

      await tester.pumpWidget(createTestWidget(items: items));
      await tester.pump(const Duration(seconds: 4));

      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
    });

    testWidgets('displays info button in app bar', (tester) async {
      final items = [GalleryItemFixtures.completed()];

      await tester.pumpWidget(createTestWidget(items: items));
      await tester.pump(const Duration(seconds: 4));

      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
    });

    testWidgets('displays PageView for swiping between images', (tester) async {
      final items = GalleryItemFixtures.list(count: 3);

      await tester.pumpWidget(createTestWidget(items: items));
      await tester.pump(const Duration(seconds: 4));

      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('displays InteractiveViewer for zoom', (tester) async {
      final items = [GalleryItemFixtures.completed()];

      await tester.pumpWidget(createTestWidget(items: items));
      await tester.pump(const Duration(seconds: 4));

      expect(find.byType(InteractiveViewer), findsOneWidget);
    });

    testWidgets('displays image using Hero animation', (tester) async {
      final items = [GalleryItemFixtures.completed()];

      await tester.pumpWidget(createTestWidget(items: items));
      await tester.pump(const Duration(seconds: 4));

      expect(find.byType(Hero), findsOneWidget);
    });

    testWidgets('shows processing state for pending items', (tester) async {
      final items = [GalleryItemFixtures.processing()];

      await tester.pumpWidget(createTestWidget(items: items));
      await tester.pump(const Duration(seconds: 4));

      expect(find.byType(PageView), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(find.byType(Hero), findsOneWidget);

      // Verify app bar actions are still present
      expect(find.byIcon(Icons.share_rounded), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
    });

    testWidgets('starts at specified initialIndex', (tester) async {
      final items = GalleryItemFixtures.list(count: 5);

      await tester.pumpWidget(
          createTestWidget(items: items, initialIndex: 2));
      await tester.pump(const Duration(seconds: 4));

      final pageView = tester.widget<PageView>(find.byType(PageView));
      expect(pageView.controller?.initialPage, 2);
    });

    testWidgets('shows page counter in app bar', (tester) async {
      final items = GalleryItemFixtures.list(count: 3);

      await tester.pumpWidget(createTestWidget(items: items));
      await tester.pump(const Duration(seconds: 4));

      expect(find.text('1 / 3'), findsOneWidget);
    });

    group('watermark overlay', () {
      testWidgets('shows watermark text for free users', (tester) async {
        final items = [GalleryItemFixtures.completed()];

        await tester.pumpWidget(
          createTestWidget(
            items: items,
            subscriptionStatus: const SubscriptionStatus(
              
            ),
          ),
        );
        // pump() resolves the async subscriptionNotifierProvider
        await tester.pump();
        // drain the 3-second timer from _resetIndicatorTimer in initState
        await tester.pump(const Duration(seconds: 3));

        expect(find.text('artio'), findsOneWidget);
      });

      testWidgets('hides watermark text for paid users', (tester) async {
        final items = [GalleryItemFixtures.completed()];

        await tester.pumpWidget(
          createTestWidget(
            items: items,
            subscriptionStatus: const SubscriptionStatus(
              isActive: true,
              tier: 'pro',
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(seconds: 3));

        expect(find.text('artio'), findsNothing);
      });
    });
  });
}
