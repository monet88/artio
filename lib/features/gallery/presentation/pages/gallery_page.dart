import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/app_router.dart';
import '../providers/gallery_provider.dart';
import '../widgets/empty_gallery_state.dart';
import '../widgets/masonry_image_grid.dart';
import '../widgets/shimmer_grid.dart';

class GalleryPage extends ConsumerWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleryAsync = ref.watch(galleryStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gallery')),
      body: galleryAsync.when(
        loading: () => const ShimmerGrid(),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading gallery: $error'),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => ref.invalidate(galleryStreamProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyGalleryState();
          }

          return MasonryImageGrid(
            items: items,
            onItemTap: (item, index) {
              context.push(
                AppRoutes.galleryImagePath(item.id),
                extra: {
                  'items': items,
                  'initialIndex': index,
                },
              );
            },
          );
        },
      ),
    );
  }
}
