import 'package:artio/theme/app_colors.dart';
import 'package:artio/theme/app_component_themes.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Artio Design System — Application Theme
///
/// Defines both Light and Dark [ThemeData] using [FlexColorScheme] as a base,
/// then applies custom component themes for a premium, consistent look.
///
/// Component theme details live in [AppComponentThemes].
/// Color palette lives in [AppColors].
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
        appBarTheme: AppComponentThemes.appBar(
          titleColor: AppColors.textPrimaryLight,
          iconColor: AppColors.textPrimaryLight,
          overlayStyle: SystemUiOverlayStyle.dark,
        ),
        cardTheme: AppComponentThemes.card(color: AppColors.lightCard),
        filledButtonTheme:
            AppComponentThemes.filledButton(foreground: Colors.white),
        elevatedButtonTheme:
            AppComponentThemes.elevatedButton(foreground: Colors.white),
        outlinedButtonTheme: AppComponentThemes.outlinedButton,
        textButtonTheme: AppComponentThemes.textButton,
        navigationBarTheme: AppComponentThemes.navigationBar(
          backgroundColor: AppColors.lightSurface1,
          unselectedLabelColor: AppColors.textMutedLight,
          unselectedIconColor: AppColors.textMutedLight,
        ),
        inputDecorationTheme: AppComponentThemes.inputDecoration(
          fillColor: AppColors.lightSurface2,
          hintColor: AppColors.textHintLight,
          labelColor: AppColors.textSecondaryLight,
        ),
        chipTheme: AppComponentThemes.chip(
          backgroundColor: AppColors.lightSurface2,
          labelColor: null,
        ),
        dividerTheme: AppComponentThemes.divider(
          color: AppColors.lightSurface3,
        ),
        snackBarTheme: AppComponentThemes.snackBar(
          backgroundColor: AppColors.textPrimaryLight,
          textColor: Colors.white,
        ),
        bottomSheetTheme: AppComponentThemes.bottomSheet(
          backgroundColor: AppColors.lightSurface1,
          barrierColor: AppColors.black40,
          dragHandleColor: AppColors.lightSurface3,
        ),
        dialogTheme: AppComponentThemes.dialog(
          backgroundColor: AppColors.lightSurface1,
        ),
        pageTransitionsTheme: AppComponentThemes.pageTransitions,
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
        appBarTheme: AppComponentThemes.appBar(
          titleColor: AppColors.textPrimary,
          iconColor: AppColors.textPrimary,
          overlayStyle: SystemUiOverlayStyle.light,
        ),
        cardTheme: AppComponentThemes.card(
          color: AppColors.darkCard,
          borderSide: const BorderSide(
            color: AppColors.darkBorderSubtle,
            width: 0.5,
          ),
        ),
        filledButtonTheme: AppComponentThemes.filledButton(
          foreground: AppColors.darkBackground,
        ),
        elevatedButtonTheme: AppComponentThemes.elevatedButton(
          foreground: AppColors.darkBackground,
        ),
        outlinedButtonTheme: AppComponentThemes.outlinedButton,
        textButtonTheme: AppComponentThemes.textButton,
        navigationBarTheme: AppComponentThemes.navigationBar(
          backgroundColor: AppColors.darkSurface1,
          unselectedLabelColor: AppColors.textMuted,
          unselectedIconColor: AppColors.textMuted,
        ),
        inputDecorationTheme: AppComponentThemes.inputDecoration(
          fillColor: AppColors.darkSurface2,
          hintColor: AppColors.textHint,
          labelColor: AppColors.textSecondary,
          enabledBorderSide: const BorderSide(
            color: AppColors.darkBorderSubtle,
            width: 0.5,
          ),
        ),
        chipTheme: AppComponentThemes.chip(
          backgroundColor: AppColors.darkSurface2,
          labelColor: AppColors.textSecondary,
          shapeSide: const BorderSide(
            color: AppColors.darkBorderSubtle,
            width: 0.5,
          ),
        ),
        dividerTheme: AppComponentThemes.divider(
          color: AppColors.white10,
          thickness: 0.5,
          space: 0.5,
        ),
        snackBarTheme: AppComponentThemes.snackBar(
          backgroundColor: AppColors.darkSurface3,
          textColor: AppColors.textPrimary,
          borderSide: const BorderSide(
            color: AppColors.darkBorderSubtle,
            width: 0.5,
          ),
        ),
        bottomSheetTheme: AppComponentThemes.bottomSheet(
          backgroundColor: AppColors.darkSurface1,
          barrierColor: AppColors.black60,
          dragHandleColor: AppColors.white20,
        ),
        dialogTheme: AppComponentThemes.dialog(
          backgroundColor: AppColors.darkSurface2,
          borderSide: const BorderSide(
            color: AppColors.darkBorderSubtle,
            width: 0.5,
          ),
        ),
        pageTransitionsTheme: AppComponentThemes.pageTransitions,
      );
}
