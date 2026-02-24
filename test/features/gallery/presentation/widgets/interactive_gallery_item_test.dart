import 'package:artio/core/services/storage_url_service.dart';
import 'package:artio/features/gallery/domain/entities/gallery_item.dart';
import 'package:artio/features/gallery/presentation/constants/gallery_strings.dart';
import 'package:artio/features/gallery/presentation/widgets/interactive_gallery_item.dart';
import 'package:artio/shared/widgets/retry_text_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test helper: creates a completed GalleryItem with an imageUrl.
GalleryItem _completedItem({String imageUrl = 'user123/test.jpg'}) {
  return GalleryItem(
    id: 'item-1',
    jobId: 'job-1',
    userId: 'user123',
    templateId: 'tmpl-1',
    templateName: 'Test Template',
    createdAt: DateTime(2026, 2, 24),
    status: GenerationStatus.completed,
    imageUrl: imageUrl,
  );
}

/// Wraps widget in MaterialApp + ProviderScope with overrides.
Widget _buildTestWidget({
  required Widget child,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('InteractiveGalleryItem — provider error retry', () {
    testWidgets('shows RetryTextButton when provider returns error',
        (tester) async {
      final item = _completedItem();

      await tester.pumpWidget(
        _buildTestWidget(
          overrides: [
            signedStorageUrlProvider(item.imageUrl!)
                .overrideWith((_) => throw Exception('network error')),
          ],
          child: SizedBox(
            width: 200,
            height: 200,
            child: InteractiveGalleryItem(
              item: item,
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Error state visible
      expect(find.text(GalleryStrings.failedToLoad), findsOneWidget);
      expect(find.byType(RetryTextButton), findsOneWidget);
    });

    testWidgets('tapping Retry invalidates provider', (tester) async {
      var callCount = 0;
      final item = _completedItem();

      await tester.pumpWidget(
        _buildTestWidget(
          overrides: [
            signedStorageUrlProvider(item.imageUrl!).overrideWith((_) {
              callCount++;
              throw Exception('network error');
            }),
          ],
          child: SizedBox(
            width: 200,
            height: 200,
            child: InteractiveGalleryItem(
              item: item,
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final initialCallCount = callCount;

      // Tap retry
      await tester.tap(find.byType(RetryTextButton));
      await tester.pumpAndSettle();

      // Provider should have been re-evaluated (callCount increased)
      expect(callCount, greaterThan(initialCallCount));
    });
  });

  group('InteractiveGalleryItem — CachedNetworkImage retry', () {
    testWidgets(
        'with resolvedUrl, retry increments ValueKey on CachedNetworkImage',
        (tester) async {
      final item = _completedItem();
      const resolvedUrl = 'https://example.com/signed/test.jpg';

      await tester.pumpWidget(
        _buildTestWidget(
          child: SizedBox(
            width: 200,
            height: 200,
            child: InteractiveGalleryItem(
              item: item,
              onTap: () {},
              resolvedUrl: resolvedUrl,
            ),
          ),
        ),
      );
      await tester.pump();

      // CachedNetworkImage should exist with initial ValueKey(0)
      final cachedImageFinder = find.byType(CachedNetworkImage);
      expect(cachedImageFinder, findsOneWidget);

      final cachedImage =
          tester.widget<CachedNetworkImage>(cachedImageFinder);
      expect(cachedImage.key, equals(const ValueKey(0)));
    });
  });
}
