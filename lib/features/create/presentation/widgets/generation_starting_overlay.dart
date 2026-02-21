import 'package:artio/core/design_system/app_spacing.dart';
import 'package:flutter/material.dart';

/// Full-screen overlay shown while the generation job is being submitted.
class GenerationStartingOverlay extends StatelessWidget {
  const GenerationStartingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
        child: Center(
          child: Card(
            child: Padding(
              padding: AppSpacing.cardPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Starting generation...',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
