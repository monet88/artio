import 'package:artio/core/design_system/app_animations.dart';
import 'package:artio/core/design_system/app_gradients.dart';
import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/core/design_system/app_dimensions.dart';
import 'package:artio/core/design_system/app_typography.dart';
import 'package:artio/shared/widgets/loading_state_widget.dart';
import 'package:artio/theme/app_colors.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/generation_job_model.dart';

/// Redesigned generation progress widget with animated progress bar (gradient),
/// pulsing glow, bounce-in checkmark, shake error, and status text transitions.
class GenerationProgress extends StatefulWidget {
  final GenerationJobModel job;

  const GenerationProgress({super.key, required this.job});

  @override
  State<GenerationProgress> createState() => _GenerationProgressState();
}

class _GenerationProgressState extends State<GenerationProgress>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _completionController;
  late final AnimationController _shakeController;

  late final Animation<double> _bounceScale;
  late final Animation<double> _shakeOffset;

  @override
  void initState() {
    super.initState();

    // Pulsing glow for generating state
    _pulseController = AnimationController(
      vsync: this,
      duration: AppAnimations.ambient,
    );

    // Bounce-in for completion checkmark
    _completionController = AnimationController(
      vsync: this,
      duration: AppAnimations.slow,
    );
    _bounceScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _completionController,
        curve: AppAnimations.bounceCurve,
      ),
    );

    // Shake for error state
    _shakeController = AnimationController(
      vsync: this,
      duration: AppAnimations.normal,
    );
    _shakeOffset = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.elasticIn,
      ),
    );

    _updateAnimations();
  }

  @override
  void didUpdateWidget(covariant GenerationProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.job.status != widget.job.status) {
      _updateAnimations();
    }
  }

  void _updateAnimations() {
    final status = widget.job.status;

    if (status == JobStatus.generating || status == JobStatus.processing) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
    }

    if (status == JobStatus.completed) {
      _completionController.forward(from: 0);
    }

    if (status == JobStatus.failed) {
      _shakeController.forward(from: 0).then((_) {
        // Reset to center after shake completes
        if (mounted) {
          _shakeController.reset();
        }
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _completionController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = widget.job.status;

    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        // Shake offset for error
        final shakeX = _shakeOffset.value *
            8 *
            ((_shakeController.value * 6).toInt().isEven ? 1 : -1);

        return Transform.translate(
          offset: status == JobStatus.failed ? Offset(shakeX, 0) : Offset.zero,
          child: child,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface1,
          borderRadius: BorderRadius.circular(16),
          border: isDark
              ? Border.all(color: AppColors.white10, width: 0.5)
              : null,
          boxShadow: isDark ? null : const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (status == JobStatus.pending ||
                  status == JobStatus.generating ||
                  status == JobStatus.processing) ...[
                // ── Animated Progress Bar ─────────────────────────
                AnimatedBuilder(
                  animation: _pulseController,
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
                              _pulseController.value,
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
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryCta.withValues(
                              alpha: 0.2 + (_pulseController.value * 0.3),
                            ),
                            blurRadius: 16 + (_pulseController.value * 8),
                            spreadRadius: _pulseController.value * 4,
                          ),
                        ],
                      ),
                      child: child,
                    );
                  },
                  child: CircleAvatar(
                    backgroundColor: AppColors.primaryCta.withValues(alpha: 0.15),
                    child: Icon(
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
              ] else if (status == JobStatus.completed) ...[
                // ── Completion Checkmark ───────────────────────────
                ScaleTransition(
                  scale: _bounceScale,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppGradients.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: const [
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

                // Result image
                if (widget.job.resultUrls != null &&
                    widget.job.resultUrls!.isNotEmpty)
                  ClipRRect(
                    borderRadius: AppDimensions.cardRadius,
                    child: Image.network(
                      widget.job.resultUrls!.first,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const LoadingStateWidget();
                      },
                    ),
                  ),
              ] else if (status == JobStatus.failed) ...[
                // ── Error State ───────────────────────────────────
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
                  widget.job.errorMessage ?? 'Generation failed',
                  style: AppTypography.bodySecondary(context).copyWith(
                    color: AppColors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
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
