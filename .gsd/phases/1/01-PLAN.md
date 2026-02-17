---
phase: 1
plan: 1
wave: 1
depends_on: []
files_modified:
  - lib/core/utils/date_time_utils.dart
  - lib/features/gallery/data/repositories/gallery_repository.dart
  - test/core/utils/date_time_utils_test.dart
autonomous: true
must_haves:
  truths:
    - "DateTime.parse is never called directly in repository code"
    - "Invalid date strings do not crash the app"
  artifacts:
    - "lib/core/utils/date_time_utils.dart exists with safeParseDateTime"
    - "test/core/utils/date_time_utils_test.dart passes"
---

# Plan 1.1: DateTime Parsing Safety

<objective>
Fix DateTime parsing crash: `DateTime.parse()` called without try-catch in `gallery_repository.dart` — crashes on invalid server dates.

Purpose: Prevent crash on bad server data.
Output: Safe date parsing utility with tests
</objective>

<context>
Load for context:
- .gsd/ARCHITECTURE.md (gallery section)
- lib/features/gallery/data/repositories/gallery_repository.dart (lines 60-70)
- artifacts/superpowers/brainstorm.md (verification evidence)
</context>

<tasks>

<task type="auto">
  <name>Create safeParseDateTime utility and update gallery_repository</name>
  <files>
    lib/core/utils/date_time_utils.dart
    lib/features/gallery/data/repositories/gallery_repository.dart
    test/core/utils/date_time_utils_test.dart
  </files>
  <action>
    1. Create `lib/core/utils/date_time_utils.dart` with:
       ```dart
       DateTime? safeParseDateTime(dynamic value, {DateTime? fallback}) {
         if (value == null) return fallback;
         try {
           return DateTime.parse(value.toString());
         } catch (_) {
           return fallback;
         }
       }
       ```
    2. Update `gallery_repository.dart` `_parseJob` method:
       - Replace `DateTime.parse(job['created_at'] as String)` at line 63 with:
         `safeParseDateTime(job['created_at']) ?? DateTime.now()`
       - Replace `DateTime.parse(job['deleted_at'] as String)` at line 67 with:
         `safeParseDateTime(job['deleted_at'])`
       - Add import for `date_time_utils.dart`
    3. Create `test/core/utils/date_time_utils_test.dart` with tests:
       - Valid ISO 8601 string → correct DateTime
       - Invalid string → returns fallback
       - Null → returns fallback
       - Empty string → returns fallback
       - Fallback parameter works

    AVOID: Don't change the function signature of `_parseJob` — only change the DateTime parsing calls inside it.
  </action>
  <verify>
    flutter test test/core/utils/date_time_utils_test.dart
    grep -rn "DateTime.parse" lib/features/gallery/data/repositories/ → should return 0 results
  </verify>
  <done>
    - safeParseDateTime utility exists and is tested
    - No raw DateTime.parse in gallery_repository.dart
    - All existing tests still pass
  </done>
</task>

</tasks>

<verification>
After all tasks, verify:
- [ ] `flutter test test/core/utils/` passes
- [ ] `flutter analyze` clean (no new warnings)
- [ ] No raw `DateTime.parse` in gallery_repository.dart
</verification>

<success_criteria>
- [ ] DateTime parsing never crashes on invalid input
- [ ] All tasks verified
</success_criteria>
