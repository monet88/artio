---
phase: 2
plan: 3
wave: 2
depends_on: [2.1, 2.2]
files_modified:
  - lib/features/gallery/presentation/pages/image_viewer_page.dart
  - lib/features/gallery/presentation/widgets/*
  - lib/features/settings/presentation/screens/settings_screen.dart
  - lib/features/settings/presentation/widgets/*
  - lib/shared/widgets/error_state_widget.dart
  - lib/shared/widgets/*
autonomous: true
must_haves:
  truths:
    - "No file exceeds 250 lines after extraction"
    - "Only widgets >50 lines are extracted into new files"
    - "_GradientButton has a single shared definition"
  artifacts:
    - "All new widget files are importable and used"
    - "flutter analyze clean"
---

# Plan 2.3: Code Quality — Widget Extraction

<objective>
Extract oversized widgets from files >200 lines to improve maintainability.

**Key correction from brainstorm:** Only extract widgets >50 lines. The original plan proposed 16 new files — this is over-fragmentation. Target ~8-10 new files for genuinely large widgets.

Files to address:
- `image_viewer_page.dart` (~350 lines)
- `settings_screen.dart` (~280 lines)
- `error_state_widget.dart` (~200 lines)

Also: deduplicate `_GradientButton` (exists in 2+ files).

Purpose: Split oversized files for better readability and maintenance.
Output: Smaller, focused widget files
</objective>

<context>
Load for context:
- lib/features/gallery/presentation/pages/image_viewer_page.dart (full file)
- lib/features/settings/presentation/screens/settings_screen.dart (full file)
- lib/shared/widgets/error_state_widget.dart (full file)
- plans/260217-1647-codebase-improvement/phase-02-code-quality.md (widget list — use as reference but apply >50 line filter)
</context>

<tasks>

<task type="auto">
  <name>Extract large widgets from image_viewer_page.dart</name>
  <files>
    lib/features/gallery/presentation/pages/image_viewer_page.dart
    lib/features/gallery/presentation/widgets/ (new files)
  </files>
  <action>
    1. Read `image_viewer_page.dart` and identify private widget classes >50 lines
    2. For each qualifying widget:
       - Create a new file in `lib/features/gallery/presentation/widgets/`
       - Make it a public class (remove underscore prefix)
       - Add proper import in `image_viewer_page.dart`
    3. After extraction, `image_viewer_page.dart` should be ≤250 lines

    Naming convention: snake_case matching the widget class name.
    Example: `_ImageToolbar` → `lib/features/gallery/presentation/widgets/image_toolbar.dart`

    AVOID: Don't extract tiny helper widgets (<50 lines) — keep them inline.
    AVOID: Don't change widget behavior — pure structural move.
    AVOID: Don't extract `build()` content that isn't a separate widget class.
  </action>
  <verify>
    wc -l lib/features/gallery/presentation/pages/image_viewer_page.dart → ≤250
    flutter analyze lib/features/gallery/
  </verify>
  <done>
    - image_viewer_page.dart ≤250 lines
    - Extracted widgets in separate files, importable and used
  </done>
</task>

<task type="auto">
  <name>Extract widgets from settings_screen and deduplicate _GradientButton</name>
  <files>
    lib/features/settings/presentation/screens/settings_screen.dart
    lib/features/settings/presentation/widgets/ (new files)
    lib/shared/widgets/gradient_button.dart (new, shared)
  </files>
  <action>
    1. **settings_screen.dart:**
       - Identify private widget classes >50 lines
       - Extract to `lib/features/settings/presentation/widgets/`
       - Target: ≤250 lines after extraction

    2. **_GradientButton deduplication:**
       - Find all `_GradientButton` definitions: `grep -rn "_GradientButton" lib/`
       - Create shared `lib/shared/widgets/gradient_button.dart` with public `GradientButton`
       - Update all files that define `_GradientButton` to import the shared one
       - Delete the duplicate private definitions

    3. **error_state_widget.dart:**
       - Only extract if there are clear sub-widgets >50 lines
       - If it's already a single cohesive widget, LEAVE IT as-is

    AVOID: Don't extract tiny helpers (<50 lines).
    AVOID: Don't change GradientButton behavior — just move and deduplicate.
  </action>
  <verify>
    wc -l lib/features/settings/presentation/screens/settings_screen.dart → ≤250
    grep -rn "_GradientButton" lib/ → should return 0 (no more private duplicates)
    grep -rn "GradientButton" lib/shared/widgets/ → should find shared definition
    flutter analyze lib/
  </verify>
  <done>
    - settings_screen.dart ≤250 lines
    - Single GradientButton in shared/widgets/
    - No duplicate _GradientButton definitions
    - All tests still pass
  </done>
</task>

</tasks>

<verification>
After all tasks, verify:
- [ ] No file >250 lines among extracted targets
- [ ] `flutter test` passes
- [ ] `flutter analyze` clean
- [ ] Only widgets >50 lines were extracted
- [ ] _GradientButton deduplicated to single shared widget
</verification>

<success_criteria>
- [ ] Oversized files split into maintainable sizes
- [ ] Shared widget deduplicated
- [ ] No behavioral changes
- [ ] All tests pass
</success_criteria>
