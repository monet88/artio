import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:artio/features/gallery/presentation/widgets/masonry_image_grid.dart';
import 'package:artio/features/gallery/domain/entities/gallery_item.dart';

import '../../../../core/fixtures/gallery_item_fixtures.dart';

void main() {
  group('MasonryImageGrid', () {
    late List<GalleryItem> testItems;
    late GalleryItem tappedItem;
    late int tappedIndex;

    setUp(() {
      testItems = GalleryItemFixtures.list(count: 5);
    });

    Widget buildWidget(List<GalleryItem> items) {
      return MaterialApp(
        home: Scaffold(
          body: MasonryImageGrid(
            items: items,
            onItemTap: (item, index) {
              tappedItem = item;
              tappedIndex = index;
            },
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
      final pendingItems = [
        GalleryItemFixtures.processing(),
      ];

      await tester.pumpWidget(buildWidget(pendingItems));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Generating'), findsOneWidget);
    });

    testWidgets('shows failed image card for failed items', (tester) async {
      final failedItems = [
        GalleryItemFixtures.failed(),
      ];

      await tester.pumpWidget(buildWidget(failedItems));

      expect(find.byType(AspectRatio), findsOneWidget);
    });

    testWidgets('renders image for completed items', (tester) async {
      final completedItems = [
        GalleryItemFixtures.completed(),
      ];

      await tester.pumpWidget(buildWidget(completedItems));

      expect(find.byType(ClipRRect), findsOneWidget);
    });
  });
}
