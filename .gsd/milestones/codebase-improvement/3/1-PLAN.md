---
phase: 3
plan: 1
wave: 1
---

# Plan 3.1: Fix Presentation→Data Layer Violations

## Objective
Fix 7 direct imports from `presentation/` to `data/` layer. Clean Architecture requires
presentation→domain→data flow. Providers that expose data-layer implementations should be
moved to the domain layer or routed through domain interfaces.

**Current violations:**
1. `settings_screen.dart` → `settings/data/notifications_provider.dart`
2. `settings_sections.dart` → `settings/data/notifications_provider.dart`
3. `generation_view_model.dart` → `template_engine/data/repositories/generation_repository.dart`
4. `template_provider.dart` → `template_engine/data/repositories/template_repository.dart`
5. `generation_policy_provider.dart` → `template_engine/data/policies/free_beta_policy.dart`
6. `auth_view_model.dart` → `auth/data/repositories/auth_repository.dart`
7. `subscription_provider.dart` → `subscription/data/repositories/subscription_repository.dart`

## Context
- .gsd/ARCHITECTURE.md (Clean Architecture layer rules)
- lib/features/settings/presentation/settings_screen.dart
- lib/features/template_engine/presentation/view_models/generation_view_model.dart
- lib/features/auth/presentation/view_models/auth_view_model.dart
- lib/features/subscription/presentation/providers/subscription_provider.dart

## Tasks

<task type="auto">
  <name>Create domain-layer provider wrappers</name>
  <files>
    lib/features/settings/domain/providers/ (new)
    lib/features/template_engine/domain/providers/ (existing — add missing)
    lib/features/auth/domain/providers/ (new)
    lib/features/subscription/domain/providers/ (new)
  </files>
  <action>
    For each violation, create a Riverpod provider in the feature's `domain/providers/` directory
    that wraps the data-layer dependency:

    1. **settings:** Move `notifications_provider.dart` to `domain/providers/` (or create a thin
       re-export provider there if different from current file)
    2. **template_engine:** Create `generation_repository_provider.dart` and
       `template_repository_provider.dart` in `domain/providers/` that expose the repository
       via a provider (some may already exist — check first, only create if missing)
    3. **auth:** Create `auth_repository_provider.dart` in `domain/providers/`
    4. **subscription:** Create `subscription_repository_provider.dart` in `domain/providers/`

    Each provider simply instantiates the data-layer class and returns it typed to the abstract
    interface (if one exists) or the concrete class.

    - What to avoid: Do NOT create unnecessary abstract interfaces — only move import paths.
      If the feature has no domain layer yet, create `domain/providers/` only.
      Do NOT change the repository implementations themselves.
  </action>
  <verify>find lib/features -path '*/domain/providers/*' -name '*.dart' | sort</verify>
  <done>Domain provider files exist for all 4 features</done>
</task>

<task type="auto">
  <name>Update presentation imports to use domain providers</name>
  <files>
    lib/features/settings/presentation/settings_screen.dart
    lib/features/settings/presentation/widgets/settings_sections.dart
    lib/features/template_engine/presentation/view_models/generation_view_model.dart
    lib/features/template_engine/presentation/providers/template_provider.dart
    lib/features/template_engine/presentation/providers/generation_policy_provider.dart
    lib/features/auth/presentation/view_models/auth_view_model.dart
    lib/features/subscription/presentation/providers/subscription_provider.dart
  </files>
  <action>
    In each file listed:
    1. Replace `import 'package:artio/features/X/data/...'` with the corresponding
       `import 'package:artio/features/X/domain/providers/...'`
    2. Verify the provider names match (may need to update `ref.watch(...)` calls if
       provider names changed)
    3. Run `flutter analyze` after each file to catch import errors early

    - What to avoid: Do NOT change widget logic, state management, or add new abstractions.
      This is a PURE import path correction.
  </action>
  <verify>python3 -c "
import os, re
for root, dirs, files in os.walk('lib/features'):
    for f in files:
        if f.endswith('.dart') and not f.endswith('.g.dart') and '/presentation/' in os.path.join(root, f):
            fp = os.path.join(root, f)
            with open(fp) as fh:
                for i, line in enumerate(fh, 1):
                    if re.search(r\"import 'package:artio/features/\w+/data/\", line):
                        print(f'VIOLATION: {fp}:{i}')
"
  # Should print nothing</verify>
  <done>Zero presentation→data imports remain; `flutter analyze` clean; all tests pass</done>
</task>

## Success Criteria
- [ ] Zero `presentation/ → data/` imports in feature source files
- [ ] Domain provider files exist for affected features
- [ ] `flutter analyze` clean
- [ ] All tests pass (`flutter test`)
