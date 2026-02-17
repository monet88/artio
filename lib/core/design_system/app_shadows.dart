import 'package:flutter/material.dart';

/// Artio Design System — Shadow Definitions
///
/// Provides consistent elevation and depth styling across the app.
/// Dark mode uses colored shadows (brand glow), light mode uses gray shadows.
abstract class AppShadows {
  // ── Card Shadows ─────────────────────────────────────────────────────
  /// Standard elevated card (used in template grid, settings cards)
  static const cardShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  /// Subtle card shadow for dark mode (colored glow effect)
  static const cardShadowDark = [
    BoxShadow(
      color: Color(0x209B87F5), // Accent purple glow
      blurRadius: 16,
      offset: Offset(0, 4),
      spreadRadius: -2,
    ),
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  // ── Button Shadows ───────────────────────────────────────────────────
  /// Primary CTA button glow (mint green)
  static const buttonShadow = [
    BoxShadow(
      color: Color(0x4D3DD598), // Primary CTA 30% opacity
      blurRadius: 16,
      offset: Offset(0, 6),
      spreadRadius: -2,
    ),
  ];

  /// Accent button glow (purple)
  static const buttonShadowAccent = [
    BoxShadow(
      color: Color(0x4D9B87F5), // Accent 30% opacity
      blurRadius: 16,
      offset: Offset(0, 6),
      spreadRadius: -2,
    ),
  ];

  /// Gradient button glow — combines both brand colors
  static const buttonShadowGradient = [
    BoxShadow(
      color: Color(0x333DD598),
      blurRadius: 20,
      offset: Offset(-4, 6),
      spreadRadius: -2,
    ),
    BoxShadow(
      color: Color(0x339B87F5),
      blurRadius: 20,
      offset: Offset(4, 6),
      spreadRadius: -2,
    ),
  ];

  // ── Navigation Shadows ───────────────────────────────────────────────
  /// Bottom navigation bar — separation from content
  static const bottomNavShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 20,
      offset: Offset(0, -4),
    ),
  ];

  /// Bottom nav shadow for dark mode
  static const bottomNavShadowDark = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 24,
      offset: Offset(0, -6),
    ),
  ];

  // ── Utility Shadows ──────────────────────────────────────────────────
  /// Floating elements (FAB, dropdown, dialogs)
  static const floatingShadow = [
    BoxShadow(
      color: Color(0x26000000),
      blurRadius: 24,
      offset: Offset(0, 8),
      spreadRadius: -4,
    ),
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Subtle inner shadow for input fields
  static const inputShadow = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 4,
      offset: Offset(0, 2),
      spreadRadius: -1,
    ),
  ];
}
