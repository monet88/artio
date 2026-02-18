---
phase: pr-fixes
plan: 1
wave: 1
---

# Plan PR-Fixes.1: Watermark Safety & Resource Cleanup

## Objective
Fix two blockers and one resource leak in the watermark implementation:
- **B1**: `WatermarkUtil.applyWatermark()` force-unwraps `toByteData()` which can return null, causing a crash
- **B2**: Temporary watermarked file created during sharing is never deleted, leaking disk space
- **N1**: Image codec from `instantiateImageCodec()` is never disposed, leaking memory

## Context
- `lib/core/utils/watermark_util.dart` — the utility that burns watermarks into images
- `lib/features/gallery/presentation/pages/image_viewer_page.dart` — download/share flow
- `test/core/utils/watermark_util_test.dart` — existing watermark tests

## Tasks

<task type="auto">
  <name>Fix null safety and resource disposal in WatermarkUtil</name>
  <files>lib/core/utils/watermark_util.dart</files>
  <action>
    In `WatermarkUtil.applyWatermark()`:

    1. **Dispose codec** — After `codec.getNextFrame()`, add `codec.dispose()` to prevent memory leaks.
       Also dispose codec in the early-return path (small image).

    2. **Handle null `toByteData()`** — Replace the force-unwrap `byteData!.buffer.asUint8List()` with a null check:
       ```dart
       if (byteData == null) {
         image.dispose();
         rendered.dispose();
         return imageBytes; // Graceful fallback: return original
       }
       return byteData.buffer.asUint8List();
       ```
       Note: `image.dispose()` and `rendered.dispose()` currently run AFTER the force-unwrap (line 71),
       so a null would also leak those resources. Move the dispose calls BEFORE the null check,
       or handle them in both paths.

    3. **Keep the method signature unchanged** — still returns `Future<Uint8List>`.
  </action>
  <verify>
    ```bash
    cd /Users/gold/workspace/artio && dart analyze lib/core/utils/watermark_util.dart
    cd /Users/gold/workspace/artio && flutter test test/core/utils/watermark_util_test.dart
    ```
  </verify>
  <done>
    - `toByteData()` null case returns original image bytes instead of crashing
    - `codec.dispose()` called in both normal and early-return paths
    - All existing watermark tests still pass
    - No analyzer warnings
  </done>
</task>

<task type="auto">
  <name>Delete temporary watermarked file after sharing</name>
  <files>lib/features/gallery/presentation/pages/image_viewer_page.dart</files>
  <action>
    In `_share()` method, the free-user branch (line 133-143):

    1. Wrap the share call in a `try/finally` that deletes the temp file:
       ```dart
       if (_isFreeUser) {
         final bytes = await file.readAsBytes();
         final watermarked = await WatermarkUtil.applyWatermark(bytes);
         final watermarkedFile = File(
           '${file.parent.path}/watermarked_${file.uri.pathSegments.last}',
         );
         await watermarkedFile.writeAsBytes(watermarked);
         try {
           await SharePlus.instance.share(
             ShareParams(
               files: [XFile(watermarkedFile.path)],
               text: 'Created with Artio',
             ),
           );
         } finally {
           await watermarkedFile.delete().catchError((_) => watermarkedFile);
         }
       }
       ```

    2. Do NOT change the subscriber path — it shares the original file which is managed by the cache.
  </action>
  <verify>
    ```bash
    cd /Users/gold/workspace/artio && dart analyze lib/features/gallery/presentation/pages/image_viewer_page.dart
    ```
  </verify>
  <done>
    - Temporary watermarked file is deleted after sharing completes (or fails)
    - `catchError` prevents deletion failure from propagating
    - No analyzer warnings
  </done>
</task>

## Success Criteria
- [ ] `WatermarkUtil.applyWatermark()` gracefully handles null `toByteData()` by returning original bytes
- [ ] Image codec is disposed in all code paths
- [ ] Temporary watermarked files are cleaned up after sharing
- [ ] All existing tests pass: `flutter test test/core/utils/watermark_util_test.dart`
- [ ] `dart analyze` clean on both modified files
