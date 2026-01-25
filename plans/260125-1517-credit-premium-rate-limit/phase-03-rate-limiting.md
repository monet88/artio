# Phase 3: Rate Limiting & Cooldown

## Context

- Parent: [plan.md](./plan.md)
- Depends on: [Phase 2](./phase-02-credit-availability.md)

## Overview

| Field | Value |
|-------|-------|
| Priority | P1 - Critical |
| Status | Pending |
| Effort | 1h |

Implement client-side debounce/cooldown to prevent double-tap and rapid requests.

## Key Insights

- Backend already returns 429 for rate limit
- Client has no debounce - double-tap can cause duplicate requests
- Need: button disable + 10s cooldown after generation

## Requirements

### Functional
- Disable button immediately on press
- 10s cooldown after generation starts
- Show countdown or "Generating..." state
- Re-enable after cooldown + job complete/failed

### Non-Functional
- No extra network calls for rate limiting
- Cooldown survives widget rebuild

## Architecture

```
User Press → Disable Button → Start Timer (10s) → Start Generation
                                    ↓
            Timer Complete ─────────┴───────→ Check Job Status
                                                  ↓
                              Job Complete? → Enable Button
                              Job Pending? → Keep Disabled
```

## Related Code Files

### Modify
- `lib/features/template_engine/ui/view_model/generation_view_model.dart` - Add cooldown state
- `lib/features/template_engine/ui/template_detail_screen.dart` - Respect cooldown

## Implementation Steps

### 1. Add Cooldown State to GenerationViewModel

```dart
// lib/features/template_engine/ui/view_model/generation_view_model.dart

import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../model/generation_job_model.dart';
import '../../repository/generation_repository.dart';

part 'generation_view_model.g.dart';

@riverpod
class GenerationViewModel extends _$GenerationViewModel {
  StreamSubscription<GenerationJobModel>? _jobSubscription;
  Timer? _cooldownTimer;
  bool _isOnCooldown = false;

  @override
  AsyncValue<GenerationJobModel?> build() {
    ref.onDispose(() {
      _jobSubscription?.cancel();
      _cooldownTimer?.cancel();
    });
    return const AsyncData(null);
  }

  bool get canGenerate => !state.isLoading && !_isOnCooldown;

  Future<void> generate({
    required String templateId,
    required String prompt,
    String aspectRatio = '1:1',
    int imageCount = 1,
  }) async {
    if (!canGenerate) return;

    _startCooldown();
    state = const AsyncLoading();

    try {
      final repo = ref.read(generationRepositoryProvider);
      final jobId = await repo.startGeneration(
        templateId: templateId,
        prompt: prompt.trim(),
        aspectRatio: aspectRatio,
        imageCount: imageCount,
      );

      _jobSubscription?.cancel();
      _jobSubscription = repo.watchJob(jobId).listen(
        (job) {
          state = AsyncData(job);
          if (job.status == JobStatus.completed ||
              job.status == JobStatus.failed) {
            _jobSubscription?.cancel();
          }
        },
        onError: (Object e, StackTrace st) {
          state = AsyncError(e, st);
        },
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  void _startCooldown() {
    _isOnCooldown = true;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer(const Duration(seconds: 10), () {
      _isOnCooldown = false;
    });
  }

  void reset() {
    _jobSubscription?.cancel();
    _cooldownTimer?.cancel();
    _isOnCooldown = false;
    state = const AsyncData(null);
  }
}
```

### 2. Update TemplateDetailScreen Button

```dart
// In _buildGenerationState:

final viewModel = ref.watch(generationViewModelProvider.notifier);
final canGenerate = viewModel.canGenerate;

FilledButton(
  onPressed: canGenerate ? () => _handleGenerate(template) : null,
  child: Text(
    state.isLoading
        ? 'Generating...'
        : canGenerate
            ? 'Generate'
            : 'Please wait...',
  ),
);
```

### 3. Input Length Validation (bonus)

```dart
// In _handleGenerate:
void _handleGenerate(TemplateModel template) {
  final prompt = _buildPrompt(template).trim();

  if (prompt.length > 1000) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Prompt too long (max 1000 characters)')),
    );
    return;
  }

  ref.read(creditAvailabilityNotifierProvider.notifier).decrement();
  ref.read(generationViewModelProvider.notifier).generate(
        templateId: template.id,
        prompt: prompt,
        aspectRatio: _selectedAspectRatio,
        imageCount: 1,
      );
}
```

## Todo List

- [ ] Add `_isOnCooldown` and `_cooldownTimer` to GenerationViewModel
- [ ] Add `canGenerate` getter
- [ ] Guard `generate()` with `if (!canGenerate) return`
- [ ] Update button text based on state
- [ ] Add prompt length validation
- [ ] Run `dart run build_runner build`
- [ ] Test: Double-tap blocked
- [ ] Test: Button re-enables after 10s + job complete
- [ ] Test: Long prompt rejected

## Success Criteria

- [ ] Double-tap prevented
- [ ] 10s cooldown enforced
- [ ] Button state reflects cooldown
- [ ] Prompt > 1000 chars rejected client-side

## Risk Assessment

| Risk | Mitigation |
|------|------------|
| Timer not cancelled on dispose | `ref.onDispose()` handles cleanup |
| Cooldown too aggressive | 10s is reasonable for image generation |
| UI doesn't reflect cooldown | Use `ref.watch` on notifier |

## Security Considerations

- Client-side cooldown is UX, not security
- Backend leaky bucket is the actual rate limiter
- Never trust client timing

## Next Steps

→ Phase 4: Premium Hybrid Sync
