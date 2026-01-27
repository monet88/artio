import 'package:flutter/material.dart';
import '../../domain/entities/input_field_model.dart';

class InputFieldBuilder extends StatelessWidget {
  final InputFieldModel field;
  final ValueChanged<String> onChanged;

  const InputFieldBuilder({
    super.key,
    required this.field,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    switch (field.type) {
      case 'select':
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: field.label,
            border: const OutlineInputBorder(),
          ),
          initialValue: field.defaultValue,
          items: field.options
              ?.map((option) => DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        );
      case 'slider':
        // Simplified slider implementation - assumes state management in parent for value
        // For now, using a simple text field as fallback or robust slider requires state
        return TextFormField(
          initialValue: field.defaultValue,
          decoration: InputDecoration(
            labelText: field.label,
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onChanged: onChanged,
        );
      case 'text':
      default:
        return TextFormField(
          initialValue: field.defaultValue,
          decoration: InputDecoration(
            labelText: field.label,
            hintText: field.placeholder,
            border: const OutlineInputBorder(),
          ),
          onChanged: onChanged,
          validator: field.required
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
        );
    }
  }
}
