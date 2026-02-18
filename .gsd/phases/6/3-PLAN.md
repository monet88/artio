---
phase: 6
plan: 3
wave: 2
---

# Plan 6.3: Comprehensive Testing

## Objective
Add tests for new watermark functionality, verify credit edge cases, and ensure the full test suite passes with all Phase 1-6 changes.

## Context
- lib/shared/widgets/watermark_overlay.dart — New widget from Plan 6.1
- lib/core/utils/watermark_util.dart — New utility from Plan 6.2
- test/features/gallery/ — Existing gallery tests
- test/features/create/presentation/view_models/create_view_model_test.dart — Credit check tests
- test/features/credits/ — Existing credit tests
- test/features/settings/presentation/screens/settings_screen_test.dart — Settings tests
- test/core/mocks/mock_repositories.dart — Mock setup

## Tasks

<task type="auto">
  <name>Add watermark widget and utility tests</name>
  <files>
    test/shared/widgets/watermark_overlay_test.dart
    test/core/utils/watermark_util_test.dart
  </files>
  <action>
    1. Create `test/shared/widgets/watermark_overlay_test.dart`:
       - Test: renders child directly when showWatermark=false (no "artio" text found)
       - Test: renders "artio" text when showWatermark=true
       - Test: child is always rendered regardless of showWatermark flag
    
    2. Create `test/core/utils/watermark_util_test.dart`:
       - Test: applyWatermark returns valid PNG bytes (check PNG header)
       - Test: applyWatermark output dimensions match input dimensions
       - Test: returns original bytes for very small images (< 100px) — or verify graceful handling
    
    Use existing test patterns from the codebase (pumpApp helper, Riverpod test utils).
  </action>
  <verify>flutter test test/shared/widgets/watermark_overlay_test.dart test/core/utils/watermark_util_test.dart</verify>
  <done>All watermark-related tests pass</done>
</task>

<task type="auto">
  <name>Update gallery and settings tests for watermark integration</name>
  <files>
    test/features/gallery/presentation/pages/gallery_page_test.dart
    test/features/gallery/presentation/widgets/masonry_image_grid_test.dart
    test/features/settings/presentation/screens/settings_screen_test.dart
  </files>
  <action>
    1. Update `gallery_page_test.dart`:
       - Ensure `subscriptionNotifierProvider` is mocked/overridden in test setup
       - Add test: gallery page passes showWatermark=true for free users
       - Add test: gallery page passes showWatermark=false for subscribers
    
    2. Update `masonry_image_grid_test.dart`:
       - Add test: watermark is visible on completed images when showWatermark=true
       - Add test: watermark is hidden when showWatermark=false
    
    3. Update `settings_screen_test.dart`:
       - Add test: subscription card shows credit balance for free users
       - Add test: subscription card shows credit balance and monthly allocation for subscribers
       - Ensure `creditBalanceNotifierProvider` is mocked/overridden
    
    All tests should use existing mock patterns (mocktail, ProviderScope overrides).
  </action>
  <verify>flutter test test/features/gallery/ test/features/settings/</verify>
  <done>All gallery and settings tests pass, including new watermark-related tests</done>
</task>

<task type="auto">
  <name>Full test suite verification</name>
  <files>test/</files>
  <action>
    1. Run the full test suite: `flutter test`
    2. Fix any failing tests caused by Phase 6 changes (e.g., missing mock overrides for subscription/credit providers)
    3. Common fixes expected:
       - Tests that pump `GalleryPage` may need `subscriptionNotifierProvider` override
       - Tests that pump `ImageViewerPage` may need subscription override
       - Tests that pump `SettingsScreen` may need `creditBalanceNotifierProvider` override
    4. Ensure all tests pass with 0 failures
    5. Run `dart analyze` across the full project to verify no lint issues
  </action>
  <verify>flutter test — 0 failures; dart analyze — no issues</verify>
  <done>Full test suite passes with 0 failures; dart analyze reports no issues</done>
</task>

## Success Criteria
- [ ] Watermark widget tests exist and pass
- [ ] Watermark utility tests exist and pass
- [ ] Gallery tests updated for watermark integration
- [ ] Settings tests updated for credit balance display
- [ ] Full `flutter test` suite passes with 0 failures
- [ ] `dart analyze` reports no issues
