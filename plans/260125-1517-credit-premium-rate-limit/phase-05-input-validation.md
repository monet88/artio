# Phase 5: Input Validation

## Context

- Parent: [plan.md](./plan.md)
- Depends on: [Phase 3](./phase-03-rate-limiting.md)

## Overview

| Field | Value |
|-------|-------|
| Priority | P2 - Medium |
| Status | Pending |
| Effort | 0.5h |

Add client-side input validation: trim, length limits, and basic sanitization.

## Key Insights

- Current code only does `prompt.trim()` in repository
- No length validation - could send huge prompts
- Backend should sanitize, but fail-fast locally is better UX

## Requirements

### Functional
- Trim whitespace on all inputs
- Max 1000 characters for prompt
- Show error before network call if invalid
- Block empty prompts

### Non-Functional
- Validation < 10ms
- Clear error messages

## Architecture

```
User Input → Trim → Length Check → Empty Check → Proceed to Generate
                        ↓              ↓
                   Show Error     Show Error
```

## Related Code Files

### Modify
- `lib/features/template_engine/ui/template_detail_screen.dart` - Add validation

### Create
- `lib/shared/utils/input_validator.dart` - Reusable validation functions

## Implementation Steps

### 1. Create InputValidator Utility

```dart
// lib/shared/utils/input_validator.dart

const int kMaxPromptLength = 1000;

class InputValidator {
  static String? validatePrompt(String prompt) {
    final trimmed = prompt.trim();

    if (trimmed.isEmpty) {
      return 'Prompt cannot be empty';
    }

    if (trimmed.length > kMaxPromptLength) {
      return 'Prompt too long (max $kMaxPromptLength characters)';
    }

    return null; // Valid
  }

  static String sanitize(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '') // Remove control chars
        .replaceAll(RegExp(r'\s+'), ' '); // Normalize whitespace
  }
}
```

### 2. Update TemplateDetailScreen

```dart
// lib/features/template_engine/ui/template_detail_screen.dart

import '../../../shared/utils/input_validator.dart';

void _handleGenerate(TemplateModel template) {
  final prompt = _buildPrompt(template);
  final error = InputValidator.validatePrompt(prompt);

  if (error != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error)),
    );
    return;
  }

  final sanitized = InputValidator.sanitize(prompt);

  ref.read(creditAvailabilityNotifierProvider.notifier).decrement();
  ref.read(generationViewModelProvider.notifier).generate(
        templateId: template.id,
        prompt: sanitized,
        aspectRatio: _selectedAspectRatio,
        imageCount: 1,
      );
}
```

### 3. Show Character Count (Optional UX)

```dart
// Below prompt input fields
Text(
  '${_buildPrompt(template).length}/$kMaxPromptLength',
  style: TextStyle(
    color: _buildPrompt(template).length > kMaxPromptLength
        ? Colors.red
        : Colors.grey,
  ),
),
```

## Todo List

- [ ] Create `lib/shared/utils/input_validator.dart`
- [ ] Add `validatePrompt()` and `sanitize()` functions
- [ ] Update `_handleGenerate()` to validate before calling
- [ ] Show SnackBar for validation errors
- [ ] Optional: Show character count
- [ ] Test: Empty prompt rejected
- [ ] Test: Long prompt rejected
- [ ] Test: Valid prompt proceeds

## Success Criteria

- [ ] Empty prompts blocked with message
- [ ] Prompts > 1000 chars blocked
- [ ] Control characters stripped
- [ ] Whitespace normalized

## Risk Assessment

| Risk | Mitigation |
|------|------------|
| Overly strict validation | Allow generous limit (1000 chars) |
| Unicode edge cases | Only strip control chars, keep emoji |

## Security Considerations

- Client validation is UX, not security
- Backend MUST sanitize independently
- Never trust client-sanitized input

## Next Steps

→ Implementation complete. Run tests and deploy.
