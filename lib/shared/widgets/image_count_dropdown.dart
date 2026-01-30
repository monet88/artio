import 'package:flutter/material.dart';

/// Dropdown for selecting image count (1-4)
class ImageCountDropdown extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const ImageCountDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Image Count', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
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
