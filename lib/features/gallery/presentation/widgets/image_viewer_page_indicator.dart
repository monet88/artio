import 'package:artio/core/design_system/app_animations.dart';
import 'package:artio/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Animated dot-style page indicator for the image viewer.
class ImageViewerPageIndicator extends StatelessWidget {
  const ImageViewerPageIndicator({
    required this.itemCount,
    required this.currentIndex,
    super.key,
  });

  final int itemCount;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        itemCount.clamp(0, 10), // Max 10 dots
        (index) {
          final isActive = index == currentIndex;
          return AnimatedContainer(
            duration: AppAnimations.fast,
            curve: AppAnimations.defaultCurve,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: isActive ? 24 : 6,
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: isActive
                  ? AppColors.primaryCta
                  : Colors.white.withValues(alpha: 0.4),
            ),
          );
        },
      ),
    );
  }
}
