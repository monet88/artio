import 'package:flutter/material.dart';

import '../../../../core/design_system/app_dimensions.dart';
import '../../../../core/design_system/app_spacing.dart';
import '../../../../routing/routes/app_routes.dart';

class EmptyGalleryState extends StatelessWidget {
  const EmptyGalleryState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: AppDimensions.iconXxl,
              color: Theme.of(context).colorScheme.outline,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'No images yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Start generating to see your creations here',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: () => const HomeRoute().go(context),
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('Create New'),
            ),
          ],
        ),
      ),
    );
  }
}
