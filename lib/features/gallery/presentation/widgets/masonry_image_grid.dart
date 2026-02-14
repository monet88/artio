import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../../core/design_system/app_dimensions.dart';
import '../../../../core/design_system/app_spacing.dart';
import '../../domain/entities/gallery_item.dart';
import 'failed_image_card.dart';

class MasonryImageGrid extends StatelessWidget {
  final List<GalleryItem> items;
  final Function(GalleryItem item, int index) onItemTap;

  const MasonryImageGrid({
    super.key,
    required this.items,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    // Responsive column count
    final width = MediaQuery.sizeOf(context).width;
    final int crossAxisCount;
    if (width > 900) {
      crossAxisCount = 4;
    } else if (width > 600) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 2;
    }

    return MasonryGridView.count(
      padding: AppSpacing.cardPadding,
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () => onItemTap(item, index),
          child: _buildGalleryItem(context, item),
        );
      },
    );
  }

  Widget _buildGalleryItem(BuildContext context, GalleryItem item) {
    // Handle Failed Status
    if (item.status == GenerationStatus.failed) {
      return AspectRatio(
        aspectRatio: 1,
        child: FailedImageCard(jobId: item.jobId),
      );
    }

    // Handle Pending/Processing Status
    if (item.status == GenerationStatus.pending ||
        item.status == GenerationStatus.generating ||
        item.status == GenerationStatus.processing) {
      return AspectRatio(
        aspectRatio: 1, // Square placeholder
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: AppDimensions.cardRadius,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: AppDimensions.iconMd,
                height: AppDimensions.iconMd,
                child: const CircularProgressIndicator(strokeWidth: 2.5),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                item.status == GenerationStatus.pending
                    ? 'Pending'
                    : 'Generating',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    // Handle Completed Status with Image
    // Use CachedNetworkImage if url is present
    if (item.imageUrl != null) {
      return Hero(
        tag: 'gallery-image-${item.id}',
        child: ClipRRect(
          borderRadius: AppDimensions.cardRadius,
          child: CachedNetworkImage(
            imageUrl: item.imageUrl!,
            placeholder: (context, url) => AspectRatio(
              aspectRatio: 1,
              child: Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
            errorWidget: (context, url, error) => AspectRatio(
              aspectRatio: 1,
              child: Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.broken_image),
              ),
            ),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    // Fallback
    return const SizedBox.shrink();
  }
}
