import 'package:flutter/material.dart';
import '../../domain/entities/input_field_model.dart';

class InputFieldBuilder extends StatefulWidget {
  final InputFieldModel field;
  final ValueChanged<String> onChanged;

  const InputFieldBuilder({
    super.key,
    required this.field,
    required this.onChanged,
  });

  @override
  State<InputFieldBuilder> createState() => _InputFieldBuilderState();
}

class _InputFieldBuilderState extends State<InputFieldBuilder> {
  late double _sliderValue;

  @override
  void initState() {
    super.initState();
    _sliderValue = double.tryParse(widget.field.defaultValue ?? '50') ?? 50;
  }

  @override
  void didUpdateWidget(covariant InputFieldBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.field.id != widget.field.id ||
        oldWidget.field.defaultValue != widget.field.defaultValue) {
      _sliderValue = double.tryParse(widget.field.defaultValue ?? '50') ?? 50;
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.field.type) {
      case 'select':
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: widget.field.label,
            border: const OutlineInputBorder(),
          ),
          value: widget.field.defaultValue,
          items: widget.field.options
              ?.map((option) => DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) widget.onChanged(value);
          },
        );

      case 'slider':
        final min = widget.field.min ?? 0;
        final max = widget.field.max ?? 100;
        final divisions = (max - min).toInt();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.field.label,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  _sliderValue.toStringAsFixed(0),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            Slider(
              value: _sliderValue.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions > 0 ? divisions : null,
              label: _sliderValue.toStringAsFixed(0),
              onChanged: (value) {
                setState(() => _sliderValue = value);
                widget.onChanged(value.toStringAsFixed(0));
              },
            ),
          ],
        );

      case 'text':
      default:
        return TextFormField(
          initialValue: widget.field.defaultValue,
          decoration: InputDecoration(
            labelText: widget.field.label,
            hintText: widget.field.placeholder,
            border: const OutlineInputBorder(),
          ),
          onChanged: widget.onChanged,
          validator: widget.field.required
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
