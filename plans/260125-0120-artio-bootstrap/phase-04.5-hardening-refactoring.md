# Phase 4.5: Hardening & Refactoring

**Status:** ✅ Completed
**Priority:** P0 - Critical (blocks production)

---

## Overview

Address critical issues from code review before continuing to Phase 5.

---

## Tasks

### 1. State Management Refactoring (GenerationViewModel)
- [x] Change state type to `AsyncValue<GenerationJobModel?>`
- [x] Remove `_isLoading`, `_error`, `reset()`
- [x] Update `generate()` to use `AsyncValue.loading()`, `AsyncValue.data()`, `AsyncValue.error()`
- [x] Remove `ref.notifyListeners()`

**File:** `lib/features/template_engine/ui/view_model/generation_view_model.dart`

### 2. Repository Hardening
- [x] Add try-catch to `TemplateRepository`
- [x] Add try-catch to `GenerationRepository`
- [x] Throw `AppException` variants
- [x] Replace unsafe casts with type guards

**Files:**
- `lib/features/template_engine/repository/template_repository.dart`
- `lib/features/template_engine/repository/generation_repository.dart`

### 3. Type-Safe Routing (go_router_builder)
- [x] Create `AppRoutes` class with static path methods
- [x] Update `app_router.dart` to use AppRoutes
- [x] Update navigation calls to use typed routes

**Note:** TypedGoRoute deferred due to go_router_builder version incompatibility

**Files:**
- `lib/routing/app_router.dart`
- `lib/features/template_engine/ui/widgets/template_card.dart`

### 4. Safety & Best Practices
- [x] Add `_validateEnv()` in main.dart
- [x] Change `ref.read` to `ref.watch` in providers

**Files:**
- `lib/main.dart`
- `lib/features/template_engine/ui/providers/template_provider.dart`

---

## Open Questions Resolution

| Question | Resolution |
|----------|------------|
| Credit system | Add `credits` to UserModel, check before generation |
| Premium gating | Disable generate button if `template.isPremium && !user.isPremium` |
| Rate limiting | Handle 429 from Edge Function, map to AppException |
| Input sanitization | Trim on client, sanitize on backend |

---

## Success Criteria

- [ ] `flutter analyze` clean
- [ ] No manual state tracking in ViewModels
- [ ] All navigation uses TypedGoRoute
- [ ] All repository methods have error handling
- [ ] App starts gracefully with clear error if env missing
