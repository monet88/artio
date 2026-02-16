import 'package:flutter/material.dart';

/// Admin Dashboard color palette — derived from Artio brand
abstract class AdminColors {
  // ── Brand ─────────────────────────────────────────────────────────────
  static const primary = Color(0xFF3DD598); // Mint green
  static const accent = Color(0xFF9B87F5); // Purple
  static const accentLight = Color(0xFFBFADF9);
  static const primaryDark = Color(0xFF2BA878);

  // ── Dark Surfaces ─────────────────────────────────────────────────────
  static const background = Color(0xFF0D1025);
  static const surface = Color(0xFF141730);
  static const surfaceContainer = Color(0xFF1E2342);
  static const surfaceElevated = Color(0xFF282E55);
  static const surfaceBright = Color(0xFF2F3566);

  // ── Light Surfaces ────────────────────────────────────────────────────
  static const lightBackground = Color(0xFFF8F9FC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceContainer = Color(0xFFF3F4F8);

  // ── Text ──────────────────────────────────────────────────────────────
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xB3FFFFFF); // 70%
  static const textMuted = Color(0x80FFFFFF); // 50%
  static const textHint = Color(0x4DFFFFFF); // 30%

  // ── Semantic ──────────────────────────────────────────────────────────
  static const error = Color(0xFFEF5350);
  static const success = Color(0xFF66BB6A);
  static const warning = Color(0xFFFFB74D);
  static const info = Color(0xFF42A5F5);

  // ── Border ────────────────────────────────────────────────────────────
  static const borderSubtle = Color(0x26FFFFFF); // ~15% white

  // ── Stat Card Colors ──────────────────────────────────────────────────
  static const statBlue = Color(0xFF5B8DEF);
  static const statGreen = Color(0xFF3DD598);
  static const statAmber = Color(0xFFFFB74D);
  static const statPurple = Color(0xFF9B87F5);
}
