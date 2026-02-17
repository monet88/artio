---
phase: 1
plan: 5
wave: 3
depends_on: [1.1, 1.2, 1.3, 1.4]
files_modified:
  - test/core/utils/retry_test.dart
  - test/features/auth/data/repositories/auth_repository_test.dart
  - test/features/auth/presentation/view_models/auth_view_model_test.dart
  - test/features/template_engine/data/repositories/generation_repository_test.dart
  - test/features/gallery/data/repositories/gallery_repository_test.dart
autonomous: true
must_haves:
  truths:
    - "Every edge case fix has a corresponding test"
    - "All tests pass including new tests"
  artifacts:
    - "Test files for each fix"
    - "flutter test passes"
---

# Plan 1.5: Edge Case Testing & Verification

<objective>
Write targeted tests for all edge case fixes from Plans 1.1-1.4. This is NOT a general "increase coverage to 80%" plan — it specifically tests the 8 bugs we fixed.

Purpose: Verify each fix works and prevent regression.
Output: Targeted test cases for each edge case fix
</objective>

<context>
Load for context:
- .gsd/phases/1/01-PLAN.md through 04-PLAN.md (what was fixed)
- lib/core/utils/date_time_utils.dart (new utility)
- lib/features/auth/presentation/view_models/auth_view_model.dart (guards + notifyRouter)
- lib/features/auth/data/repositories/auth_repository.dart (23505 handling)
- lib/features/template_engine/data/repositories/generation_repository.dart (429 + timeout)
- lib/core/utils/retry.dart (HandshakeException)
- lib/features/gallery/data/repositories/gallery_repository.dart (FileSystemException)
- Existing test files in test/ directory
</context>

<tasks>

<task type="auto">
  <name>Add retry utility tests for new transient errors</name>
  <files>
    test/core/utils/retry_test.dart
  </files>
  <action>
    Create or expand `test/core/utils/retry_test.dart`:

    Test cases:
    1. HandshakeException triggers retry
    2. AppException.network with statusCode 429 triggers retry
    3. AppException.generation does NOT trigger retry (this was the old bug)
    4. Max attempts limit works
    5. Exponential backoff increases delay

    Use `mocktail` for mocking (project convention).

    AVOID: Don't test SocketException/TimeoutException — those are already covered if tests exist.
  </action>
  <verify>flutter test test/core/utils/retry_test.dart</verify>
  <done>New transient error cases tested and passing</done>
</task>

<task type="auto">
  <name>Add auth concurrency and edge case tests</name>
  <files>
    test/features/auth/presentation/view_models/auth_view_model_test.dart
    test/features/auth/data/repositories/auth_repository_test.dart
  </files>
  <action>
    Expand existing auth tests:

    **auth_view_model_test.dart:**
    1. Test: calling signInWithEmail while already authenticating → returns immediately (no second request)
    2. Test: _handleSignedIn with null user → state is unauthenticated + router notified
    3. Test: _handleSignedIn with error → state is error + router notified

    **auth_repository_test.dart:**
    4. Test: _createUserProfile with PostgrestException code 23505 → returns silently
    5. Test: _createUserProfile with other PostgrestException → rethrows

    AVOID: Don't rewrite existing tests. Only ADD new test cases.
  </action>
  <verify>flutter test test/features/auth/</verify>
  <done>Concurrency guard and race condition tests passing</done>
</task>

<task type="auto">
  <name>Add generation repository and gallery edge case tests</name>
  <files>
    test/features/template_engine/data/repositories/generation_repository_test.dart
    test/features/gallery/data/repositories/gallery_repository_test.dart
  </files>
  <action>
    Expand existing tests:

    **generation_repository_test.dart:**
    1. Test: 429 response → throws AppException.network (not generation)
    2. Test: FunctionException with 429 → throws AppException.network
    3. Test: timeout → throws AppException.network with statusCode 408

    **gallery_repository_test.dart:**
    4. Test: FileSystemException during save → throws AppException.storage
    5. Test: invalid DateTime in job data → uses fallback instead of crashing

    AVOID: Don't rewrite existing tests. Only ADD new test cases for the edge cases we fixed.
  </action>
  <verify>
    flutter test test/features/template_engine/
    flutter test test/features/gallery/
  </verify>
  <done>
    - 429 retry, timeout, and error classification tests passing
    - DateTime parsing and file error tests passing
  </done>
</task>

</tasks>

<verification>
After all tasks, verify:
- [ ] `flutter test` (full suite) passes
- [ ] `flutter analyze` clean
- [ ] Each of the 8 edge case fixes has at least 1 test
</verification>

<success_criteria>
- [ ] All new tests pass
- [ ] No regression in existing tests
- [ ] Full flutter test suite green
</success_criteria>
