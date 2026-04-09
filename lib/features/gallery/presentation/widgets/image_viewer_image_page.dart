import 'package:artio/core/design_system/app_gradients.dart';
import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/core/services/storage_url_service.dart';
import 'package:artio/features/gallery/domain/entities/gallery_item.dart';
import 'package:artio/features/gallery/presentation/constants/gallery_strings.dart';
import 'package:artio/shared/widgets/animated_retry_button.dart';
import 'package:artio/shared/widgets/watermark_overlay.dart';
import 'package:artio/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Single image page in the image viewer's PageView.
class ImageViewerImagePage extends ConsumerStatefulWidget {
  const ImageViewerImagePage({
    required this.item,
    this.showWatermark = false,
    this.resolvedUrl,
    super.key,
  });

  final GalleryItem item;
  final bool showWatermark;

  /// Pre-resolved signed URL. When provided, skips the
  /// per-item [signedStorageUrlProvider] to avoid N+1 API requests.
  final String? resolvedUrl;

  @override
  ConsumerState<ImageViewerImagePage> createState() =>
      _ImageViewerImagePageState();
}

class _ImageViewerImagePageState extends ConsumerState<ImageViewerImagePage> {
  bool _forceProviderSignedUrl = false;

  @override
  void didUpdateWidget(covariant ImageViewerImagePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.imageUrl != widget.item.imageUrl ||
        oldWidget.resolvedUrl != widget.resolvedUrl) {
      _forceProviderSignedUrl = false;
    }
  }

  void _retrySignedUrl(String rawPath) {
    setState(() => _forceProviderSignedUrl = true);
    ref.invalidate(signedStorageUrlProvider(rawPath));
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final rawPath = item.imageUrl;
    final localUrl = _forceProviderSignedUrl ? null : widget.resolvedUrl;

    // ⚡ Bolt Optimization: Use pre-resolved signed URL if available
    // Impact: Avoids firing individual N+1 signed URL generation API calls
    // as the user swipes through the gallery pager, cutting down network latency.
    final signedUrlAsync = rawPath != null
        ? (localUrl != null
              ? AsyncValue.data(localUrl)
              : ref.watch(signedStorageUrlProvider(rawPath)))
        : null;

    return WatermarkOverlay(
      showWatermark: widget.showWatermark,
      child: InteractiveViewer(
        child: Center(
          child: Hero(
            tag: 'gallery-image-${item.id}',
            child: signedUrlAsync == null
                // No image yet — show loading/processing state
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.primaryCta,
                          backgroundColor: AppColors.white10,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        item.status == GenerationStatus.pending
                            ? 'Pending...'
                            : 'Processing...',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  )
                // Resolve signed URL then display
                : signedUrlAsync.when(
                    loading: () => const Center(
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.primaryCta,
                          backgroundColor: AppColors.white10,
                        ),
                      ),
                    ),
                    error: (_, __) => _ViewerErrorPlaceholder(
                      onRetry: () => _retrySignedUrl(rawPath!),
                    ),
                    data: (signedUrl) => signedUrl == null
                        ? const SizedBox.shrink()
                        : CachedNetworkImage(
                            imageUrl: signedUrl,
                            cacheKey: rawPath,
                            fit: BoxFit.contain,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) {
                                  final progress = downloadProgress.progress;
                                  return Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 48,
                                          height: 48,
                                          child: CircularProgressIndicator(
                                            value: progress,
                                            strokeWidth: 2.5,
                                            color: AppColors.primaryCta,
                                            backgroundColor: AppColors.white10,
                                          ),
                                        ),
                                        if (progress != null) ...[
                                          const SizedBox(height: 12),
                                          Text(
                                            '${(progress * 100).toInt()}%',
                                            style: const TextStyle(
                                              color: AppColors.textMuted,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  );
                                },
                            errorWidget: (context, url, error) =>
                                _ViewerErrorPlaceholder(
                                  onRetry: () => _retrySignedUrl(rawPath!),
                                ),
                          ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Shared error placeholder for the full-screen image viewer.
/// Displays gradient broken image icon, error text, and animated retry button.
class _ViewerErrorPlaceholder extends StatelessWidget {
  const _ViewerErrorPlaceholder({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) =>
              AppGradients.primaryGradient.createShader(bounds),
          child: const Icon(Icons.broken_image_rounded, size: 56),
        ),
        const SizedBox(height: AppSpacing.md),
        const Text(
          GalleryStrings.failedToLoadImage,
          style: TextStyle(color: AppColors.textMuted, fontSize: 14),
        ),
        const SizedBox(height: AppSpacing.sm),
        AnimatedRetryButton(onPressed: onRetry, color: AppColors.primaryCta),
      ],
    );
  }
}
