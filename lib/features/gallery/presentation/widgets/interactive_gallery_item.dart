import 'package:artio/core/design_system/app_animations.dart';
import 'package:artio/core/design_system/app_dimensions.dart';
import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/core/services/storage_url_service.dart';
import 'package:artio/features/gallery/domain/entities/gallery_item.dart';
import 'package:artio/features/gallery/presentation/constants/gallery_strings.dart';
import 'package:artio/features/gallery/presentation/widgets/failed_image_card.dart';
import 'package:artio/shared/widgets/retry_text_button.dart';
import 'package:artio/shared/widgets/watermark_overlay.dart';
import 'package:artio/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

/// Gallery item with long-press scale effect.
class InteractiveGalleryItem extends ConsumerStatefulWidget {
  const InteractiveGalleryItem({
    required this.item,
    required this.onTap,
    this.showWatermark = false,

    /// Pre-resolved signed URL from a batch call. When provided, skips the
    /// per-item [signedStorageUrlProvider] to avoid N+1 API requests.
    this.resolvedUrl,
    super.key,
  });

  final GalleryItem item;
  final VoidCallback onTap;
  final bool showWatermark;
  final String? resolvedUrl;

  @override
  ConsumerState<InteractiveGalleryItem> createState() =>
      _InteractiveGalleryItemState();
}

class _InteractiveGalleryItemState extends ConsumerState<InteractiveGalleryItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnimation;

  /// Incremented on retry to force [CachedNetworkImage] recreation via
  /// [ValueKey]. More reliable than depending on setState alone.
  int _retryCount = 0;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: AppAnimations.fast,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.95).animate(
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
      // Use pre-resolved URL from batch call if available,
      // otherwise fall back to per-item signed URL resolution.
      final signedUrlAsync = widget.resolvedUrl != null
          ? AsyncValue.data(widget.resolvedUrl)
          : ref.watch(signedStorageUrlProvider(item.imageUrl!));

      return signedUrlAsync.when(
        loading: () => AspectRatio(
          aspectRatio: 1,
          child: Shimmer.fromColors(
            baseColor: isDark ? AppColors.shimmerBase : const Color(0xFFE8EAF0),
            highlightColor: isDark
                ? AppColors.shimmerHighlight
                : const Color(0xFFF3F4F8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppDimensions.cardRadius,
              ),
            ),
          ),
        ),
        error: (_, __) => AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: AppDimensions.cardRadius,
            child: ColoredBox(
              color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image_rounded,
                    size: 32,
                    color: isDark
                        ? AppColors.textMuted
                        : AppColors.textMutedLight,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    GalleryStrings.failedToLoad,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isDark
                          ? AppColors.textMuted
                          : AppColors.textMutedLight,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  RetryTextButton(
                    onPressed: () => ref.invalidate(
                      signedStorageUrlProvider(item.imageUrl!),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        data: (signedUrl) {
          if (signedUrl == null) {
            return AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: AppDimensions.cardRadius,
                child: ColoredBox(
                  color: isDark
                      ? AppColors.darkSurface2
                      : AppColors.lightSurface2,
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 32,
                    color: isDark
                        ? AppColors.textMuted
                        : AppColors.textMutedLight,
                  ),
                ),
              ),
            );
          }
          return WatermarkOverlay(
            showWatermark: widget.showWatermark,
            child: Hero(
              tag: 'gallery-image-${item.id}',
              child: ClipRRect(
                borderRadius: AppDimensions.cardRadius,
                child: CachedNetworkImage(
                  key: ValueKey(_retryCount),
                  imageUrl: signedUrl,
                  // Use the stable storage path as cache key so the cached
                  // image survives signed URL expiry (signed URL rotates,
                  // but the content is the same file).
                  cacheKey: item.imageUrl,
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
                    child: ClipRRect(
                      borderRadius: AppDimensions.cardRadius,
                      child: ColoredBox(
                        color: isDark
                            ? AppColors.darkSurface2
                            : AppColors.lightSurface2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image_rounded,
                              size: 32,
                              color: isDark
                                  ? AppColors.textMuted
                                  : AppColors.textMutedLight,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              GalleryStrings.failedToLoad,
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: isDark
                                        ? AppColors.textMuted
                                        : AppColors.textMutedLight,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            RetryTextButton(
                              onPressed: () {
                                CachedNetworkImage.evictFromCache(
                                  item.imageUrl!,
                                );
                                setState(() => _retryCount++);
                                if (widget.resolvedUrl == null) {
                                  ref.invalidate(
                                    signedStorageUrlProvider(item.imageUrl!),
                                  );
                                }
                                // When resolvedUrl != null: _retryCount++
                                // changes ValueKey → CachedNetworkImage
                                // fully recreated. Cache was evicted,
                                // so re-fetch happens naturally.
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      );
    }

    // Fallback
    return const SizedBox.shrink();
  }
}
