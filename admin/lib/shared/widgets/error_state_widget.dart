import 'package:artio_admin/core/theme/admin_colors.dart';
import 'package:flutter/material.dart';

/// Error category for visual differentiation
enum ErrorCategory { network, server, unknown }

/// Simplified error state widget for admin dashboard.
/// Shows categorized icon, friendly message, and retry button.
class ErrorStateWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final config = _configFor(category);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: config.color.withValues(alpha: 0.12),
              ),
              child: Icon(config.icon, size: 36, color: config.color),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              config.title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AdminColors.textSecondary),
            ),
            const SizedBox(height: 24),

            // Retry button
            if (onRetry != null)
              FilledButton.tonal(
                onPressed: onRetry,
                child: const Text('Try Again'),
              ),
          ],
        ),
      ),
    );
  }

  static _ErrorConfig _configFor(ErrorCategory category) {
    switch (category) {
      case ErrorCategory.network:
        return const _ErrorConfig(
          icon: Icons.wifi_off_rounded,
          color: AdminColors.warning,
          title: 'Connection Lost',
        );
      case ErrorCategory.server:
        return const _ErrorConfig(
          icon: Icons.cloud_off_rounded,
          color: AdminColors.error,
          title: 'Server Issue',
        );
      case ErrorCategory.unknown:
        return const _ErrorConfig(
          icon: Icons.error_outline_rounded,
          color: AdminColors.textMuted,
          title: 'Something Went Wrong',
        );
    }
  }
}

class _ErrorConfig {
  const _ErrorConfig({
    required this.icon,
    required this.color,
    required this.title,
  });

  final IconData icon;
  final Color color;
  final String title;
}
