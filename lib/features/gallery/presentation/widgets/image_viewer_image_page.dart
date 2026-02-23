import 'package:artio/core/design_system/app_gradients.dart';
import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/core/services/storage_url_service.dart';
import 'package:artio/features/gallery/domain/entities/gallery_item.dart';
import 'package:artio/shared/widgets/watermark_overlay.dart';
import 'package:artio/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Single image page in the image viewer's PageView.
class ImageViewerImagePage extends ConsumerWidget {
  const ImageViewerImagePage({
    required this.item,
    this.showWatermark = false,
    super.key,
  });

  final GalleryItem item;
  final bool showWatermark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rawPath = item.imageUrl;
    final signedUrlAsync = rawPath != null
        ? ref.watch(signedStorageUrlProvider(rawPath))
        : null;

    return WatermarkOverlay(
      showWatermark: showWatermark,
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
                    error: (_, __) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (bounds) =>
                              AppGradients.primaryGradient.createShader(bounds),
                          child: const Icon(
                            Icons.broken_image_rounded,
                            size: 56,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const Text(
                          'Failed to load image',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        GestureDetector(
                          onTap: () => ref.invalidate(
                            signedStorageUrlProvider(rawPath!),
                          ),
                          child: const Text(
                            'Retry',
                            style: TextStyle(
                              color: AppColors.primaryCta,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    data: (signedUrl) => signedUrl == null
                        ? const SizedBox.shrink()
                        : Image.network(
                            signedUrl,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              final progress =
                                  loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null;
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
                            errorBuilder: (context, error, stackTrace) =>
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ShaderMask(
                                      blendMode: BlendMode.srcIn,
                                      shaderCallback: (bounds) => AppGradients
                                          .primaryGradient
                                          .createShader(bounds),
                                      child: const Icon(
                                        Icons.broken_image_rounded,
                                        size: 56,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    const Text(
                                      'Failed to load image',
                                      style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    GestureDetector(
                                      onTap: () => ref.invalidate(
                                        signedStorageUrlProvider(rawPath!),
                                      ),
                                      child: const Text(
                                        'Retry',
                                        style: TextStyle(
                                          color: AppColors.primaryCta,
                                          fontSize: 14,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                          ),
                  ),
          ),
        ),
      ),
    );
  }
}
