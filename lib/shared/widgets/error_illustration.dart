import 'package:flutter/material.dart';

/// Circular illustration with glow ring and accent dot for error states.
class ErrorIllustration extends StatelessWidget {
  const ErrorIllustration({
    required this.icon,
    required this.color,
    required this.isDark,
    super.key,
  });

  final IconData icon;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow ring
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withValues(alpha: 0.12),
                  color.withValues(alpha: 0),
                ],
              ),
            ),
          ),

          // Main circle
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
              border: isDark
                  ? Border.all(color: color.withValues(alpha: 0.2), width: 0.5)
                  : null,
            ),
            child: Icon(icon, size: 36, color: color),
          ),

          // Accent dot
          Positioned(
            top: 12,
            right: 16,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
