import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract class AppTheme {
  static const _fontFamily = 'Inter';
  static const _borderRadius = 14.0;

  static ThemeData get light => FlexThemeData.light(
        colors: const FlexSchemeColor(
          primary: AppColors.primaryCta,
          primaryContainer: AppColors.primaryCta,
          secondary: AppColors.accent,
          secondaryContainer: AppColors.accent,
          tertiary: AppColors.accent,
          tertiaryContainer: AppColors.accent,
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
        ),
        fontFamily: _fontFamily,
        useMaterial3: true,
      );

  static ThemeData get dark => FlexThemeData.dark(
        colors: const FlexSchemeColor(
          primary: AppColors.primaryCta,
          primaryContainer: AppColors.primaryCta,
          secondary: AppColors.accent,
          secondaryContainer: AppColors.accent,
          tertiary: AppColors.accent,
          tertiaryContainer: AppColors.accent,
        ),
        surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
        blendLevel: 13,
        darkIsTrueBlack: false,
        subThemesData: const FlexSubThemesData(
          defaultRadius: _borderRadius,
          cardRadius: _borderRadius,
          inputDecoratorRadius: _borderRadius,
          filledButtonRadius: _borderRadius,
          elevatedButtonRadius: _borderRadius,
          outlinedButtonRadius: _borderRadius,
          textButtonRadius: _borderRadius,
        ),
        fontFamily: _fontFamily,
        useMaterial3: true,
      ).copyWith(
        scaffoldBackgroundColor: AppColors.darkBackground,
        cardColor: AppColors.darkCard,
      );
}
