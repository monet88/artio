# Phase 1: 3-Layer Architecture Restructure

## Context Links

- [Flutter Expert Review](../reports/flutter-expert-260125-1503-phase45-review.md) - H2 finding
- [Feature-Based Clean Architecture Skill](../../.claude/skills/flutter/feature-based-clean-architecture/skill.md)
- [Folder Structure Reference](../../.claude/skills/flutter/feature-based-clean-architecture/references/folder-structure.md)

## Overview

**Priority**: P1 (High)
**Status**: pending
**Effort**: 4 hours

Restructure `template_engine` and `auth` features to follow 3-layer clean architecture: `domain/`, `data/`, `presentation/`.

## Key Insights

1. Current structure mixes concerns: `model/`, `repository/`, `ui/` at same level
2. No abstract repository interfaces - direct coupling to implementations
3. Presentation layer directly imports data layer (violates dependency rule)
4. Clean arch dependency rule: `Presentation -> Domain <- Data`

## Requirements

### Functional
- Maintain all existing functionality
- Keep existing public API surface (imports may change)
- Generated files must regenerate cleanly

### Non-Functional
- Zero runtime regressions
- Compile without errors after each step
- Follow naming conventions from skill reference

## Architecture

### Current Structure (BEFORE)

```
lib/features/template_engine/
├── model/
│   ├── template_model.dart
│   ├── generation_job_model.dart
│   └── input_field_model.dart
├── repository/
│   ├── template_repository.dart
│   └── generation_repository.dart
└── ui/
    ├── providers/
    ├── view_model/
    ├── widgets/
    └── *.dart (screens)
```

### Target Structure (AFTER)

```
lib/features/template_engine/
├── domain/
│   ├── entities/
│   │   ├── template_model.dart
│   │   ├── generation_job_model.dart
│   │   └── input_field_model.dart
│   └── repositories/
│       ├── i_template_repository.dart
│       └── i_generation_repository.dart
├── data/
│   └── repositories/
│       ├── template_repository.dart
│       └── generation_repository.dart
└── presentation/
    ├── providers/
    │   └── template_provider.dart
    ├── view_models/
    │   └── generation_view_model.dart
    ├── screens/
    │   ├── home_screen.dart
    │   └── template_detail_screen.dart
    └── widgets/
        ├── template_card.dart
        ├── template_grid.dart
        ├── generation_progress.dart
        └── input_field_builder.dart
```

## Related Code Files

### Files to Move

| From | To |
|------|----|
| `template_engine/model/*.dart` | `template_engine/domain/entities/` |
| `template_engine/repository/*.dart` | `template_engine/data/repositories/` |
| `template_engine/ui/providers/` | `template_engine/presentation/providers/` |
| `template_engine/ui/view_model/` | `template_engine/presentation/view_models/` |
| `template_engine/ui/widgets/` | `template_engine/presentation/widgets/` |
| `template_engine/ui/*_screen.dart` | `template_engine/presentation/screens/` |
| `auth/model/` | `auth/domain/entities/` |
| `auth/repository/` | `auth/data/repositories/` |
| `auth/ui/` | `auth/presentation/` |

### Files to Create

- `domain/repositories/i_template_repository.dart` - abstract interface
- `domain/repositories/i_generation_repository.dart` - abstract interface
- `auth/domain/repositories/i_auth_repository.dart` - abstract interface

### Files to Modify (imports)

- All screens/widgets that import models/repos
- Provider files
- `app_router.dart`

## Implementation Steps

### Step 1: Create Directory Structure (5 min)

```bash
# template_engine
mkdir -p lib/features/template_engine/domain/entities
mkdir -p lib/features/template_engine/domain/repositories
mkdir -p lib/features/template_engine/data/repositories
mkdir -p lib/features/template_engine/presentation/providers
mkdir -p lib/features/template_engine/presentation/view_models
mkdir -p lib/features/template_engine/presentation/screens
mkdir -p lib/features/template_engine/presentation/widgets

# auth
mkdir -p lib/features/auth/domain/entities
mkdir -p lib/features/auth/domain/repositories
mkdir -p lib/features/auth/data/repositories
mkdir -p lib/features/auth/presentation/providers
mkdir -p lib/features/auth/presentation/view_models
mkdir -p lib/features/auth/presentation/screens
mkdir -p lib/features/auth/presentation/widgets
mkdir -p lib/features/auth/presentation/state
```

### Step 2: Move Entity Files (15 min)

1. Move `template_engine/model/*.dart` -> `template_engine/domain/entities/`
2. Move `auth/model/*.dart` -> `auth/domain/entities/`
3. Delete empty `model/` folders
4. Run `flutter analyze` - expect import errors

### Step 3: Move Repository Implementations (20 min)

1. Move `template_engine/repository/*.dart` -> `template_engine/data/repositories/`
2. Move `auth/repository/*.dart` -> `auth/data/repositories/`
3. Delete empty `repository/` folders

### Step 4: Create Abstract Repository Interfaces (45 min)

For each repository, create interface in `domain/repositories/`:

```dart
// domain/repositories/i_template_repository.dart
abstract class ITemplateRepository {
  Future<List<TemplateModel>> fetchTemplates();
  Future<TemplateModel?> fetchTemplate(String id);
  Future<List<TemplateModel>> fetchByCategory(String category);
  Stream<List<TemplateModel>> watchTemplates();
}
```

```dart
// domain/repositories/i_generation_repository.dart
abstract class IGenerationRepository {
  Future<String> startGeneration({
    required String templateId,
    required String prompt,
    String aspectRatio = '1:1',
    int imageCount = 1,
  });
  Stream<GenerationJobModel> watchJob(String jobId);
  Future<List<GenerationJobModel>> fetchUserJobs({int limit = 20, int offset = 0});
  Future<GenerationJobModel?> fetchJob(String jobId);
}
```

```dart
// auth/domain/repositories/i_auth_repository.dart
abstract class IAuthRepository {
  Stream<AuthState> get onAuthStateChange;
  User? get currentUser;
  Session? get currentSession;
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> signUpWithEmail(String email, String password);
  Future<void> signInWithGoogle();
  Future<void> signInWithApple();
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<UserModel?> getCurrentUserWithProfile();
  Future<UserModel> refreshCurrentUser();
  Future<Map<String, dynamic>?> fetchOrCreateProfile(User user);
}
```

### Step 5: Update Repository Implementations (30 min)

Add `implements IXxxRepository` to each implementation class.

### Step 6: Move Presentation Layer (30 min)

1. Move `template_engine/ui/providers/` -> `template_engine/presentation/providers/`
2. Move `template_engine/ui/view_model/` -> `template_engine/presentation/view_models/`
3. Move `template_engine/ui/widgets/` -> `template_engine/presentation/widgets/`
4. Move `template_engine/ui/*_screen.dart` -> `template_engine/presentation/screens/`
5. Move `auth/ui/state/` -> `auth/presentation/state/`
6. Move `auth/ui/view_model/` -> `auth/presentation/view_models/`
7. Move `auth/ui/widgets/` -> `auth/presentation/widgets/`
8. Move `auth/ui/*_screen.dart` -> `auth/presentation/screens/`
9. Delete empty `ui/` folders

### Step 7: Fix All Imports (60 min)

1. Search for all imports from old paths
2. Update to new paths
3. Update `app_router.dart` imports
4. Update any shared/ imports

### Step 8: Regenerate Code (15 min)

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Step 9: Verify (20 min)

```bash
flutter analyze
flutter test
```

## Todo List

- [ ] Create directory structure for template_engine
- [ ] Create directory structure for auth
- [ ] Move template_engine entity files
- [ ] Move auth entity files
- [ ] Move template_engine repository implementations
- [ ] Move auth repository implementations
- [ ] Create ITemplateRepository interface
- [ ] Create IGenerationRepository interface
- [ ] Create IAuthRepository interface
- [ ] Update TemplateRepository to implement interface
- [ ] Update GenerationRepository to implement interface
- [ ] Update AuthRepository to implement interface
- [ ] Move template_engine presentation layer
- [ ] Move auth presentation layer
- [ ] Fix all imports in template_engine
- [ ] Fix all imports in auth
- [ ] Fix imports in app_router.dart
- [ ] Run build_runner
- [ ] Run flutter analyze
- [ ] Run flutter test

## Success Criteria

- [ ] `flutter analyze` reports 0 errors
- [ ] All features have `domain/`, `data/`, `presentation/` structure
- [ ] Abstract interfaces exist in `domain/repositories/`
- [ ] Implementations in `data/repositories/` implement interfaces
- [ ] No direct imports from `data/` in presentation layer (except via providers)

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Import chain breaks | High | Medium | Move files one folder at a time, run analyze after each |
| Generated files stale | High | Low | Always run build_runner after file moves |
| Circular dependencies | Low | High | Domain layer must have zero dependencies on other layers |
| Lost file during move | Low | High | Git track changes, verify with `git status` |

## Security Considerations

No security impact - this is purely structural refactoring.

## Next Steps

After completing Phase 1:
1. Proceed to Phase 2: Repository DI
2. Update any documentation referencing old paths
