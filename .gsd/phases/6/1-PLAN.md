---
phase: 6
plan: 1
wave: 1
---

# Plan 6.1: Watermark Overlay Widget & Display Integration

## Objective
Create a reusable watermark overlay widget and integrate it into the gallery views (masonry grid and full-screen viewer). Free-tier users see a subtle "artio" watermark on their generated images; subscribers do not.

## Context
- .gsd/SPEC.md — Lines 40, 49, 68-69, 104-105 (watermark requirements)
- lib/features/gallery/presentation/widgets/masonry_image_grid.dart — Gallery grid, needs watermark on completed images
- lib/features/gallery/presentation/widgets/image_viewer_image_page.dart — Full-screen viewer, needs watermark overlay
- lib/features/subscription/presentation/providers/subscription_provider.dart — `subscriptionNotifierProvider` for tier check
- lib/features/subscription/domain/entities/subscription_status.dart — `isFree` getter
- lib/shared/widgets/ — Location for reusable widgets

## Tasks

<task type="auto">
  <name>Create WatermarkOverlay widget</name>
  <files>lib/shared/widgets/watermark_overlay.dart</files>
  <action>
    Create a new `WatermarkOverlay` StatelessWidget that:
    - Takes a `child` widget and `bool showWatermark`
    - When `showWatermark` is false, renders child directly (no overhead)
    - When true, wraps child in a Stack with a positioned "artio" text in the bottom-right corner
    - Text styling: white, semi-transparent (0.4 opacity), 12sp font, slight shadow for readability on any background
    - Small padding from the corner (8px bottom, 12px right)
    - Keep it simple — just a text overlay, no complex image manipulation
    - Do NOT use `IgnorePointer` unless the overlay actually intercepts gestures (it won't — it's just a Text)
  </action>
  <verify>dart analyze lib/shared/widgets/watermark_overlay.dart — no errors</verify>
  <done>WatermarkOverlay widget exists, renders "artio" text overlay on child when showWatermark=true, passes through child when false</done>
</task>

<task type="auto">
  <name>Integrate watermark into gallery masonry grid</name>
  <files>lib/features/gallery/presentation/widgets/masonry_image_grid.dart, lib/features/gallery/presentation/pages/gallery_page.dart</files>
  <action>
    1. Add a `bool showWatermark` parameter to `MasonryImageGrid` constructor
    2. Pass it through to `_InteractiveGalleryItem` 
    3. In `_buildGalleryItem`, wrap the completed-image Hero/ClipRRect subtree with `WatermarkOverlay(showWatermark: showWatermark, child: ...)`
    4. In `GalleryPage` — watch `subscriptionNotifierProvider`, derive `showWatermark` from `status.isFree`
       - Convert `GalleryPage` from `ConsumerWidget` to use subscription provider
       - Pass `showWatermark` to `MasonryImageGrid`
       - Default to `true` if subscription status is loading/error (safe default — free users are the majority)
  </action>
  <verify>dart analyze lib/features/gallery/ — no errors</verify>
  <done>Gallery masonry grid shows watermark on completed images for free users, no watermark for subscribers</done>
</task>

<task type="auto">
  <name>Integrate watermark into full-screen image viewer</name>
  <files>lib/features/gallery/presentation/widgets/image_viewer_image_page.dart, lib/features/gallery/presentation/pages/image_viewer_page.dart</files>
  <action>
    1. Add `bool showWatermark` parameter to `ImageViewerImagePage`
    2. Wrap the image content (the Image.network inside Hero) with `WatermarkOverlay`
    3. In `ImageViewerPage` — watch `subscriptionNotifierProvider`, derive `showWatermark`
       - ImageViewerPage is already a ConsumerStatefulWidget
       - Pass `showWatermark` to `ImageViewerImagePage` in the PageView.builder
  </action>
  <verify>dart analyze lib/features/gallery/ — no errors</verify>
  <done>Full-screen image viewer shows watermark for free users, no watermark for subscribers</done>
</task>

## Success Criteria
- [ ] `WatermarkOverlay` widget exists in `lib/shared/widgets/`
- [ ] Gallery masonry grid shows subtle "artio" watermark on completed images for free users
- [ ] Full-screen image viewer shows watermark for free users
- [ ] Subscribers (Pro/Ultra) see no watermark in either view
- [ ] `dart analyze` passes with no new errors
