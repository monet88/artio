import 'package:artio/core/design_system/app_gradients.dart';
import 'package:artio/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Artio Design System — Typography Extensions
///
/// Additional text styles beyond the standard Material [TextTheme].
/// Use these for branded or specialized text treatments.
///
/// All styles use the Inter font family (set via theme).
abstract class AppTypography {
  // ── Display & Heading Extensions ─────────────────────────────────────

  /// Large display text style — used as base for gradient text headings
  static const displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    height: 1.2,
  );

  /// Medium display text style — section titles
  static const displayMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.3,
  );

  /// Small display text style — card titles
  static const displaySmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
  );

  // ── Body Extensions ──────────────────────────────────────────────────

  /// Secondary body text — muted, used for descriptions and subtitles
  static TextStyle bodySecondary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
      height: 1.5,
    );
  }

  /// Muted body text — timestamps, metadata, footnotes
  static TextStyle bodyMuted(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
      height: 1.4,
    );
  }

  // ── Label / Badge Extensions ─────────────────────────────────────────

  /// Badge text — PRO, NEW, etc. (all-caps, bold, small)
  static const labelBadge = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    height: 1,
  );

  /// Badge text — medium size for larger badges
  static const labelBadgeMd = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    height: 1,
  );

  /// Category tag — small chips on cards
  static const labelTag = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    height: 1,
  );

  // ── Caption Extensions ───────────────────────────────────────────────

  /// Caption muted — timestamps, metadata, counts
  static TextStyle captionMuted(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: isDark ? AppColors.textHint : AppColors.textHintLight,
      height: 1.3,
      letterSpacing: 0.2,
    );
  }

  /// Caption emphasis — small but noticeable text
  static const captionEmphasis = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    height: 1.3,
  );

  // ── Button Text Extensions ───────────────────────────────────────────

  /// Large button text
  static const buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1,
  );

  /// Small button text
  static const buttonSmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    height: 1,
  );
}

// ── Gradient Text Widget ───────────────────────────────────────────────

/// A widget that renders text with a gradient shader.
///
/// Usage:
/// ```dart
/// GradientText(
///   'Hello World',
///   style: AppTypography.displayLarge,
///   gradient: AppGradients.primaryGradient,
/// )
/// ```
class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    super.key,
    this.style,
    this.gradient = AppGradients.primaryGradient,
    this.textAlign,
  });

  /// The text to display.
  final String text;

  /// Base text style (color will be overridden by gradient).
  final TextStyle? style;

  /// The gradient to apply. Defaults to [AppGradients.primaryGradient].
  final Gradient gradient;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
      ),
    );
  }
}
