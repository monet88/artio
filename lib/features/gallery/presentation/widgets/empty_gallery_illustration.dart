import 'package:artio/core/design_system/app_gradients.dart';
import 'package:artio/core/design_system/app_typography.dart';
import 'package:artio/theme/app_colors.dart';
import 'package:flutter/material.dart';

// ── Empty Gallery Illustration (widget-based) ─────────────────────────────

class EmptyIllustration extends StatelessWidget {
  const EmptyIllustration({required this.isDark, super.key});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle glow
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primaryCta.withValues(alpha: 0.12),
                  AppColors.primaryCta.withValues(alpha: 0),
                ],
              ),
            ),
          ),

          // Main circle
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
              border: isDark
                  ? Border.all(color: AppColors.white10, width: 0.5)
                  : null,
            ),
            child: Icon(
              Icons.photo_library_outlined,
              size: 40,
              color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
            ),
          ),

          // Floating sparkle top-right
          Positioned(
            top: 16,
            right: 20,
            child: Icon(
              Icons.auto_awesome,
              size: 20,
              color: AppColors.primaryCta.withValues(alpha: 0.6),
            ),
          ),

          // Small dot bottom-left
          Positioned(
            bottom: 24,
            left: 24,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.5),
              ),
            ),
          ),

          // Medium dot top-left
          Positioned(
            top: 32,
            left: 28,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryCta.withValues(alpha: 0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Gradient CTA Button ───────────────────────────────────────────────────

class GradientCTAButton extends StatelessWidget {
  const GradientCTAButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    super.key,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      constraints: const BoxConstraints(maxWidth: 260),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x333DD598),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTypography.buttonLarge.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
