import 'package:artio/core/design_system/app_animations.dart';
import 'package:artio/core/design_system/app_dimensions.dart';
import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';

import '../../domain/entities/gallery_item.dart';
import 'failed_image_card.dart';

/// Masonry image grid with staggered appear animations,
/// shimmer placeholders, and long-press scale effect.
class MasonryImageGrid extends StatefulWidget {
  final List<GalleryItem> items;
  final Function(GalleryItem item, int index) onItemTap;

  const MasonryImageGrid({
    super.key,
    required this.items,
    required this.onItemTap,
  });

  @override
  State<MasonryImageGrid> createState() => _MasonryImageGridState();
}

class _MasonryImageGridState extends State<MasonryImageGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: AppAnimations.normal.inMilliseconds +
            (AppAnimations.staggerDelay.inMilliseconds *
                widget.items.length.clamp(0, AppAnimations.maxStaggerItems)),
      ),
    )..forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final item = widget.items[index];

        // Stagger animation
        final maxItems = AppAnimations.maxStaggerItems;
        final clampedItemCount = widget.items.length.clamp(0, maxItems);
        final staggerIndex = index.clamp(0, maxItems);
        final totalStaggerTime =
            AppAnimations.staggerDelay.inMilliseconds * clampedItemCount;
        final totalDuration =
            AppAnimations.normal.inMilliseconds + totalStaggerTime;
        final startFrac =
            (staggerIndex * AppAnimations.staggerDelay.inMilliseconds) /
                totalDuration;
        final endFrac =
            (staggerIndex * AppAnimations.staggerDelay.inMilliseconds +
                    AppAnimations.normal.inMilliseconds) /
                totalDuration;

        final itemAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _staggerController,
            curve: Interval(
              startFrac.clamp(0.0, 1.0),
              endFrac.clamp(0.0, 1.0),
              curve: AppAnimations.defaultCurve,
            ),
          ),
        );

        return AnimatedBuilder(
          animation: itemAnim,
          builder: (context, child) => Opacity(
            opacity: itemAnim.value,
            child: Transform.scale(
              scale: 0.9 + (0.1 * itemAnim.value),
              child: child,
            ),
          ),
          child: _InteractiveGalleryItem(
            item: item,
            onTap: () => widget.onItemTap(item, index),
          ),
        );
      },
    );
  }
}

/// Gallery item with long-press scale effect
class _InteractiveGalleryItem extends StatefulWidget {
  const _InteractiveGalleryItem({
    required this.item,
    required this.onTap,
  });

  final GalleryItem item;
  final VoidCallback onTap;

  @override
  State<_InteractiveGalleryItem> createState() =>
      _InteractiveGalleryItemState();
}

class _InteractiveGalleryItemState extends State<_InteractiveGalleryItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: AppAnimations.fast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: AppAnimations.defaultCurve,
      ),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPressStart: (_) => _pressController.forward(),
        onLongPressEnd: (_) => _pressController.reverse(),
        onTapDown: (_) => _pressController.forward(),
        onTapUp: (_) => _pressController.reverse(),
        onTapCancel: () => _pressController.reverse(),
        child: _buildGalleryItem(context, widget.item),
      ),
    );
  }

  Widget _buildGalleryItem(BuildContext context, GalleryItem item) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
            borderRadius: AppDimensions.cardRadius,
            border: isDark
                ? Border.all(color: AppColors.white10, width: 0.5)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: AppDimensions.iconMd,
                height: AppDimensions.iconMd,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryCta.withValues(alpha: 0.7),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                item.status == GenerationStatus.pending
                    ? 'Pending'
                    : 'Generating',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.textMuted
                          : AppColors.textMutedLight,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    // Handle Completed Status with Image
    if (item.imageUrl != null) {
      return Hero(
        tag: 'gallery-image-${item.id}',
        child: ClipRRect(
          borderRadius: AppDimensions.cardRadius,
          child: CachedNetworkImage(
            imageUrl: item.imageUrl!,
            placeholder: (context, url) => AspectRatio(
              aspectRatio: 1,
              child: Shimmer.fromColors(
                baseColor: isDark
                    ? AppColors.shimmerBase
                    : const Color(0xFFE8EAF0),
                highlightColor: isDark
                    ? AppColors.shimmerHighlight
                    : const Color(0xFFF3F4F8),
                child: Container(color: Colors.white),
              ),
            ),
            errorWidget: (context, url, error) => AspectRatio(
              aspectRatio: 1,
              child: Container(
                color: isDark
                    ? AppColors.darkSurface2
                    : AppColors.lightSurface2,
                child: Icon(
                  Icons.broken_image_rounded,
                  color: isDark
                      ? AppColors.textMuted
                      : AppColors.textMutedLight,
                ),
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
