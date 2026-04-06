import 'package:artio/core/services/storage_url_service.dart';
import 'package:artio/features/gallery/domain/entities/gallery_item.dart';
import 'package:artio/features/gallery/presentation/widgets/image_viewer_image_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

Widget _buildTestWidget({
  required GalleryItem item,
  String? resolvedUrl,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 300,
          height: 300,
          child: ImageViewerImagePage(
            item: item,
            resolvedUrl: resolvedUrl,
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('ImageViewerImagePage', () {
    testWidgets(
      'retry falls back to signedStorageUrlProvider when pre-resolved URL fails',
      (tester) async {
        var providerCallCount = 0;
        final item = _completedItem();

        await tester.pumpWidget(
          _buildTestWidget(
            item: item,
            resolvedUrl: 'https://example.com/stale.jpg',
            overrides: [
              signedStorageUrlProvider(item.imageUrl!).overrideWith((_) async {
                providerCallCount++;
                return 'https://example.com/refreshed.jpg';
              }),
            ],
          ),
        );
        await tester.pump();

        expect(providerCallCount, 0);
        final cachedImage = tester.widget<CachedNetworkImage>(
          find.byType(CachedNetworkImage),
        );
        final context = tester.element(find.byType(CachedNetworkImage));
        final errorWidget = cachedImage.errorWidget!(
          context,
          cachedImage.imageUrl,
          Exception('expired'),
        );

        (errorWidget as dynamic).onRetry();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        expect(providerCallCount, 1);
      },
    );
  });
}
