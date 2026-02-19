---
phase: 2
plan: 3
wave: 2
---

# Plan 2.3: Gallery & Misc Widget Extraction

## Objective
Break remaining 5 oversized files in gallery feature and misc areas into focused components.

**Targets:**
| File | Lines | Target |
|------|-------|--------|
| `gallery_repository.dart` | 313 | ≤250 |
| `generation_progress.dart` | 306 | ≤250 |
| `image_viewer_page.dart` | 302 | ≤250 |
| `empty_gallery_state.dart` | 285 | ≤250 |
| `masonry_image_grid.dart` | 279 | ≤250 |
| `register_screen.dart` | 252 | on the edge — only if natural split exists |

## Context
- lib/features/gallery/data/repositories/gallery_repository.dart
- lib/features/gallery/presentation/pages/image_viewer_page.dart
- lib/features/gallery/presentation/widgets/empty_gallery_state.dart
- lib/features/gallery/presentation/widgets/masonry_image_grid.dart
- lib/features/template_engine/presentation/widgets/generation_progress.dart

## Tasks

<task type="auto">
  <name>Extract gallery repository and viewer widgets</name>
  <files>
    lib/features/gallery/data/repositories/gallery_repository.dart
    lib/features/gallery/presentation/pages/image_viewer_page.dart
    lib/features/gallery/presentation/widgets/empty_gallery_state.dart
    lib/features/gallery/presentation/widgets/masonry_image_grid.dart
  </files>
  <action>
    **gallery_repository.dart (313 → ≤250):**
    1. Extract query builder helpers or storage utility methods into a private helper file
       `gallery_query_helpers.dart` in the same directory
    2. Keep repository class as the public interface

    **image_viewer_page.dart (302 → ≤250):**
    1. Extract toolbar/action buttons or image display section to a widget file

    **empty_gallery_state.dart (285 → ≤250):**
    1. Extract animation or illustration section to a widget

    **masonry_image_grid.dart (279 → ≤250):**
    1. Extract the grid item builder or image tile into a separate widget

    - What to avoid: Do NOT change public APIs of the repository or widget constructors.
      Do NOT change the gallery query logic or RLS patterns.
  </action>
  <verify>wc -l lib/features/gallery/data/repositories/gallery_repository.dart lib/features/gallery/presentation/pages/image_viewer_page.dart lib/features/gallery/presentation/widgets/empty_gallery_state.dart lib/features/gallery/presentation/widgets/masonry_image_grid.dart</verify>
  <done>All 4 files ≤250 lines; tests pass</done>
</task>

<task type="auto">
  <name>Extract generation_progress widget</name>
  <files>
    lib/features/template_engine/presentation/widgets/generation_progress.dart
  </files>
  <action>
    **generation_progress.dart (306 → ≤250):**
    1. Identify the largest subtree (progress bar + status text OR error state section)
    2. Extract into a focused widget in the same directory
    3. Import back and compose

    - What to avoid: Do NOT change the animation timing or state transitions.
  </action>
  <verify>wc -l lib/features/template_engine/presentation/widgets/generation_progress.dart</verify>
  <done>File ≤250 lines; `flutter analyze` clean; tests pass</done>
</task>

## Success Criteria
- [ ] All 5 target files ≤ 250 lines
- [ ] No new lint warnings
- [ ] All tests pass (`flutter test`)
- [ ] 0 files over 250-line target remaining in `lib/` (excluding generated files)
