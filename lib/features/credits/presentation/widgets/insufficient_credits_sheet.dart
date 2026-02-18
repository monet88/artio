import 'package:artio/core/design_system/app_spacing.dart';
import 'package:flutter/material.dart';

/// Bottom sheet displayed when user has insufficient credits
/// to generate with the selected model.
class InsufficientCreditsSheet extends StatelessWidget {
  const InsufficientCreditsSheet({
    required this.currentBalance,
    required this.requiredCredits,
    super.key,
  });

  final int currentBalance;
  final int requiredCredits;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('💎', style: TextStyle(fontSize: 48)),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Not enough credits',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'This model costs $requiredCredits credits, '
            'but you only have $currentBalance.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('Watch ad for credits'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Dismiss'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}
