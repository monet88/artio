import 'package:flutter/material.dart';
import 'admin_colors.dart';

/// Artio Admin — Theme configuration
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AdminColors.primary,
        secondary: AdminColors.accent,
        error: AdminColors.error,
      ),
      scaffoldBackgroundColor: AdminColors.lightBackground,
      inputDecorationTheme: _inputDecoration(Brightness.light),
      cardTheme: _cardTheme(Brightness.light),
      appBarTheme: _appBarTheme(Brightness.light),
      navigationRailTheme: _navRailTheme(Brightness.light),
      chipTheme: _chipTheme(Brightness.light),
      tabBarTheme: _tabBarTheme(Brightness.light),
      dividerTheme: const DividerThemeData(space: 1, thickness: 1),
      filledButtonTheme: _filledButtonTheme(),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AdminColors.primary,
        secondary: AdminColors.accent,
        surface: AdminColors.surface,
        error: AdminColors.error,
      ),
      scaffoldBackgroundColor: AdminColors.background,
      inputDecorationTheme: _inputDecoration(Brightness.dark),
      dialogTheme: const DialogThemeData(
        backgroundColor: AdminColors.surfaceContainer,
      ),
      cardTheme: _cardTheme(Brightness.dark),
      appBarTheme: _appBarTheme(Brightness.dark),
      navigationRailTheme: _navRailTheme(Brightness.dark),
      chipTheme: _chipTheme(Brightness.dark),
      tabBarTheme: _tabBarTheme(Brightness.dark),
      dividerTheme: const DividerThemeData(
        space: 1,
        thickness: 1,
        color: AdminColors.borderSubtle,
      ),
      filledButtonTheme: _filledButtonTheme(),
    );
  }

  // ── Component Themes ────────────────────────────────────────────────

  static InputDecorationTheme _inputDecoration(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return InputDecorationTheme(
      filled: true,
      fillColor: isDark ? AdminColors.surfaceContainer : AdminColors.lightSurfaceContainer,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isDark ? AdminColors.borderSubtle : Colors.grey.shade300,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isDark ? AdminColors.borderSubtle : Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AdminColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  static CardThemeData _cardTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return CardThemeData(
      color: isDark ? AdminColors.surfaceContainer : AdminColors.lightSurface,
      elevation: isDark ? 0 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDark
            ? const BorderSide(color: AdminColors.borderSubtle)
            : BorderSide.none,
      ),
      margin: EdgeInsets.zero,
    );
  }

  static AppBarTheme _appBarTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: isDark ? AdminColors.surface : AdminColors.lightSurface,
      foregroundColor: isDark ? AdminColors.textPrimary : Colors.black87,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: isDark ? AdminColors.textPrimary : Colors.black87,
      ),
    );
  }

  static NavigationRailThemeData _navRailTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return NavigationRailThemeData(
      backgroundColor: isDark ? AdminColors.surface : AdminColors.lightSurface,
      selectedIconTheme: const IconThemeData(color: AdminColors.primary),
      unselectedIconTheme: IconThemeData(
        color: isDark ? AdminColors.textMuted : Colors.grey.shade600,
      ),
      selectedLabelTextStyle: const TextStyle(
        color: AdminColors.primary,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: isDark ? AdminColors.textMuted : Colors.grey.shade600,
        fontSize: 12,
      ),
      indicatorColor: AdminColors.primary.withValues(alpha: 0.15),
    );
  }

  static ChipThemeData _chipTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ChipThemeData(
      backgroundColor: isDark ? AdminColors.surfaceContainer : AdminColors.lightSurfaceContainer,
      selectedColor: AdminColors.primary.withValues(alpha: 0.2),
      side: BorderSide(
        color: isDark ? AdminColors.borderSubtle : Colors.grey.shade300,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      labelStyle: TextStyle(
        color: isDark ? AdminColors.textSecondary : Colors.black87,
        fontSize: 13,
      ),
    );
  }

  static TabBarThemeData _tabBarTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return TabBarThemeData(
      indicatorColor: AdminColors.primary,
      labelColor: AdminColors.primary,
      unselectedLabelColor: isDark ? AdminColors.textMuted : Colors.grey.shade600,
      indicatorSize: TabBarIndicatorSize.label,
      dividerHeight: 1,
      dividerColor: isDark ? AdminColors.borderSubtle : Colors.grey.shade200,
    );
  }

  static FilledButtonThemeData _filledButtonTheme() {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AdminColors.primary,
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    );
  }
}
