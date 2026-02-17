import 'package:artio/core/utils/app_exception_mapper.dart';
import 'package:artio/features/gallery/presentation/providers/gallery_provider.dart';
import 'package:artio/features/gallery/presentation/widgets/empty_gallery_state.dart';
import 'package:artio/features/gallery/presentation/widgets/masonry_image_grid.dart';
import 'package:artio/features/gallery/presentation/widgets/shimmer_grid.dart';
import 'package:artio/routing/routes/app_routes.dart';
import 'package:artio/shared/widgets/error_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GalleryPage extends ConsumerWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleryAsync = ref.watch(galleryStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gallery')),
      body: galleryAsync.when(
        loading: () => const ShimmerGrid(),
        error: (error, stackTrace) => ErrorStateWidget(
          message: AppExceptionMapper.toUserMessage(error),
          onRetry: () => ref.invalidate(galleryStreamProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyGalleryState();
          }

          return MasonryImageGrid(
            items: items,
            onItemTap: (item, index) {
              GalleryImageRoute(
                $extra: GalleryImageExtra(
                  items: items,
                  initialIndex: index,
                ),
              ).push(context);
            },
          );
        },
      ),
    );
  }
}
