import 'package:artio/core/design_system/app_animations.dart';
import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/features/template_engine/domain/entities/generation_job_model.dart';
import 'package:artio/features/template_engine/presentation/widgets/generation_progress_sections.dart';
import 'package:artio/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Redesigned generation progress widget with animated progress bar (gradient),
/// pulsing glow, bounce-in checkmark, shake error, and status text transitions.
class GenerationProgress extends StatefulWidget {
  const GenerationProgress({required this.job, super.key});
  final GenerationJobModel job;

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
    _bounceScale = Tween<double>(begin: 0, end: 1).animate(
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
    _shakeOffset = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
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
        final shakeX =
            _shakeOffset.value *
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
          boxShadow: isDark
              ? null
              : const [
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
                  status == JobStatus.processing)
                ProgressStatusSection(
                  pulseController: _pulseController,
                  status: status,
                )
              else if (status == JobStatus.completed)
                CompletedStatusSection(
                  bounceScale: _bounceScale,
                  resultUrls: widget.job.resultUrls,
                )
              else if (status == JobStatus.failed)
                ErrorStatusSection(errorMessage: widget.job.errorMessage),
            ],
          ),
        ),
      ),
    );
  }
}
