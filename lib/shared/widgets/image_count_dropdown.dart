import 'package:artio/core/design_system/app_spacing.dart';
import 'package:flutter/material.dart';

/// Dropdown for selecting image count (1-4)
class ImageCountDropdown extends StatelessWidget {

  const ImageCountDropdown({
    required this.value, required this.onChanged, super.key,
  });
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Image Count', style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<int>(
          initialValue: value,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: List.generate(4, (i) => i + 1).map((count) {
            return DropdownMenuItem(
              value: count,
              child: Text('$count image${count > 1 ? 's' : ''}'),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ],
    );
  }
}
