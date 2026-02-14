import 'dart:io';

import 'package:artio/core/design_system/app_animations.dart';
import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/core/design_system/app_typography.dart';
import 'package:artio/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Error category for visual differentiation
enum ErrorCategory {
  network,
  server,
  unknown,
}

/// Redesigned error state widget with categorized illustrations,
/// friendly messaging, and animated retry button.
class ErrorStateWidget extends StatefulWidget {
  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.category = ErrorCategory.unknown,
  });

  final String message;
  final VoidCallback? onRetry;
  final ErrorCategory category;

  /// Factory to auto-detect error category from exception
  factory ErrorStateWidget.fromError({
    Key? key,
    required Object error,
    required String message,
    VoidCallback? onRetry,
  }) {
    return ErrorStateWidget(
      key: key,
      message: message,
      onRetry: onRetry,
      category: _categorize(error),
    );
  }

  static ErrorCategory _categorize(Object error) {
    if (error is SocketException || error is HttpException) {
      return ErrorCategory.network;
    }
    final msg = error.toString().toLowerCase();
    if (msg.contains('socket') ||
        msg.contains('connection') ||
        msg.contains('timeout') ||
        msg.contains('network')) {
      return ErrorCategory.network;
    }
    if (msg.contains('500') ||
        msg.contains('502') ||
        msg.contains('503') ||
        msg.contains('server')) {
      return ErrorCategory.server;
    }
    return ErrorCategory.unknown;
  }

  @override
  State<ErrorStateWidget> createState() => _ErrorStateWidgetState();
}

class _ErrorStateWidgetState extends State<ErrorStateWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.slow,
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.defaultCurve,
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppAnimations.defaultCurve,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config = _ErrorConfig.from(widget.category);

    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Illustration ──────────────────────────────────
                _ErrorIllustration(
                  icon: config.icon,
                  color: config.color,
                  isDark: isDark,
                ),

                const SizedBox(height: AppSpacing.lg),

                // ── Title ─────────────────────────────────────────
                Text(
                  config.title,
                  style: AppTypography.displaySmall.copyWith(
                    color: isDark
                        ? AppColors.textPrimary
                        : AppColors.textPrimaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.sm),

                // ── Message ───────────────────────────────────────
                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySecondary(context),
                ),

                const SizedBox(height: AppSpacing.xl),

                // ── Retry Button ──────────────────────────────────
                if (widget.onRetry != null)
                  _AnimatedRetryButton(
                    onPressed: widget.onRetry!,
                    color: config.color,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Error Configuration ───────────────────────────────────────────────────

class _ErrorConfig {
  const _ErrorConfig({
    required this.icon,
    required this.color,
    required this.title,
  });

  final IconData icon;
  final Color color;
  final String title;

  factory _ErrorConfig.from(ErrorCategory category) {
    switch (category) {
      case ErrorCategory.network:
        return const _ErrorConfig(
          icon: Icons.wifi_off_rounded,
          color: AppColors.warning,
          title: 'Connection Lost',
        );
      case ErrorCategory.server:
        return const _ErrorConfig(
          icon: Icons.cloud_off_rounded,
          color: AppColors.error,
          title: 'Server Issue',
        );
      case ErrorCategory.unknown:
        return const _ErrorConfig(
          icon: Icons.sentiment_dissatisfied_rounded,
          color: AppColors.textMuted,
          title: 'Something Went Wrong',
        );
    }
  }
}

// ── Error Illustration ────────────────────────────────────────────────────

class _ErrorIllustration extends StatelessWidget {
  const _ErrorIllustration({
    required this.icon,
    required this.color,
    required this.isDark,
  });

  final IconData icon;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow ring
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withValues(alpha: 0.12),
                  color.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),

          // Main circle
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
              border: isDark
                  ? Border.all(color: color.withValues(alpha: 0.2), width: 0.5)
                  : null,
            ),
            child: Icon(icon, size: 36, color: color),
          ),

          // Accent dot
          Positioned(
            top: 12,
            right: 16,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Animated Retry Button ─────────────────────────────────────────────────

class _AnimatedRetryButton extends StatefulWidget {
  const _AnimatedRetryButton({
    required this.onPressed,
    required this.color,
  });

  final VoidCallback onPressed;
  final Color color;

  @override
  State<_AnimatedRetryButton> createState() => _AnimatedRetryButtonState();
}

class _AnimatedRetryButtonState extends State<_AnimatedRetryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinController;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _handleRetry() {
    if (_isRetrying) return;
    setState(() => _isRetrying = true);

    // Spin the icon once then trigger retry
    _spinController.forward(from: 0).then((_) {
      if (mounted) {
        setState(() => _isRetrying = false);
        widget.onPressed();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _handleRetry,
      icon: RotationTransition(
        turns: _spinController,
        child: const Icon(Icons.refresh_rounded, size: 20),
      ),
      label: Text(_isRetrying ? 'Retrying...' : 'Try Again'),
      style: OutlinedButton.styleFrom(
        foregroundColor: widget.color,
        side: BorderSide(color: widget.color.withValues(alpha: 0.5), width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
