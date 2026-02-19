---
phase: 2
plan: 1
wave: 1
---

# Plan 2.1: Theme Extraction

## Objective
Break `lib/theme/app_theme.dart` (597 lines) into focused modules. This single file currently
contains light theme, dark theme, color schemes, text themes, component themes, and elevation/shape
constants — all concatenated. Extract into dedicated files grouped by responsibility.

## Context
- lib/theme/app_theme.dart (597 lines — biggest offender)
- .gsd/ARCHITECTURE.md (250-line target)

## Tasks

<task type="auto">
  <name>Audit and plan theme split</name>
  <files>lib/theme/app_theme.dart</files>
  <action>
    Read `app_theme.dart` and identify logical boundaries:
    1. **Color schemes** — `ColorScheme` definitions for light/dark
    2. **Text themes** — `TextTheme` definitions
    3. **Component themes** — `AppBarTheme`, `CardTheme`, `InputDecorationTheme`, etc.
    4. **ThemeData builders** — `lightTheme()` / `darkTheme()` top-level functions

    Create a split plan preserving public API (the two `ThemeData` getters).

    - What to avoid: Do NOT change any color values, font sizes, or theme semantics.
      This is a PURE structural refactor.
  </action>
  <verify>wc -l lib/theme/app_theme.dart</verify>
  <done>Split plan documented in commit message; boundaries identified</done>
</task>

<task type="auto">
  <name>Extract theme into focused files</name>
  <files>
    lib/theme/app_theme.dart
    lib/theme/app_colors.dart (new)
    lib/theme/app_text_theme.dart (new)
    lib/theme/app_component_themes.dart (new)
  </files>
  <action>
    1. Create `app_colors.dart` — all color constants, `ColorScheme` builders
    2. Create `app_text_theme.dart` — `TextTheme` definitions
    3. Create `app_component_themes.dart` — all component theme overrides
    4. Slim `app_theme.dart` to import and compose the above, exposing `lightTheme` / `darkTheme`
    5. Ensure all imports across the codebase still resolve (search for `package:artio/theme/`)
    6. Run `flutter analyze` — zero new issues

    - What to avoid: Do NOT rename the public API (`AppTheme.lightTheme` / `AppTheme.darkTheme`).
      Do NOT change barrel file exports. Existing callers must not change.
  </action>
  <verify>flutter analyze && wc -l lib/theme/*.dart</verify>
  <done>Each file ≤250 lines; `flutter analyze` clean; all tests pass</done>
</task>

## Success Criteria
- [ ] `app_theme.dart` ≤ 250 lines
- [ ] All new files ≤ 250 lines
- [ ] Public API unchanged (callers use same imports)
- [ ] `flutter analyze` clean
- [ ] All tests pass (`flutter test`)
