import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:artio/theme/app_colors.dart';

/// Artio Design System — Application Theme
///
/// Defines both Light and Dark [ThemeData] using [FlexColorScheme] as a base,
/// then applies custom component themes for a premium, consistent look.
abstract class AppTheme {
  static const _fontFamily = 'Inter';
  static const _borderRadius = 14.0;
  static const _borderRadiusSm = 8.0;
  static const _borderRadiusLg = 20.0;

  // ═══════════════════════════════════════════════════════════════════════
  //  LIGHT THEME
  // ═══════════════════════════════════════════════════════════════════════

  static ThemeData get light => FlexThemeData.light(
        colors: const FlexSchemeColor(
          primary: AppColors.primaryCta,
          primaryContainer: AppColors.primaryLight,
          secondary: AppColors.accent,
          secondaryContainer: AppColors.accentLight,
          tertiary: AppColors.info,
          tertiaryContainer: AppColors.info,
        ),
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 7,
        subThemesData: const FlexSubThemesData(
          defaultRadius: _borderRadius,
          cardRadius: _borderRadius,
          inputDecoratorRadius: _borderRadius,
          filledButtonRadius: _borderRadius,
          elevatedButtonRadius: _borderRadius,
          outlinedButtonRadius: _borderRadius,
          textButtonRadius: _borderRadius,
          dialogRadius: _borderRadiusLg,
          bottomSheetRadius: _borderRadiusLg,
        ),
        fontFamily: _fontFamily,
      ).copyWith(
        scaffoldBackgroundColor: AppColors.lightBackground,
        cardColor: AppColors.lightCard,

        // ── AppBar ─────────────────────────────────────────────────────
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
            letterSpacing: -0.3,
          ),
          iconTheme: IconThemeData(
            color: AppColors.textPrimaryLight,
            size: 24,
          ),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),

        // ── Card ───────────────────────────────────────────────────────
        cardTheme: CardThemeData(
          elevation: 0,
          color: AppColors.lightCard,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.zero,
        ),

        // ── FilledButton ───────────────────────────────────────────────
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryCta,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(
              fontFamily: _fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
            ),
          ),
        ),

        // ── ElevatedButton ─────────────────────────────────────────────
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryCta,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            elevation: 0,
            textStyle: const TextStyle(
              fontFamily: _fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
            ),
          ),
        ),

        // ── OutlinedButton ─────────────────────────────────────────────
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryCta,
            minimumSize: const Size(double.infinity, 52),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            side: const BorderSide(color: AppColors.primaryCta, width: 1.5),
            textStyle: const TextStyle(
              fontFamily: _fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
            ),
          ),
        ),

        // ── TextButton ─────────────────────────────────────────────────
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryCta,
            textStyle: const TextStyle(
              fontFamily: _fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_borderRadiusSm),
            ),
          ),
        ),

        // ── NavigationBar ──────────────────────────────────────────────
        navigationBarTheme: NavigationBarThemeData(
          elevation: 0,
          backgroundColor: AppColors.lightSurface1,
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
            return const TextStyle(
              fontFamily: _fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textMutedLight,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(
                color: AppColors.primaryCta,
                size: 24,
              );
            }
            return const IconThemeData(
              color: AppColors.textMutedLight,
              size: 24,
            );
          }),
        ),

        // ── InputDecoration ────────────────────────────────────────────
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.lightSurface2,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
            borderSide: BorderSide.none,
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
          hintStyle: const TextStyle(
            fontFamily: _fontFamily,
            color: AppColors.textHintLight,
            fontSize: 14,
          ),
          labelStyle: const TextStyle(
            fontFamily: _fontFamily,
            color: AppColors.textSecondaryLight,
            fontSize: 14,
          ),
        ),

        // ── Chip ───────────────────────────────────────────────────────
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.lightSurface2,
          selectedColor: AppColors.primaryCta.withValues(alpha: 0.15),
          checkmarkColor: AppColors.primaryCta,
          labelStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadiusSm),
          ),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),

        // ── Divider ────────────────────────────────────────────────────
        dividerTheme: const DividerThemeData(
          color: AppColors.lightSurface3,
          thickness: 1,
          space: 1,
        ),

        // ── SnackBar ───────────────────────────────────────────────────
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.textPrimaryLight,
          contentTextStyle: const TextStyle(
            fontFamily: _fontFamily,
            color: Colors.white,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
        ),

        // ── Bottom Sheet ───────────────────────────────────────────────
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.lightSurface1,
          surfaceTintColor: Colors.transparent,
          modalBarrierColor: AppColors.black40,
          showDragHandle: true,
          dragHandleColor: AppColors.lightSurface3,
        ),

        // ── Dialog ─────────────────────────────────────────────────────
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.lightSurface1,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadiusLg),
          ),
        ),

        // ── Page Transition ────────────────────────────────────────────
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      );

  // ═══════════════════════════════════════════════════════════════════════
  //  DARK THEME
  // ═══════════════════════════════════════════════════════════════════════

  static ThemeData get dark => FlexThemeData.dark(
        colors: const FlexSchemeColor(
          primary: AppColors.primaryCta,
          primaryContainer: AppColors.primaryDark,
          secondary: AppColors.accent,
          secondaryContainer: AppColors.accentDark,
          tertiary: AppColors.info,
          tertiaryContainer: AppColors.info,
        ),
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 13,
        subThemesData: const FlexSubThemesData(
          defaultRadius: _borderRadius,
          cardRadius: _borderRadius,
          inputDecoratorRadius: _borderRadius,
          filledButtonRadius: _borderRadius,
          elevatedButtonRadius: _borderRadius,
          outlinedButtonRadius: _borderRadius,
          textButtonRadius: _borderRadius,
          dialogRadius: _borderRadiusLg,
          bottomSheetRadius: _borderRadiusLg,
        ),
        fontFamily: _fontFamily,
      ).copyWith(
        scaffoldBackgroundColor: AppColors.darkBackground,
        cardColor: AppColors.darkCard,

        // ── AppBar ─────────────────────────────────────────────────────
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
          iconTheme: IconThemeData(
            color: AppColors.textPrimary,
            size: 24,
          ),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),

        // ── Card ───────────────────────────────────────────────────────
        cardTheme: CardThemeData(
          elevation: 0,
          color: AppColors.darkCard,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
            side: const BorderSide(
              color: AppColors.darkBorderSubtle,
              width: 0.5,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.zero,
        ),

        // ── FilledButton ───────────────────────────────────────────────
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryCta,
            foregroundColor: AppColors.darkBackground,
            minimumSize: const Size(double.infinity, 52),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(
              fontFamily: _fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
            ),
          ),
        ),

        // ── ElevatedButton ─────────────────────────────────────────────
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryCta,
            foregroundColor: AppColors.darkBackground,
            minimumSize: const Size(double.infinity, 52),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            elevation: 0,
            textStyle: const TextStyle(
              fontFamily: _fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
            ),
          ),
        ),

        // ── OutlinedButton ─────────────────────────────────────────────
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryCta,
            minimumSize: const Size(double.infinity, 52),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            side: const BorderSide(color: AppColors.primaryCta, width: 1.5),
            textStyle: const TextStyle(
              fontFamily: _fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
            ),
          ),
        ),

        // ── TextButton ─────────────────────────────────────────────────
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryCta,
            textStyle: const TextStyle(
              fontFamily: _fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_borderRadiusSm),
            ),
          ),
        ),

        // ── NavigationBar ──────────────────────────────────────────────
        navigationBarTheme: NavigationBarThemeData(
          elevation: 0,
          backgroundColor: AppColors.darkSurface1,
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
            return const TextStyle(
              fontFamily: _fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(
                color: AppColors.primaryCta,
                size: 24,
              );
            }
            return const IconThemeData(
              color: AppColors.textMuted,
              size: 24,
            );
          }),
        ),

        // ── InputDecoration ────────────────────────────────────────────
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkSurface2,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
            borderSide: const BorderSide(
              color: AppColors.darkBorderSubtle,
              width: 0.5,
            ),
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
          hintStyle: const TextStyle(
            fontFamily: _fontFamily,
            color: AppColors.textHint,
            fontSize: 14,
          ),
          labelStyle: const TextStyle(
            fontFamily: _fontFamily,
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),

        // ── Chip ───────────────────────────────────────────────────────
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.darkSurface2,
          selectedColor: AppColors.primaryCta.withValues(alpha: 0.15),
          checkmarkColor: AppColors.primaryCta,
          labelStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadiusSm),
            side: const BorderSide(
              color: AppColors.darkBorderSubtle,
              width: 0.5,
            ),
          ),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),

        // ── Divider ────────────────────────────────────────────────────
        dividerTheme: const DividerThemeData(
          color: AppColors.white10,
          thickness: 0.5,
          space: 0.5,
        ),

        // ── SnackBar ───────────────────────────────────────────────────
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.darkSurface3,
          contentTextStyle: const TextStyle(
            fontFamily: _fontFamily,
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
            side: const BorderSide(
              color: AppColors.darkBorderSubtle,
              width: 0.5,
            ),
          ),
        ),

        // ── Bottom Sheet ───────────────────────────────────────────────
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.darkSurface1,
          surfaceTintColor: Colors.transparent,
          modalBarrierColor: AppColors.black60,
          showDragHandle: true,
          dragHandleColor: AppColors.white20,
        ),

        // ── Dialog ─────────────────────────────────────────────────────
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.darkSurface2,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadiusLg),
            side: const BorderSide(
              color: AppColors.darkBorderSubtle,
              width: 0.5,
            ),
          ),
        ),

        // ── Page Transition ────────────────────────────────────────────
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      );
}
