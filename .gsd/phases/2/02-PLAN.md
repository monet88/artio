---
phase: 2
plan: 2
wave: 1
depends_on: []
files_modified:
  - lib/features/create/presentation/view_models/create_view_model.dart
  - lib/features/gallery/presentation/pages/gallery_page.dart
  - lib/features/gallery/data/repositories/gallery_repository.dart
autonomous: true
must_haves:
  truths:
    - "create_view_model.dart and gallery_page.dart dependency violations fixed"
    - "Data layer imports removed from Presentation layer files"
  artifacts:
    - "No presentation → data imports remain (except auth_view_model which is correct Riverpod)"
---

# Plan 2.2: Architecture Compliance (2 Violations)

<objective>
Fix 2 Clean Architecture violations where Presentation layer imports Data layer directly.

**NOT fixing:** `auth_view_model.dart` → `authRepositoryProvider` — this is a Riverpod convention (provider access via `ref.read`), NOT a violation. Confirmed via Serena `find_referencing_symbols` (9 refs, all via provider).

Purpose: Enforce Clean Architecture dependency rule (Presentation → Domain only, not → Data).
Output: Corrected imports using domain abstractions
</objective>

<context>
Load for context:
- .gsd/ARCHITECTURE.md (architecture section)
- lib/features/create/presentation/view_models/create_view_model.dart
- lib/features/gallery/presentation/pages/gallery_page.dart (or wherever galleryProvider is)
- lib/features/gallery/data/repositories/gallery_repository.dart
- plans/260217-1647-codebase-improvement/phase-03-architecture-compliance.md (details of violations)
</context>

<tasks>

<task type="auto">
  <name>Fix create_view_model.dart data layer import</name>
  <files>
    lib/features/create/presentation/view_models/create_view_model.dart
  </files>
  <action>
    Find the import that references the data layer directly (e.g., importing a repository implementation instead of going through a provider or domain interface).

    Steps:
    1. Identify the offending import (should reference `data/repositories/`)
    2. Check if a provider already exists in a `.g.dart` file (Riverpod codegen)
    3. If provider exists → change import to use the provider file
    4. If no provider → create one in the domain layer

    The fix pattern should follow the same convention as `auth_view_model.dart`:
    - Import the `.g.dart` provider, NOT the concrete repository class

    AVOID: Don't change the actual business logic — only fix the import path.
    AVOID: Don't refactor the entire file.
  </action>
  <verify>
    grep -rn "data/repositories" lib/features/create/presentation/ → should return 0 results
    flutter analyze lib/features/create/
  </verify>
  <done>
    - No data layer imports in create/presentation/
    - flutter analyze clean
  </done>
</task>

<task type="auto">
  <name>Fix gallery_page.dart data layer import</name>
  <files>
    lib/features/gallery/presentation/pages/gallery_page.dart
    lib/features/gallery/data/repositories/gallery_repository.dart
  </files>
  <action>
    Same pattern as Task 1:
    1. Find the offending import in gallery presentation that references data layer
    2. Check if the referenced symbol has a Riverpod provider
    3. If provider exists → use provider import
    4. If not → the import may be for a type that should be in domain layer → move it

    AVOID: Don't change the data layer's internal logic.
    AVOID: Don't touch gallery_repository.dart unless moving a type to domain layer.
  </action>
  <verify>
    grep -rn "data/repositories" lib/features/gallery/presentation/ → should return 0 results
    flutter analyze lib/features/gallery/
  </verify>
  <done>
    - No data layer imports in gallery/presentation/
    - flutter analyze clean
  </done>
</task>

</tasks>

<verification>
After all tasks, verify:
- [ ] `grep -rn "data/repositories" lib/features/create/presentation/` → 0 results
- [ ] `grep -rn "data/repositories" lib/features/gallery/presentation/` → 0 results
- [ ] `flutter analyze` clean
- [ ] `flutter test` passes
</verification>

<success_criteria>
- [ ] 2 architecture violations fixed
- [ ] auth_view_model.dart untouched (false positive)
- [ ] No regression in existing functionality
</success_criteria>
