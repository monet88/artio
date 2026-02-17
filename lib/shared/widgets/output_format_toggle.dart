import 'package:artio/core/design_system/app_spacing.dart';
import 'package:flutter/material.dart';

/// Toggle for output format (JPG/PNG) with premium indicator for PNG
class OutputFormatToggle extends StatelessWidget {

  const OutputFormatToggle({
    required this.value, required this.isPremium, required this.onChanged, super.key,
  });
  final String value;
  final bool isPremium;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Output Format', style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        SegmentedButton<String>(
          segments: [
            const ButtonSegment(
              value: 'jpg',
              label: Text('JPG'),
            ),
            ButtonSegment(
              value: 'png',
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('PNG'),
                  if (!isPremium) ...[
                    const SizedBox(width: 4),
                    const Text('\u{1F451}', style: TextStyle(fontSize: 12)), // Crown emoji
                  ],
                ],
              ),
              enabled: isPremium,
            ),
          ],
          selected: {value},
          onSelectionChanged: (Set<String> selection) {
            if (selection.isNotEmpty) {
              onChanged(selection.first);
            }
          },
        ),
        if (!isPremium && value == 'jpg')
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'PNG format requires premium',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
      ],
    );
  }
}
