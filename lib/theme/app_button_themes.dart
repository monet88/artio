import 'package:artio/core/design_system/app_dimensions.dart';
import 'package:artio/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Button theme overrides shared between Light and Dark themes.
abstract class AppButtonThemes {
  // ── FilledButton ────────────────────────────────────────────────────
  static FilledButtonThemeData filledButton({required Color foreground}) =>
      FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryCta,
          foregroundColor: foreground,
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: AppDimensions.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
      );

  // ── ElevatedButton ──────────────────────────────────────────────────
  static ElevatedButtonThemeData elevatedButton({required Color foreground}) =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryCta,
          foregroundColor: foreground,
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily: AppDimensions.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
      );

  // ── OutlinedButton ──────────────────────────────────────────────────
  static OutlinedButtonThemeData get outlinedButton => OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primaryCta,
      minimumSize: const Size(double.infinity, 52),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      side: const BorderSide(color: AppColors.primaryCta, width: 1.5),
      textStyle: const TextStyle(
        fontFamily: AppDimensions.fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
    ),
  );

  // ── TextButton ──────────────────────────────────────────────────────
  static TextButtonThemeData get textButton => TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primaryCta,
      textStyle: const TextStyle(
        fontFamily: AppDimensions.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
    ),
  );
}
