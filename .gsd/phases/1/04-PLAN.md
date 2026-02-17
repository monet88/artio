---
phase: 1
plan: 4
wave: 2
depends_on: []
files_modified:
  - lib/features/gallery/data/repositories/gallery_repository.dart
autonomous: true
must_haves:
  truths:
    - "FileSystemException is caught and classified as AppException.storage"
    - "Temp files are cleaned up in finally blocks"
  artifacts:
    - "FileSystemException catch in download method"
    - "finally block with file cleanup"
---

# Plan 1.4: Storage Operations Safety

<objective>
Fix file operation error handling in gallery_repository.dart:
1. `writeAsBytes` has no try-catch — `FileSystemException` bypasses error handling
2. File errors misclassified as network errors
3. Temp file cleanup not guaranteed

Purpose: Correct error classification and ensure cleanup.
Output: Proper error handling for file I/O operations
</objective>

<context>
Load for context:
- lib/features/gallery/data/repositories/gallery_repository.dart (download methods, lines 240-280)
- lib/core/exceptions/app_exception.dart (AppException.storage confirmed via Serena)
- artifacts/superpowers/brainstorm.md (verification evidence)
</context>

<tasks>

<task type="auto">
  <name>Fix error classification and cleanup in file operations</name>
  <files>
    lib/features/gallery/data/repositories/gallery_repository.dart
  </files>
  <action>
    Find the download/save method that has `file.writeAsBytes(response.bodyBytes)` around line 250.

    1. **Fix error classification** in the catch block (around line 277-280):
       If the current catch is:
       ```dart
       catch (e) {
         if (e is AppException) rethrow;
         throw AppException.network(message: 'Failed to download image');
       }
       ```
       Change to:
       ```dart
       catch (e) {
         if (e is AppException) rethrow;
         if (e is FileSystemException) {
           throw AppException.storage(message: 'Failed to save image: ${e.message}');
         }
         throw AppException.network(message: 'Failed to download image');
       }
       ```
       Add `import 'dart:io' show FileSystemException;` if not covered by existing `dart:io` import.

    2. **Ensure temp file cleanup** — If there's a temp file pattern, wrap in try-finally:
       ```dart
       File? tempFile;
       try {
         // ... download logic
         tempFile = File('${directory.path}/$fileName');
         await tempFile.writeAsBytes(response.bodyBytes);
         return tempFile;
       } catch (e) {
         // cleanup on error
         if (tempFile != null && tempFile.existsSync()) {
           tempFile.deleteSync();
         }
         if (e is AppException) rethrow;
         if (e is FileSystemException) {
           throw AppException.storage(message: 'Failed to save image: ${e.message}');
         }
         throw AppException.network(message: 'Failed to download image');
       }
       ```

    AVOID: Don't add disk space pre-check (`_hasEnoughSpace`) — the brainstorm flagged this as a no-op. Handle errors AFTER they occur.
    AVOID: Don't change the method's return type or signature.
    AVOID: Don't modify the Supabase storage upload/delete methods — only fix local file I/O.
  </action>
  <verify>
    flutter analyze lib/features/gallery/
    grep -n "FileSystemException" lib/features/gallery/data/repositories/gallery_repository.dart → should find catch clause
    grep -n "AppException.storage" lib/features/gallery/data/repositories/gallery_repository.dart → should find throw
  </verify>
  <done>
    - FileSystemException caught and classified as AppException.storage
    - Network errors still classified as AppException.network
    - Temp files cleaned up on error
    - Existing tests still pass
  </done>
</task>

</tasks>

<verification>
After all tasks, verify:
- [ ] `flutter test test/features/gallery/` passes
- [ ] `flutter analyze` clean
- [ ] FileSystemException → AppException.storage
- [ ] Temp file cleanup on error path
</verification>

<success_criteria>
- [ ] File operation errors correctly classified
- [ ] No file leaks on error
- [ ] No regression in gallery download/share flow
</success_criteria>
