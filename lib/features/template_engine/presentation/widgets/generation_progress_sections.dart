import 'package:artio/core/design_system/app_animations.dart';
import 'package:artio/core/design_system/app_dimensions.dart';
import 'package:artio/core/design_system/app_gradients.dart';
import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/core/design_system/app_typography.dart';
import 'package:artio/core/services/storage_url_service.dart';
import 'package:artio/features/template_engine/domain/entities/generation_job_model.dart';
import 'package:artio/shared/widgets/loading_state_widget.dart';
import 'package:artio/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pulsing progress bar + glow ring for generating/processing states.
class ProgressStatusSection extends StatelessWidget {
  const ProgressStatusSection({
    required this.pulseController,
    required this.status,
    super.key,
  });

  final AnimationController pulseController;
  final JobStatus status;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Animated Progress Bar ─────────────────────────
        AnimatedBuilder(
          animation: pulseController,
          builder: (context, _) {
            return Container(
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: isDark
                    ? AppColors.darkSurface3
                    : AppColors.lightSurface3,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color.lerp(
                      AppColors.primaryCta,
                      AppColors.accent,
                      pulseController.value,
                    )!,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.md),

        // Pulsing glow ring
        AnimatedBuilder(
          animation: pulseController,
          builder: (context, child) {
            return Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryCta.withValues(
                      alpha: 0.2 + (pulseController.value * 0.3),
                    ),
                    blurRadius: 16 + (pulseController.value * 8),
                    spreadRadius: pulseController.value * 4,
                  ),
                ],
              ),
              child: child,
            );
          },
          child: CircleAvatar(
            backgroundColor: AppColors.primaryCta.withValues(alpha: 0.15),
            child: const Icon(
              Icons.auto_awesome,
              color: AppColors.primaryCta,
              size: 22,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Status text
        AnimatedSwitcher(
          duration: AppAnimations.fast,
          child: Text(
            _getStatusText(status),
            key: ValueKey(status),
            style: AppTypography.bodySecondary(context),
          ),
        ),
      ],
    );
  }

  String _getStatusText(JobStatus status) {
    switch (status) {
      case JobStatus.pending:
        return 'Queued — waiting for your turn...';
      case JobStatus.generating:
        return 'Creating your masterpiece ✨';
      case JobStatus.processing:
        return 'Almost there — applying finishing touches...';
      case JobStatus.completed:
        return 'Completed';
      case JobStatus.failed:
        return 'Failed';
    }
  }
}

/// Bounce-in checkmark + result image for completed state.
class CompletedStatusSection extends StatelessWidget {
  const CompletedStatusSection({
    required this.bounceScale,
    required this.resultUrls,
    super.key,
  });

  final Animation<double> bounceScale;
  final List<String>? resultUrls;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: bounceScale,
          child: Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              gradient: AppGradients.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x403DD598),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (resultUrls != null && resultUrls!.isNotEmpty)
          _SignedStorageImage(storagePath: resultUrls!.first),
      ],
    );
  }
}

/// Resolves a Supabase storage path to a signed URL before displaying.
/// Prevents `Invalid argument: No host specified` errors from raw storage paths.
class _SignedStorageImage extends ConsumerWidget {
  const _SignedStorageImage({required this.storagePath});

  final String storagePath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urlAsync = ref.watch(signedStorageUrlProvider(storagePath));

    return urlAsync.when(
      loading: () => const LoadingStateWidget(),
      error: (_, __) => Icon(
        Icons.broken_image_outlined,
        size: 48,
        color: AppColors.error.withValues(alpha: 0.5),
      ),
      data: (url) {
        if (url == null) {
          return Icon(
            Icons.broken_image_outlined,
            size: 48,
            color: AppColors.error.withValues(alpha: 0.5),
          );
        }
        return ClipRRect(
          borderRadius: AppDimensions.cardRadius,
          child: Image.network(
            url,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const LoadingStateWidget();
            },
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.broken_image_outlined,
              size: 48,
              color: AppColors.error.withValues(alpha: 0.5),
            ),
          ),
        );
      },
    );
  }
}

/// Error icon + message for failed state.
class ErrorStatusSection extends StatelessWidget {
  const ErrorStatusSection({required this.errorMessage, super.key});

  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 32,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          errorMessage ?? 'Generation failed',
          style: AppTypography.bodySecondary(
            context,
          ).copyWith(color: AppColors.error),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
