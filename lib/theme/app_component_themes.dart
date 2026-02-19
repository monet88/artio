import 'package:artio/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

export 'app_button_themes.dart';

/// Component theme overrides shared between Light and Dark themes.
///
/// Each method returns the fully configured component theme.
/// Parameters are only those values that differ between light/dark.
abstract class AppComponentThemes {
  static const _fontFamily = 'Inter';
  static const _borderRadius = 14.0;
  static const _borderRadiusSm = 8.0;
  static const _borderRadiusLg = 20.0;

  // ── AppBar ──────────────────────────────────────────────────────────
  static AppBarTheme appBar({
    required Color titleColor,
    required Color iconColor,
    required SystemUiOverlayStyle overlayStyle,
  }) =>
      AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: titleColor,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: iconColor, size: 24),
        systemOverlayStyle: overlayStyle,
      );

  // ── Card ─────────────────────────────────────────────────────────────
  static CardThemeData card({
    required Color color,
    BorderSide? borderSide,
  }) =>
      CardThemeData(
        elevation: 0,
        color: color,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          side: borderSide ?? BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      );

  // ── NavigationBar ───────────────────────────────────────────────────
  static NavigationBarThemeData navigationBar({
    required Color backgroundColor,
    required Color unselectedLabelColor,
    required Color unselectedIconColor,
  }) =>
      NavigationBarThemeData(
        elevation: 0,
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primaryCta.withValues(alpha: 0.15),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadiusLg),
        ),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontFamily: _fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryCta,
            );
          }
          return TextStyle(
            fontFamily: _fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: unselectedLabelColor,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: AppColors.primaryCta,
              size: 24,
            );
          }
          return IconThemeData(color: unselectedIconColor, size: 24);
        }),
      );

  // ── InputDecoration ─────────────────────────────────────────────────
  static InputDecorationTheme inputDecoration({
    required Color fillColor,
    required Color hintColor,
    required Color labelColor,
    BorderSide? enabledBorderSide,
  }) =>
      InputDecorationTheme(
        filled: true,
        fillColor: fillColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: enabledBorderSide ?? BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide:
              const BorderSide(color: AppColors.primaryCta, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: TextStyle(
          fontFamily: _fontFamily,
          color: hintColor,
          fontSize: 14,
        ),
        labelStyle: TextStyle(
          fontFamily: _fontFamily,
          color: labelColor,
          fontSize: 14,
        ),
      );

  // ── Chip ─────────────────────────────────────────────────────────────
  static ChipThemeData chip({
    required Color backgroundColor,
    required Color? labelColor,
    BorderSide? shapeSide,
  }) =>
      ChipThemeData(
        backgroundColor: backgroundColor,
        selectedColor: AppColors.primaryCta.withValues(alpha: 0.15),
        checkmarkColor: AppColors.primaryCta,
        labelStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: labelColor,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadiusSm),
          side: shapeSide ?? BorderSide.none,
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      );

  // ── SnackBar ─────────────────────────────────────────────────────────
  static SnackBarThemeData snackBar({
    required Color backgroundColor,
    required Color textColor,
    BorderSide? borderSide,
  }) =>
      SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
        contentTextStyle: TextStyle(
          fontFamily: _fontFamily,
          color: textColor,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          side: borderSide ?? BorderSide.none,
        ),
      );

  // ── Bottom Sheet ────────────────────────────────────────────────────
  static BottomSheetThemeData bottomSheet({
    required Color backgroundColor,
    required Color barrierColor,
    required Color dragHandleColor,
  }) =>
      BottomSheetThemeData(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: barrierColor,
        showDragHandle: true,
        dragHandleColor: dragHandleColor,
      );

  // ── Dialog ──────────────────────────────────────────────────────────
  static DialogThemeData dialog({
    required Color backgroundColor,
    BorderSide? borderSide,
  }) =>
      DialogThemeData(
        backgroundColor: backgroundColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadiusLg),
          side: borderSide ?? BorderSide.none,
        ),
      );

  // ── Divider ─────────────────────────────────────────────────────────
  static DividerThemeData divider({
    required Color color,
    double thickness = 1,
    double space = 1,
  }) =>
      DividerThemeData(color: color, thickness: thickness, space: space);

  // ── Page Transition ─────────────────────────────────────────────────
  static const pageTransitions = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  );
}
