import 'package:artio/core/services/storage_url_service.dart';
import 'package:artio/features/gallery/domain/entities/gallery_item.dart';
import 'package:artio/features/gallery/presentation/widgets/image_viewer_image_page.dart';
import 'package:artio/shared/widgets/animated_retry_button.dart';
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
            resolvedUrl: 'invalid-url',
            overrides: [
              signedStorageUrlProvider(item.imageUrl!).overrideWith((_) async {
                providerCallCount++;
                return 'https://example.com/refreshed.jpg';
              }),
            ],
          ),
        );
        await tester.pumpAndSettle();

        expect(providerCallCount, 0);
        expect(find.byType(AnimatedRetryButton), findsOneWidget);

        await tester.tap(find.byType(AnimatedRetryButton));
        await tester.pumpAndSettle();

        expect(providerCallCount, 1);
      },
    );
  });
}
