---
phase: 2
plan: 4
wave: 3
depends_on: [1.5, 2.3]
files_modified:
  - test/core/utils/*.dart
  - test/features/**/*_test.dart
  - test/shared/widgets/*_test.dart
autonomous: true
must_haves:
  truths:
    - "Test coverage meaningfully improved for undertested areas"
    - "Extracted widgets from Plan 2.3 have basic tests"
    - "All tests pass"
  artifacts:
    - "New test files for extracted widgets"
    - "flutter test passes"
---

# Plan 2.4: Test Coverage Expansion

<objective>
Improve test coverage for areas identified as undertested. This merges the testing phases from both original plans to avoid duplication.

**Scope is focused, NOT "80% coverage":**
- New/extracted widgets from Plan 2.3 need tests
- Shared GradientButton needs tests
- Under-tested utilities (AppExceptionMapper)
- Key repository methods without test coverage

Purpose: Ensure extracted code and critical paths have test coverage.
Output: Targeted test additions
</objective>

<context>
Load for context:
- .gsd/phases/2/03-PLAN.md (what was extracted — need to know new file paths)
- test/ directory structure (what exists)
- lib/core/utils/app_exception_mapper.dart
- lib/shared/widgets/gradient_button.dart (new shared widget)
</context>

<tasks>

<task type="auto">
  <name>Test extracted widgets and shared components</name>
  <files>
    test/features/gallery/presentation/widgets/*_test.dart
    test/features/settings/presentation/widgets/*_test.dart
    test/shared/widgets/gradient_button_test.dart
  </files>
  <action>
    For each widget extracted in Plan 2.3:
    1. Create a basic widget test that verifies:
       - Widget renders without errors
       - Key interactive elements are present (buttons, text)
       - onPressed callbacks fire

    For GradientButton specifically:
    1. Create `test/shared/widgets/gradient_button_test.dart`
    2. Test: renders with text, onPressed fires, disabled state works

    Follow existing test patterns — check nearby test files for style conventions (mocktail mocking, ProviderScope wrapping if Riverpod widgets).

    AVOID: Don't write exhaustive tests for simple display widgets.
    AVOID: Don't test Flutter framework behavior (e.g., "BoxDecoration renders a gradient").
  </action>
  <verify>
    flutter test test/shared/widgets/
    flutter test test/features/gallery/presentation/
    flutter test test/features/settings/presentation/
  </verify>
  <done>
    - Each extracted widget has at least 1 test
    - GradientButton tested
    - All tests pass
  </done>
</task>

<task type="auto">
  <name>Expand utility and repository test coverage</name>
  <files>
    test/core/utils/app_exception_mapper_test.dart
  </files>
  <action>
    Create or expand `test/core/utils/app_exception_mapper_test.dart`:
    1. Test mapping for each error type:
       - SocketException → network error message
       - TimeoutException → timeout error message
       - PostgrestException → appropriate error
       - Unknown error → generic message
    2. Verify user-facing messages are user-friendly (no stack traces)

    AVOID: Don't duplicate tests that already exist.
    AVOID: Don't test Freezed-generated code.
  </action>
  <verify>
    flutter test test/core/utils/
  </verify>
  <done>
    - AppExceptionMapper has test coverage
    - All error types produce user-friendly messages
  </done>
</task>

</tasks>

<verification>
After all tasks, verify:
- [ ] `flutter test` (full suite) passes
- [ ] `flutter analyze` clean
- [ ] Extracted widgets have tests
- [ ] AppExceptionMapper tested
</verification>

<success_criteria>
- [ ] No untested extracted widgets
- [ ] Utility coverage improved
- [ ] Full test suite green
</success_criteria>
