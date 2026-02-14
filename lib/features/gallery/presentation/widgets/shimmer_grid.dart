import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/design_system/app_dimensions.dart';
import '../../../../core/design_system/app_spacing.dart';

class ShimmerGrid extends StatelessWidget {
  const ShimmerGrid({super.key});

  @override
  Widget build(BuildContext context) {
    // Responsive column count calculation
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
        itemCount: 12, // Show enough items to fill screen
        itemBuilder: (context, index) {
          // Randomized heights for masonry effect
          final height = (index % 3 + 1) * 100.0 + (index % 2 * 50.0);

          return Shimmer.fromColors(
            baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            highlightColor: Theme.of(context).colorScheme.surface,
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
