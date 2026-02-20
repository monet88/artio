import 'package:artio/core/design_system/app_gradients.dart';
import 'package:artio/core/design_system/app_typography.dart';
import 'package:artio/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Gradient CTA button used in auth screens.
class GradientButton extends StatelessWidget {
  const GradientButton({
    required this.onPressed, required this.label, super.key,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: onPressed != null
              ? AppGradients.primaryGradient
              : null,
          color: onPressed == null ? AppColors.textMuted : null,
          borderRadius: BorderRadius.circular(14),
          boxShadow: onPressed != null
              ? const [
                  BoxShadow(
                    color: Color(0x333DD598),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(14),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : ExcludeSemantics(
                      child: Text(
                        label,
                        style: AppTypography.buttonLarge.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
