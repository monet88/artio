import 'dart:io';

import 'package:artio/core/design_system/app_animations.dart';
import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/core/design_system/app_typography.dart';
import 'package:artio/core/exceptions/app_exception.dart';
import 'package:artio/shared/widgets/animated_retry_button.dart';
import 'package:artio/shared/widgets/error_illustration.dart';
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
    required this.message, super.key,
    this.onRetry,
    this.category = ErrorCategory.unknown,
  });

  /// Factory to auto-detect error category from exception
  factory ErrorStateWidget.fromError({
    required Object error, required String message, Key? key,
    VoidCallback? onRetry,
  }) {
    return ErrorStateWidget(
      key: key,
      message: message,
      onRetry: onRetry,
      category: _categorize(error),
    );
  }

  final String message;
  final VoidCallback? onRetry;
  final ErrorCategory category;

  static ErrorCategory _categorize(Object error) {
    // Structural matching for AppException types
    if (error is AppException) {
      return switch (error) {
        NetworkException() => ErrorCategory.network,
        StorageException() => ErrorCategory.server,
        GenerationException() => ErrorCategory.server,
        AuthException() => ErrorCategory.unknown,
        PaymentException() => ErrorCategory.unknown,
        UnknownException() => ErrorCategory.unknown,
      };
    }
    // Fallback: platform-level type checks
    if (error is SocketException || error is HttpException) {
      return ErrorCategory.network;
    }
    // Fallback: string matching
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
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1).animate(
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
                ErrorIllustration(
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
                  AnimatedRetryButton(
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

  final IconData icon;
  final Color color;
  final String title;
}
