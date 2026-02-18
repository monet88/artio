---
phase: 2
plan: 2
wave: 1
---

# Plan 2.2: Screen Widget Extraction

## Objective
Break 4 oversized screen files into smaller widgets. These screens contain inline widget trees
that should be extracted into dedicated widget files within each feature's `widgets/` directory.

**Targets:**
| File | Lines | Target |
|------|-------|--------|
| `create_screen.dart` | 354 | ≤250 |
| `settings_screen.dart` | 336 | ≤250 |
| `template_detail_screen.dart` | 320 | ≤250 |
| `home_screen.dart` | 270 | ≤250 |

## Context
- lib/features/create/presentation/create_screen.dart
- lib/features/settings/presentation/settings_screen.dart
- lib/features/template_engine/presentation/screens/template_detail_screen.dart
- lib/features/template_engine/presentation/screens/home_screen.dart

## Tasks

<task type="auto">
  <name>Extract create_screen and settings_screen widgets</name>
  <files>
    lib/features/create/presentation/create_screen.dart
    lib/features/create/presentation/widgets/ (new widget files)
    lib/features/settings/presentation/settings_screen.dart
    lib/features/settings/presentation/widgets/ (new widget files)
  </files>
  <action>
    **create_screen.dart (354 → ≤250):**
    1. Read the file and identify extractable widget subtrees (model selector section,
       prompt input area, generation controls, etc.)
    2. Extract 1-2 large widget subtrees into new files under `widgets/`
    3. Import them back in `create_screen.dart`

    **settings_screen.dart (336 → ≤250):**
    1. Identify sections already partially extracted to `settings_sections.dart`
    2. Extract remaining inline sections into new widget files
    3. Keep `settings_screen.dart` as the composition scaffold

    - What to avoid: Do NOT change method signatures, state management, or navigation logic.
      Do NOT rename public classes. This is purely moving widget subtrees.
  </action>
  <verify>wc -l lib/features/create/presentation/create_screen.dart lib/features/settings/presentation/settings_screen.dart</verify>
  <done>Both files ≤250 lines; `flutter analyze` clean; affected tests pass</done>
</task>

<task type="auto">
  <name>Extract template_detail_screen and home_screen widgets</name>
  <files>
    lib/features/template_engine/presentation/screens/template_detail_screen.dart
    lib/features/template_engine/presentation/screens/home_screen.dart
    lib/features/template_engine/presentation/widgets/ (new widget files)
  </files>
  <action>
    **template_detail_screen.dart (320 → ≤250):**
    1. Extract the template preview section or input form section into a dedicated widget
    2. Import back and compose

    **home_screen.dart (270 → ≤250):**
    1. Extract the search/filter bar or template grid section into a widget
    2. Import back and compose

    - What to avoid: Do NOT change GoRouter route parameters or navigation behavior.
      Do NOT change provider reads/watches.
  </action>
  <verify>wc -l lib/features/template_engine/presentation/screens/template_detail_screen.dart lib/features/template_engine/presentation/screens/home_screen.dart</verify>
  <done>Both files ≤250 lines; `flutter analyze` clean; affected tests pass</done>
</task>

## Success Criteria
- [ ] All 4 screen files ≤ 250 lines
- [ ] No new lint warnings (`flutter analyze`)
- [ ] All tests pass (`flutter test`)
- [ ] No functional changes (pure widget extraction)
