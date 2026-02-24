import 'package:artio/core/services/storage_url_service.dart';
import 'package:artio/features/gallery/domain/entities/gallery_item.dart';
import 'package:artio/features/gallery/presentation/widgets/masonry_image_grid.dart';
import 'package:artio/shared/widgets/watermark_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../core/fixtures/gallery_item_fixtures.dart';

class _StubStorageUrlService implements StorageUrlService {
  @override
  Future<String?> signedUrl(String path) async => path;

  @override
  Future<Map<String, String?>> signedUrls(List<String> paths) async =>
      {for (final path in paths) path: path};
}

void main() {
  group('MasonryImageGrid', () {
    late List<GalleryItem> testItems;
    late GalleryItem tappedItem;
    late int tappedIndex;

    setUp(() {
      testItems = GalleryItemFixtures.list(count: 5);
    });

    Widget buildWidget(List<GalleryItem> items, {bool showWatermark = false}) {
      return ProviderScope(
        overrides: [
          storageUrlServiceProvider.overrideWith((_) => _StubStorageUrlService()),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: MasonryImageGrid(
              items: items,
              showWatermark: showWatermark,
              onItemTap: (item, index) {
                tappedItem = item;
                tappedIndex = index;
              },
            ),
          ),
        ),
      );
    }

    testWidgets('renders grid with items', (tester) async {
      await tester.pumpWidget(buildWidget(testItems));

      expect(find.byType(MasonryGridView), findsOneWidget);
    });

    testWidgets('handles empty list', (tester) async {
      await tester.pumpWidget(buildWidget([]));

      expect(find.byType(MasonryGridView), findsOneWidget);
    });

    testWidgets('onItemTap callback fires when item tapped', (tester) async {
      await tester.pumpWidget(buildWidget(testItems));

      await tester.tap(find.byType(GestureDetector).first);

      expect(tappedItem, isNotNull);
      expect(tappedIndex, 0);
    });

    testWidgets('shows loading indicator for pending items', (tester) async {
      final pendingItems = [GalleryItemFixtures.processing()];

      await tester.pumpWidget(buildWidget(pendingItems));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Generating'), findsOneWidget);
    });

    testWidgets('shows failed image card for failed items', (tester) async {
      final failedItems = [GalleryItemFixtures.failed()];

      await tester.pumpWidget(buildWidget(failedItems));

      expect(find.byType(AspectRatio), findsOneWidget);
    });

    testWidgets('renders image for completed items', (tester) async {
      final completedItems = [GalleryItemFixtures.completed()];

      await tester.pumpWidget(buildWidget(completedItems));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ClipRRect), findsOneWidget);
    });

    testWidgets('shows watermark overlay when showWatermark is true', (
      tester,
    ) async {
      final completedItems = [GalleryItemFixtures.completed()];

      await tester.pumpWidget(buildWidget(completedItems, showWatermark: true));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(WatermarkOverlay), findsOneWidget);
      expect(find.text('artio'), findsOneWidget);
    });

    testWidgets('hides watermark text when showWatermark is false', (
      tester,
    ) async {
      final completedItems = [GalleryItemFixtures.completed()];

      await tester.pumpWidget(buildWidget(completedItems));

      expect(find.text('artio'), findsNothing);
    });
  });
}
