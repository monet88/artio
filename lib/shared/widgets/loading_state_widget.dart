import 'package:artio/core/design_system/app_animations.dart';
import 'package:artio/core/design_system/app_gradients.dart';
import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/core/design_system/app_typography.dart';
import 'package:artio/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Branded loading widget with pulsing logo, optional contextual message,
/// and skeleton loading variant.
class LoadingStateWidget extends StatefulWidget {
  const LoadingStateWidget({
    super.key,
    this.message,
    this.compact = false,
  });

  /// Optional contextual message shown below the loading indicator.
  final String? message;

  /// If true, shows a smaller centered spinner (for inline usage).
  final bool compact;

  @override
  State<LoadingStateWidget> createState() => _LoadingStateWidgetState();
}

class _LoadingStateWidgetState extends State<LoadingStateWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: AppAnimations.ambient,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.primaryCta.withValues(alpha: 0.7),
            ),
          ),
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Pulsing Branded Logo ─────────────────────────────
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale = 0.9 + (_pulseController.value * 0.1);
              final glowOpacity = 0.1 + (_pulseController.value * 0.15);

              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryCta.withValues(alpha: glowOpacity),
                        blurRadius: 24,
                        spreadRadius: _pulseController.value * 4,
                      ),
                    ],
                  ),
                  child: child,
                ),
              );
            },
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: AppGradients.primaryGradient,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Center(
                child: Text(
                  'A',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── Progress Indicator ───────────────────────────────
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primaryCta.withValues(alpha: 0.6),
              ),
            ),
          ),

          // ── Message ─────────────────────────────────────────
          if (widget.message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              widget.message!,
              style: AppTypography.bodySecondary(context),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Skeleton loading placeholder — use for content areas like cards/lists.
class SkeletonLoader extends StatefulWidget {
  const SkeletonLoader({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * _shimmerController.value, 0),
              end: Alignment(1.0 + 2.0 * _shimmerController.value, 0),
              colors: isDark
                  ? const [
                      AppColors.shimmerBase,
                      AppColors.shimmerHighlight,
                      AppColors.shimmerBase,
                    ]
                  : const [
                      Color(0xFFE8EAF0),
                      Color(0xFFF3F4F8),
                      Color(0xFFE8EAF0),
                    ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}
