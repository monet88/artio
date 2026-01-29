# Phase 06: Flutter Code Quality - Template Engine

## Parallelization Info

| Property | Value |
|----------|-------|
| Group | C (Flutter) |
| Can Run With | Phases 05, 07, 08 |
| Blocked By | Group B (Phases 03, 04) |
| Blocks | Group E (Phases 10, 11) |

## File Ownership (Exclusive)

- `lib/features/template_engine/presentation/screens/template_detail_screen.dart`
- `lib/features/template_engine/presentation/widgets/input_field_builder.dart`
- `lib/features/template_engine/domain/entities/input_field_model.dart`

## Priority: MEDIUM

**Issues**:
1. Template detail screen silently fails when user not authenticated (no feedback)
2. Slider input type uses TextFormField fallback instead of actual Slider widget

## Implementation Steps

### Issue 1: Auth Feedback in Template Detail Screen

**File**: `lib/features/template_engine/presentation/screens/template_detail_screen.dart`

**Current** (lines 34-41):
```dart
void _handleGenerate(TemplateModel template) {
  final userId = ref.read(authViewModelProvider).maybeMap(
        authenticated: (s) => s.user.id,
        orElse: () => null,
      );

  if (userId == null) return;  // Silent failure!
  // ...
}
```

**Fix**: Show login prompt when not authenticated
```dart
void _handleGenerate(TemplateModel template) {
  final userId = ref.read(authViewModelProvider).maybeMap(
        authenticated: (s) => s.user.id,
        orElse: () => null,
      );

  if (userId == null) {
    // Show login prompt
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Please log in to generate images'),
        action: SnackBarAction(
          label: 'Login',
          onPressed: () => context.go('/login'),
        ),
      ),
    );
    return;
  }

  final prompt = _buildPrompt(template);
  ref.read(generationViewModelProvider.notifier).generate(
        templateId: template.id,
        prompt: prompt,
        userId: userId,
        aspectRatio: _selectedAspectRatio,
      );
}
```

Add import at top:
```dart
import 'package:go_router/go_router.dart';
```

### Issue 2: Implement Proper Slider Widget

**File**: `lib/features/template_engine/presentation/widgets/input_field_builder.dart`

**Current** (lines 34-45):
```dart
case 'slider':
  // Simplified slider implementation - assumes state management in parent
  return TextFormField(
    initialValue: field.defaultValue,
    decoration: InputDecoration(
      labelText: field.label,
      border: const OutlineInputBorder(),
    ),
    keyboardType: TextInputType.number,
    onChanged: onChanged,
  );
```

**Fix**: Implement proper stateful Slider

Convert to StatefulWidget:
```dart
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
    // Initialize slider value from default
    _sliderValue = double.tryParse(widget.field.defaultValue ?? '50') ?? 50;
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
        // Parse min/max from field config, default to 0-100
        final min = double.tryParse(widget.field.min ?? '0') ?? 0;
        final max = double.tryParse(widget.field.max ?? '100') ?? 100;
        final divisions = ((max - min) / (widget.field.step ?? 1)).round();

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
```

### Step 3: Update InputFieldModel if needed

Check if `InputFieldModel` has `min`, `max`, `step` fields. If not:

```dart
// In input_field_model.dart
@freezed
class InputFieldModel with _$InputFieldModel {
  const factory InputFieldModel({
    required String name,
    required String label,
    required String type,
    String? placeholder,
    String? defaultValue,
    List<String>? options,
    @Default(false) bool required,
    String? min,      // For slider
    String? max,      // For slider
    double? step,     // For slider
  }) = _InputFieldModel;

  // ...
}
```

## Success Criteria

- [ ] Unauthenticated users see login prompt when trying to generate
- [ ] Slider type renders actual Slider widget with value display
- [ ] Slider respects min/max/step from field config
- [ ] All existing input types still work
- [ ] Code compiles without errors

## Conflict Prevention

- Only this phase modifies template engine presentation files
- May need to update InputFieldModel (domain layer) if missing fields

## Post-Implementation

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```
