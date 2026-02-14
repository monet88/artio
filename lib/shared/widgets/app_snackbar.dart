import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:artio/core/design_system/app_animations.dart';
import 'package:artio/theme/app_colors.dart';

/// Themed snackbar variants — glassmorphism style with slide-in animation.
///
/// Usage:
/// ```dart
/// AppSnackbar.show(
///   context,
///   message: 'Image saved successfully!',
///   type: AppSnackbarType.success,
/// );
/// ```
enum AppSnackbarType { success, error, info, warning }

class AppSnackbar {
  AppSnackbar._();

  /// Show a themed glassmorphism-style snackbar.
  static void show(
    BuildContext context, {
    required String message,
    AppSnackbarType type = AppSnackbarType.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
    bool haptic = true,
  }) {
    if (haptic) {
      switch (type) {
        case AppSnackbarType.success:
          HapticFeedback.mediumImpact();
        case AppSnackbarType.error:
          HapticFeedback.heavyImpact();
        case AppSnackbarType.warning:
          HapticFeedback.lightImpact();
        case AppSnackbarType.info:
          HapticFeedback.selectionClick();
      }
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: duration,
        dismissDirection: DismissDirection.horizontal,
        content: _AppSnackbarContent(
          message: message,
          type: type,
          isDark: isDark,
          actionLabel: actionLabel,
          onAction: onAction,
        ),
      ),
    );
  }

  /// Convenience — success variant
  static void success(BuildContext context, String message) {
    show(context, message: message, type: AppSnackbarType.success);
  }

  /// Convenience — error variant
  static void error(BuildContext context, String message) {
    show(context, message: message, type: AppSnackbarType.error);
  }

  /// Convenience — info variant
  static void info(BuildContext context, String message) {
    show(context, message: message, type: AppSnackbarType.info);
  }

  /// Convenience — warning variant
  static void warning(BuildContext context, String message) {
    show(context, message: message, type: AppSnackbarType.warning);
  }
}

/// Internal widget for the snackbar content.
class _AppSnackbarContent extends StatelessWidget {
  const _AppSnackbarContent({
    required this.message,
    required this.type,
    required this.isDark,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final AppSnackbarType type;
  final bool isDark;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final config = _SnackbarConfig.from(type);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AnimatedContainer(
          duration: AppAnimations.fast,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: isDark
                ? AppColors.darkSurface2.withValues(alpha: 0.85)
                : AppColors.lightSurface1.withValues(alpha: 0.92),
            border: Border.all(
              color: config.color.withValues(alpha: 0.3),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: config.color.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Leading icon with colored circle bg
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: config.color.withValues(alpha: 0.15),
                ),
                child: Icon(
                  config.icon,
                  color: config.color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),

              // Message
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textPrimary
                        : AppColors.textPrimaryLight,
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Action button (optional)
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    onAction!();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: config.color,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    actionLabel!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Configuration per snackbar type.
class _SnackbarConfig {
  final Color color;
  final IconData icon;

  const _SnackbarConfig({required this.color, required this.icon});

  factory _SnackbarConfig.from(AppSnackbarType type) {
    return switch (type) {
      AppSnackbarType.success => const _SnackbarConfig(
          color: AppColors.success,
          icon: Icons.check_circle_rounded,
        ),
      AppSnackbarType.error => const _SnackbarConfig(
          color: AppColors.error,
          icon: Icons.error_rounded,
        ),
      AppSnackbarType.warning => const _SnackbarConfig(
          color: AppColors.warning,
          icon: Icons.warning_amber_rounded,
        ),
      AppSnackbarType.info => const _SnackbarConfig(
          color: AppColors.info,
          icon: Icons.info_rounded,
        ),
    };
  }
}
