import 'package:flutter/material.dart';

abstract class AppColors {
  // Brand colors
  static const primaryCta = Color(0xFF3DD598); // Mint green
  static const accent = Color(0xFF9B87F5); // Purple

  // Light theme
  static const lightBackground = Color(0xFFFFFFFF);
  static const lightCard = Colors.white;

  // Dark theme
  static const darkBackground = Color(0xFF0D1025);
  static const darkCard = Color(0xFF1E2342);

  // Semantic
  static const error = Color(0xFFE53935);
  static const success = Color(0xFF43A047);
  static const warning = Color(0xFFFFA726);
}
