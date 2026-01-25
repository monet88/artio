# Phase 2: Credit Availability System

## Context

- Parent: [plan.md](./plan.md)
- Depends on: [Phase 1](./phase-01-database-edge-function.md)

## Overview

| Field | Value |
|-------|-------|
| Priority | P1 - Critical |
| Status | Pending |
| Effort | 1.5h |

Implement client-side calculated credit availability with optimistic updates.

## Key Insights

- Current `UserModel.credits` is static, requires reset logic
- `generation_jobs` already tracks all generations
- Replace stored credits with calculated availability

## Requirements

### Functional
- Fetch daily generation count on app load/auth
- Calculate: `available = DAILY_LIMIT - dailyCount`
- Optimistic increment during session
- Show remaining credits in UI

### Non-Functional
- Single COUNT query per session (not per generation)
- Graceful handling of stale counts

## Architecture

```
AuthViewModel.build()
  └→ GenerationRepository.getDailyGenerationCount()
     └→ CreditAvailabilityNotifier.initialize(dailyCount)
        └→ UI shows: "5 - dailyCount = available"

On Generate:
  └→ CreditAvailabilityNotifier.decrement() [optimistic]
  └→ Edge Function validates server-side
```

## Related Code Files

### Modify
- `lib/features/template_engine/repository/generation_repository.dart` - Add `getDailyGenerationCount()`
- `lib/features/template_engine/ui/template_detail_screen.dart` - Show remaining credits

### Create
- `lib/features/template_engine/ui/view_model/credit_availability_notifier.dart` - Manage credit state

## Implementation Steps

### 1. Add `getDailyGenerationCount()` to GenerationRepository

```dart
// lib/features/template_engine/repository/generation_repository.dart

Future<int> getDailyGenerationCount() async {
  final now = DateTime.now();
  final todayMidnight = DateTime(now.year, now.month, now.day);

  try {
    final response = await _supabase
        .from('generation_jobs')
        .select('id', const FetchOptions(count: CountOption.exact, head: true))
        .gte('created_at', todayMidnight.toUtc().toIso8601String());

    return response.count ?? 0;
  } on PostgrestException catch (e) {
    throw AppException.network(message: e.message);
  }
}
```

### 2. Create CreditAvailabilityNotifier

```dart
// lib/features/template_engine/ui/view_model/credit_availability_notifier.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../repository/generation_repository.dart';

part 'credit_availability_notifier.g.dart';

const int kDailyLimit = 5;

@riverpod
class CreditAvailabilityNotifier extends _$CreditAvailabilityNotifier {
  @override
  Future<int> build() async {
    final repo = ref.read(generationRepositoryProvider);
    final usedToday = await repo.getDailyGenerationCount();
    return kDailyLimit - usedToday;
  }

  void decrement() {
    state.whenData((available) {
      if (available > 0) {
        state = AsyncData(available - 1);
      }
    });
  }

  void refresh() => ref.invalidateSelf();
}
```

### 3. Update TemplateDetailScreen

```dart
// In _buildGenerationState, before Generate button:

final creditAsync = ref.watch(creditAvailabilityNotifierProvider);

// Show remaining
creditAsync.when(
  data: (available) => Text('$available generations remaining today'),
  loading: () => const SizedBox.shrink(),
  error: (_, __) => const SizedBox.shrink(),
);

// Disable button if 0
FilledButton(
  onPressed: available > 0 ? () => _handleGenerate(template) : null,
  child: Text(available > 0 ? 'Generate' : 'Daily limit reached'),
);
```

### 4. Decrement on Generate

```dart
void _handleGenerate(TemplateModel template) {
  ref.read(creditAvailabilityNotifierProvider.notifier).decrement();
  // ... existing generation code
}
```

## Todo List

- [ ] Add `getDailyGenerationCount()` to GenerationRepository
- [ ] Create CreditAvailabilityNotifier
- [ ] Update TemplateDetailScreen to show remaining
- [ ] Disable button when 0 available
- [ ] Decrement optimistically on generate
- [ ] Run `dart run build_runner build`
- [ ] Test: Fresh user sees 5 available
- [ ] Test: After generation, count decreases
- [ ] Test: At 0, button disabled

## Success Criteria

- [ ] UI shows accurate remaining count
- [ ] Button disabled at 0 (free users)
- [ ] Optimistic decrement works
- [ ] Count resets naturally at midnight (no cron)

## Risk Assessment

| Risk | Mitigation |
|------|------------|
| Stale count after midnight | Refresh on app resume |
| Optimistic drift | Server is final authority, 403 = resync |
| Timezone mismatch | Use local time for display, UTC for queries |

## Security Considerations

- Client count is UX only, server enforces
- Never skip server validation based on client state

## Next Steps

→ Phase 3: Rate Limiting & Cooldown
