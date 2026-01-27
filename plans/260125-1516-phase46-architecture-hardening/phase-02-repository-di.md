# Phase 2: Repository Dependency Injection

## Context Links

- [Flutter Expert Review](../reports/flutter-expert-260125-1503-phase45-review.md) - M1 finding
- [Phase 1: Architecture Restructure](phase-01-three-layer-restructure.md)

## Overview

**Priority**: P2 (Medium)
**Status**: completed
**Effort**: 1 hour (actual: 45 min)
**Depends on**: Phase 1 complete

Inject `SupabaseClient` via constructor instead of accessing `Supabase.instance.client` directly. Enables testing and follows DI principles.

## Key Insights

1. Current pattern: `final _supabase = Supabase.instance.client;` in class body
2. Makes unit testing impossible without mocking Supabase singleton
3. Solution: Constructor injection with Riverpod provider wiring

## Requirements

### Functional
- All repositories receive `SupabaseClient` via constructor
- Riverpod providers wire up dependencies

### Non-Functional
- Zero behavior change
- Testable with mock SupabaseClient

## Architecture

### Current Pattern (BEFORE)

```dart
class TemplateRepository {
  final _supabase = Supabase.instance.client; // Hard dependency

  Future<List<TemplateModel>> fetchTemplates() async {
    final response = await _supabase.from('templates')...
  }
}

@riverpod
TemplateRepository templateRepository(Ref ref) => TemplateRepository();
```

### Target Pattern (AFTER)

```dart
class TemplateRepository implements ITemplateRepository {
  final SupabaseClient _supabase;

  const TemplateRepository(this._supabase); // Injectable

  Future<List<TemplateModel>> fetchTemplates() async {
    final response = await _supabase.from('templates')...
  }
}

@riverpod
SupabaseClient supabaseClient(Ref ref) => Supabase.instance.client;

@riverpod
TemplateRepository templateRepository(Ref ref) {
  return TemplateRepository(ref.watch(supabaseClientProvider));
}
```

## Related Code Files

### Files to Modify

- `lib/features/template_engine/data/repositories/template_repository.dart`
- `lib/features/template_engine/data/repositories/generation_repository.dart`
- `lib/features/auth/data/repositories/auth_repository.dart`

### Files to Create

- `lib/core/providers/supabase_provider.dart` (shared SupabaseClient provider)

## Implementation Steps

### Step 1: Create Supabase Provider (5 min)

Create `lib/core/providers/supabase_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_provider.g.dart';

@riverpod
SupabaseClient supabaseClient(Ref ref) => Supabase.instance.client;
```

### Step 2: Update TemplateRepository (10 min)

```dart
class TemplateRepository implements ITemplateRepository {
  final SupabaseClient _supabase;

  const TemplateRepository(this._supabase);

  // ... methods unchanged
}

@riverpod
TemplateRepository templateRepository(Ref ref) {
  return TemplateRepository(ref.watch(supabaseClientProvider));
}
```

### Step 3: Update GenerationRepository (10 min)

Same pattern as Step 2.

### Step 4: Update AuthRepository (10 min)

Same pattern. Note: `AuthRepository` also has `onAuthStateChange` getter - this uses `_supabase.auth` which still works.

### Step 5: Regenerate Providers (5 min)

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Step 6: Verify (10 min)

```bash
flutter analyze
flutter test
```

## Todo List

- [x] Create `lib/core/providers/supabase_provider.dart`
- [x] Update TemplateRepository constructor and provider
- [x] Update GenerationRepository constructor and provider
- [x] Update AuthRepository constructor and provider
- [x] Run build_runner
- [x] Run flutter analyze
- [ ] Run flutter test (blocked on Windows - test runner issues from Phase 1)

## Success Criteria

- [x] No repository directly accesses `Supabase.instance.client`
- [x] All repositories have `const` constructor with `SupabaseClient` param
- [x] Providers wire up `supabaseClientProvider` to repositories
- [ ] All tests pass (blocked on Windows test environment)

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Provider dependency cycle | Low | Medium | supabaseClientProvider has no deps |
| Auth state issues | Low | High | Test auth flow manually after change |

## Security Considerations

No security impact - SupabaseClient instance unchanged, just how it's passed.

## Next Steps

After completing Phase 2:
1. Proceed to Phase 3: Error Mapper
2. Consider adding repository mocks for testing
