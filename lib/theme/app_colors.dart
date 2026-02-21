import 'package:flutter/material.dart';

/// Artio Design System — Color Palette
///
/// All colors are `const` and organized by purpose.
/// Supports both Light and Dark themes.
abstract class AppColors {
  // ── Brand Colors ──────────────────────────────────────────────────────
  /// Primary CTA — Mint green, used for main actions and highlights
  static const primaryCta = Color(0xFF3DD598);

  /// Accent — Rich purple, used for secondary emphasis
  static const accent = Color(0xFF9B87F5);

  // ── Accent Variants ──────────────────────────────────────────────────
  /// Lighter accent for backgrounds, badges, and subtle highlights
  static const accentLight = Color(0xFFBFADF9);

  /// Darker accent for pressed states and emphasis
  static const accentDark = Color(0xFF7B62E0);

  /// Lighter primary for backgrounds and badges
  static const primaryLight = Color(0xFF7AE8BF);

  /// Darker primary for pressed states
  static const primaryDark = Color(0xFF2BA878);

  // ── Gradient Colors ──────────────────────────────────────────────────
  /// Gradient start/end pairs for CTA elements
  static const gradientStart = Color(0xFF3DD598);
  static const gradientEnd = Color(0xFF9B87F5);

  /// Card overlay gradient (used on template thumbnails)
  static const cardOverlayStart = Color(0x00000000);
  static const cardOverlayEnd = Color(0xCC000000);

  /// Background gradient for splash & auth screens
  static const bgGradientStart = Color(0xFF0D1025);
  static const bgGradientMid = Color(0xFF151A3A);
  static const bgGradientEnd = Color(0xFF1A1F45);

  /// Shimmer gradient colors
  static const shimmerBase = Color(0xFF1E2342);
  static const shimmerHighlight = Color(0xFF2A3060);

  // ── Light Theme ──────────────────────────────────────────────────────
  static const lightBackground = Color(0xFFF8F9FC);
  static const lightCard = Colors.white;

  /// Surface variants — increasing depth for Light mode
  static const lightSurface1 = Color(0xFFFFFFFF);
  static const lightSurface2 = Color(0xFFF3F4F8);
  static const lightSurface3 = Color(0xFFE8EAF0);

  // ── Dark Theme ───────────────────────────────────────────────────────
  static const darkBackground = Color(0xFF0D1025);
  static const darkCard = Color(0xFF1E2342);

  /// Surface variants — increasing depth for Dark mode
  static const darkSurface1 = Color(0xFF141730);
  static const darkSurface2 = Color(0xFF1E2342);
  static const darkSurface3 = Color(0xFF282E55);

  /// Elevated surface — used for cards/panels that need to "float"
  static const darkSurfaceElevated = Color(0xFF2F3566);

  /// Subtle border for dark mode cards, chips, inputs (WCAG compliant)
  static const darkBorderSubtle = Color(0x26FFFFFF); // ~15% white

  // ── Overlay Colors ───────────────────────────────────────────────────
  /// Black overlays with controlled opacity
  static const black05 = Color(0x0D000000);
  static const black10 = Color(0x1A000000);
  static const black20 = Color(0x33000000);
  static const black40 = Color(0x66000000);
  static const black60 = Color(0x99000000);

  /// White overlays with controlled opacity
  static const white05 = Color(0x0DFFFFFF);
  static const white10 = Color(0x1AFFFFFF);
  static const white20 = Color(0x33FFFFFF);
  static const white40 = Color(0x66FFFFFF);
  static const white60 = Color(0x99FFFFFF);

  // ── Semantic Colors ──────────────────────────────────────────────────
  static const error = Color(0xFFEF5350);
  static const success = Color(0xFF66BB6A);
  static const warning = Color(0xFFFFB74D);
  static const info = Color(0xFF42A5F5);

  /// Premium badge accent
  static const premium = Color(0xFFFFA500);
  static const premiumBadgeBackground = Color(0x26FFA500);

  /// Semantic colors with better contrast for dark backgrounds
  static const errorDark = Color(0xFFEF9A9A);
  static const successDark = Color(0xFFA5D6A7);
  static const warningDark = Color(0xFFFFE082);
  static const infoDark = Color(0xFF90CAF9);

  /// Semantic text/icon on dark surfaces
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xB3FFFFFF); // 70% white
  static const textMuted = Color(0x80FFFFFF); // 50% white
  static const textHint = Color(0x4DFFFFFF); // 30% white

  /// Light mode text
  static const textPrimaryLight = Color(0xFF1A1D2E);
  static const textSecondaryLight = Color(0xFF6B7082);
  static const textMutedLight = Color(0xFF9CA0AF);
  static const textHintLight = Color(0xFFBCC0CC);
}
