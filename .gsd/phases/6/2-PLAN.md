---
phase: 6
plan: 2
wave: 2
---

# Plan 6.2: Watermark on Export & Settings Polish

## Objective
Ensure exported images (download/share) include the watermark for free users. Polish the settings subscription card to show credit balance alongside tier info.

## Context
- lib/features/gallery/presentation/pages/image_viewer_page.dart — `_download()` and `_share()` methods
- lib/features/gallery/data/repositories/gallery_repository.dart — `downloadImage()`, `getImageFile()` methods
- lib/features/settings/presentation/settings_screen.dart — `_SubscriptionCard` (lines 162-264)
- lib/features/credits/presentation/providers/credit_balance_provider.dart — credit balance provider
- lib/features/subscription/presentation/providers/subscription_provider.dart — subscription status

## Tasks

<task type="auto">
  <name>Create watermark image utility for export</name>
  <files>lib/core/utils/watermark_util.dart</files>
  <action>
    Create a `WatermarkUtil` class with a static method:
    ```dart
    static Future<Uint8List> applyWatermark(Uint8List imageBytes) async
    ```
    
    Implementation:
    1. Decode image bytes using `dart:ui` (`instantiateImageCodec` / `decodeImageFromList`)
    2. Create a Canvas/PictureRecorder at the image dimensions
    3. Draw the original image
    4. Draw "artio" text in bottom-right corner (same style as WatermarkOverlay — white, semi-transparent, small font)
    5. Encode back to PNG bytes
    6. Return watermarked image bytes
    
    Key points:
    - Use `dart:ui` only (no external deps)
    - Handle edge cases: very small images (skip watermark if image < 100px)
    - Keep watermark proportional to image size (e.g., fontSize = max(12, imageWidth * 0.04))
  </action>
  <verify>dart analyze lib/core/utils/watermark_util.dart — no errors</verify>
  <done>WatermarkUtil.applyWatermark() burns "artio" watermark text into image bytes, returns watermarked PNG</done>
</task>

<task type="auto">
  <name>Integrate watermark into download and share</name>
  <files>lib/features/gallery/presentation/pages/image_viewer_page.dart</files>
  <action>
    1. In `_ImageViewerPageState`, watch `subscriptionNotifierProvider` to get subscription status
    2. Modify `_download()`:
       - After downloading the image file, if user `isFree`:
         - Read file bytes
         - Apply `WatermarkUtil.applyWatermark(bytes)`  
         - Write watermarked bytes to the same file path
       - Subscribers: no change (download raw image as-is)
    3. Modify `_share()`:
       - After getting the image file, if user `isFree`:
         - Read file bytes
         - Apply `WatermarkUtil.applyWatermark(bytes)`
         - Write watermarked bytes to a temp file for sharing
       - Subscribers: share raw image as-is
    4. Keep the existing UX flow (loading indicators, error handling) unchanged
  </action>
  <verify>dart analyze lib/features/gallery/presentation/pages/image_viewer_page.dart — no errors</verify>
  <done>Free users download/share images with burned-in "artio" watermark; subscribers download/share clean images</done>
</task>

<task type="auto">
  <name>Enhance subscription card with credit balance</name>
  <files>lib/features/settings/presentation/settings_screen.dart</files>
  <action>
    1. In `_SubscriptionCard.build()`, also watch `creditBalanceNotifierProvider`
    2. For subscribers (non-free):
       - Below the renewal/expiry text, add a row showing:
         - Credits icon + "X credits remaining" (from credit balance)
         - Monthly allocation info: "200/mo" or "500/mo" (from `status.monthlyCredits`)
    3. For free users:
       - Add credit balance display: "X credits" below the "Upgrade for more credits" text
    4. Handle loading/error states for credit balance gracefully (show nothing if unavailable)
    5. Match existing design patterns (theme, spacing, text styles from nearby code)
  </action>
  <verify>dart analyze lib/features/settings/presentation/settings_screen.dart — no errors</verify>
  <done>Settings subscription card shows credit balance for both free and subscribed users, with monthly allocation for subscribers</done>
</task>

## Success Criteria
- [ ] `WatermarkUtil.applyWatermark()` exists and compiles
- [ ] Free users' downloaded images contain burned-in "artio" watermark
- [ ] Free users' shared images contain burned-in "artio" watermark
- [ ] Subscribers download/share clean images without watermark
- [ ] Settings subscription card shows credit balance
- [ ] `dart analyze` passes with no new errors
