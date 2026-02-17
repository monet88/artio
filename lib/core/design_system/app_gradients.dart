import 'package:artio/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Artio Design System — Gradient Definitions
///
/// Provides reusable gradient objects for consistent styling.
/// All gradients reference [AppColors] to maintain single source of truth.
abstract class AppGradients {
  // ── Primary / CTA Gradient ───────────────────────────────────────────
  /// Mint-green → Purple — used for CTA buttons, accent areas, highlights
  static const primaryGradient = LinearGradient(
    colors: [AppColors.gradientStart, AppColors.gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Horizontal variant for wider elements (pills, tabs)
  static const primaryHorizontal = LinearGradient(
    colors: [AppColors.gradientStart, AppColors.gradientEnd],
  );

  // ── Card Overlay Gradient ────────────────────────────────────────────
  /// Transparent → Dark black — text overlay on template thumbnails
  static const cardOverlay = LinearGradient(
    colors: [AppColors.cardOverlayStart, AppColors.cardOverlayEnd],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.3, 1.0],
  );

  /// Subtle version for lighter overlays
  static const cardOverlaySubtle = LinearGradient(
    colors: [
      Color(0x00000000),
      Color(0x80000000),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.5, 1.0],
  );

  // ── Background Gradients ─────────────────────────────────────────────
  /// Full-screen background gradient for splash/auth screens (dark theme)
  static const backgroundGradient = LinearGradient(
    colors: [
      AppColors.bgGradientStart,
      AppColors.bgGradientMid,
      AppColors.bgGradientEnd,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.5, 1.0],
  );

  /// Radial glow effect for behind-logo or hero elements
  static const backgroundRadial = RadialGradient(
    colors: [
      Color(0x403DD598), // Primary CTA with low opacity
      Color(0x209B87F5), // Accent with lower opacity
      Color(0x000D1025), // Transparent background
    ],
    radius: 0.8,
    stops: [0.0, 0.4, 1.0],
  );

  // ── Shimmer Gradient ─────────────────────────────────────────────────
  /// Loading shimmer effect — used for skeleton placeholders
  static const shimmerGradient = LinearGradient(
    colors: [
      AppColors.shimmerBase,
      AppColors.shimmerHighlight,
      AppColors.shimmerBase,
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment(-1, -0.3),
    end: Alignment(1, 0.3),
  );

  /// Light mode shimmer variant
  static const shimmerGradientLight = LinearGradient(
    colors: [
      Color(0xFFE8EAF0),
      Color(0xFFF3F4F8),
      Color(0xFFE8EAF0),
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment(-1, -0.3),
    end: Alignment(1, 0.3),
  );

  // ── Glass / Frosted Gradient ─────────────────────────────────────────
  /// Glassmorphism overlay for cards and panels
  static const glassOverlay = LinearGradient(
    colors: [
      Color(0x20FFFFFF),
      Color(0x08FFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
