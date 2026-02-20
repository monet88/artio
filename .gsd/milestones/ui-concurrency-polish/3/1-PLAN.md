---
phase: 3
plan: 1
wave: 1
---

# Plan 3.1: Gallery UX & Guards

## Objective
Add size validation for image uploads (>10MB), implement manual pull-to-refresh for Gallery, and replace the Delete 'undo' UX with an explicit confirmation dialog.

## Context
- `lib/features/create/presentation/providers/image_picker_provider.dart` (or relevant file for picking images)
- `lib/features/gallery/presentation/screens/gallery_screen.dart`
- `lib/features/gallery/presentation/screens/image_detail_screen.dart`

## Tasks

<task type="auto">
  <name>Image Size Validation (>10MB)</name>
  <files>
    lib/features/create/presentation/providers/image_picker_provider.dart
    lib/core/utils/file_utils.dart (if needed)
  </files>
  <action>
    - When picking an image (for Image-to-Image), check the file length.
    - If size > 10MB (10 * 1024 * 1024 bytes), reject it and return a user-friendly error message.
  </action>
  <verify>grep_search `10485760` or `10 * 1024 * 1024` in `lib/features/create`</verify>
  <done>Images over 10MB cannot be picked/uploaded.</done>
</task>

<task type="auto">
  <name>Pull-to-refresh for Gallery</name>
  <files>lib/features/gallery/presentation/screens/gallery_screen.dart</files>
  <action>
    - Wrap the Gallery grid view (likely a CustomScrollView or GridView) in a Material `RefreshIndicator`.
    - The `onRefresh` callback should await `ref.refresh(galleryProvider.future)` or calling the specific refresh method on the view model so data is fetched live from Supabase.
  </action>
  <verify>grep_search `RefreshIndicator` in `lib/features/gallery/presentation/screens/gallery_screen.dart`</verify>
  <done>User can pull down on the gallery to manually refresh images.</done>
</task>

<task type="auto">
  <name>Delete Confirmation Dialog</name>
  <files>
    lib/features/gallery/presentation/widgets/gallery_grid.dart
    lib/features/gallery/presentation/screens/image_detail_screen.dart
  </files>
  <action>
    - Remove the Optimistic UI "Undo" snackbar logic.
    - When the delete button is tapped, show an `AlertDialog` asking "Are you sure you want to delete this image?" (Yes/Cancel).
    - Only perform the API delete request if the user confirms.
  </action>
  <verify>flutter analyze</verify>
  <done>Deleting an image safely prompts for confirmation first.</done>
</task>

## Success Criteria
- [ ] Users get a clear error when picking >10MB files.
- [ ] Swiping down on gallery forces cache invalidation and refetch.
- [ ] Accidentally tapping delete can be safely cancelled via the dialog.
