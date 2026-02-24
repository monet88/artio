import 'package:artio/core/design_system/app_dimensions.dart';
import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Compact retry button for inline error states (e.g. gallery thumbnails).
///
/// Uses [TextButton.icon] for built-in accessibility (ripple, semantic label,
/// keyboard focus). For full-screen error states, use `AnimatedRetryButton`
/// instead.
class RetryTextButton extends StatelessWidget {
  const RetryTextButton({
    required this.onPressed,
    this.label = 'Retry',
    super.key,
  });

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.refresh_rounded, size: 14),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryCta,
        textStyle: Theme.of(context).textTheme.labelSmall,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        minimumSize: const Size(
          AppDimensions.touchTargetMin,
          AppDimensions.touchTargetMin,
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
