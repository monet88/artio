import 'package:artio/core/design_system/app_dimensions.dart';
import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';

/// Branded shimmer grid skeleton loader matching the gallery masonry layout.
class ShimmerGrid extends StatelessWidget {
  const ShimmerGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.sizeOf(context).width;
    final int crossAxisCount;
    if (width > 900) {
      crossAxisCount = 4;
    } else if (width > 600) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 2;
    }

    return Padding(
      padding: AppSpacing.cardPadding,
      child: MasonryGridView.count(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        itemCount: 12,
        itemBuilder: (context, index) {
          // Randomized heights for masonry effect
          final height = (index % 3 + 1) * 100.0 + (index % 2 * 50.0);

          return Shimmer.fromColors(
            baseColor: isDark ? AppColors.shimmerBase : const Color(0xFFE8EAF0),
            highlightColor: isDark
                ? AppColors.shimmerHighlight
                : const Color(0xFFF3F4F8),
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppDimensions.cardRadius,
              ),
            ),
          );
        },
      ),
    );
  }
}
