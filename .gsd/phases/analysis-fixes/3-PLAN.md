---
phase: analysis-fixes
plan: 3
wave: 3
depends_on: [2]
---

# Plan 3: Manual Fixes — Remaining Warnings & Infos

## Objective
Fix remaining issues that need code understanding: type inference failures,
strict raw types, dynamic calls, boolean parameter naming, unused elements,
and miscellaneous warnings.

## Context
- .gsd/ARCHITECTURE.md
- Remaining `flutter analyze` output after Plans 1-2

## Tasks

<task type="auto">
  <name>Fix inference failures and strict_raw_type (15+ issues)</name>
  <files>
    lib/features/auth/presentation/screens/login_screen.dart (2 — push<void>)
    lib/features/auth/presentation/screens/splash_screen.dart (2 — Future<void>.delayed)
    lib/features/auth/presentation/view_models/auth_view_model.dart (1 — StreamSubscription<AuthState>?)
    lib/features/gallery/presentation/pages/gallery_page.dart (1 — push<void>)
    lib/features/gallery/presentation/widgets/masonry_image_grid.dart (1 — Function return type)
    lib/features/template_engine/presentation/screens/template_detail_screen.dart (4)
    lib/features/template_engine/presentation/widgets/template_card.dart (4)
    test/ files (3 strict_raw_type)
  </files>
  <action>
    Add explicit type arguments where inference fails:
    - `context.push(...)` → `context.push<void>(...)`
    - `Future.delayed(...)` → `Future<void>.delayed(...)`
    - `StreamSubscription?` → `StreamSubscription<AuthState>?`
    - Add explicit return types on Function parameters
    - Add type parameters on generic test mocks
  </action>
  <verify>flutter analyze 2>&1 | grep "inference_failure\|strict_raw_type" | wc -l → 0</verify>
  <done>0 remaining inference/type issues</done>
</task>

<task type="auto">
  <name>Fix avoid_dynamic_calls, unawaited_futures, unused elements (10 issues)</name>
  <files>
    lib/features/gallery/data/repositories/gallery_repository.dart (2 — dynamic calls)
    lib/features/auth/presentation/screens/splash_screen.dart (2 — unawaited)
    lib/features/gallery/data/repositories/gallery_repository.dart (1 — depend_on_referenced_packages)
    lib/features/gallery/domain/repositories/i_gallery_repository.dart (1 — bool param)
    lib/features/gallery/presentation/providers/gallery_provider.dart (1 — bool param)
    lib/features/gallery/presentation/widgets/image_viewer_swipe_dismiss.dart (1 — bool param)
    lib/features/settings/data/notifications_provider.dart (1 — bool param)
    Various unused elements/imports (3-5)
  </files>
  <action>
    - Dynamic calls: cast to proper types or use explicit typed access
    - Unawaited futures: wrap with `unawaited()` from dart:async or `await`
    - Positional bool params: convert to named params `{required bool param}`
    - Unused imports/elements: remove
    - depend_on_referenced_packages: add `storage_client` to pubspec or use alternative import
  </action>
  <verify>flutter analyze 2>&1 | grep "avoid_dynamic\|unawaited\|unused_\|depend_on\|avoid_positional" | wc -l → 0</verify>
  <done>0 remaining issues in these categories</done>
</task>

<task type="auto">
  <name>Fix remaining miscellaneous issues</name>
  <files>
    lib/features/template_engine/domain/models/template_model.dart (5 — invalid_annotation_target)
    lib/features/template_engine/domain/policies/generation_policy.dart (1 — one_member_abstracts)
    lib/core/constants/generation_constants.dart (1 — dangling_library_doc_comments — may survive dart fix)
    lib/features/template_engine/presentation/helpers/generation_job_manager.dart (2 — comment_references)
    admin/pubspec.yaml (1 — asset_does_not_exist .env)
    pubspec.yaml (2 — sort_pub_dependencies — may survive dart fix)
  </files>
  <action>
    - invalid_annotation_target: move @JsonKey to constructor param or suppress
    - one_member_abstracts: convert to typedef or suppress if intentional
    - comment_references: fix doc comment references
    - asset_does_not_exist: create admin/.env or remove from assets
    - sort_pub_dependencies: alphabetize if dart fix missed them
  </action>
  <verify>flutter analyze 2>&1 | grep -E "info|warning|error" | grep -v "Analyzing|No issues" | wc -l → 0 or near 0</verify>
  <done>Total remaining issues ≤ 5 (acceptable suppressions only)</done>
</task>

## Success Criteria
- [ ] Total analysis issues ≤ 5
- [ ] No warnings or errors remain
- [ ] All tests still pass
- [ ] Clean commit
