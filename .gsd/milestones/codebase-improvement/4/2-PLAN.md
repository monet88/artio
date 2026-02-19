---
phase: 4
plan: 2
wave: 2
---

# Plan 4.2: Core & Settings Test Coverage

## Objective
Close test gaps in core utilities and the settings feature:
- **core**: 22 source files, 6 test files (27% file coverage)
- **settings**: 6 source files, 2 test files (33% file coverage)

Priority: untested core utilities that are used across multiple features,
and settings data/domain layers.

## Context
- lib/core/ (22 source files)
- lib/features/settings/ (6 source files)
- test/core/ (6 existing tests)
- test/features/settings/ (2 existing tests)

**Existing core tests:**
- `ai_models_test.dart`, `watermark_util_test.dart`, `app_exception_mapper_test.dart`,
  `retry_test.dart`, `date_time_utils_test.dart`, `subagent_smoke_codegen_test.dart`

**High-priority untested core files:**
- `core/exceptions/app_exception.dart` (sealed class — test all variants)
- `core/services/rewarded_ad_service.dart` (AdMob service)
- `core/state/user_scoped_providers.dart` (shared providers)
- `core/utils/connectivity_monitor.dart` (network connectivity)
- `core/utils/extensions.dart` (extension methods)

**Settings gaps:**
- `settings/data/notifications_provider.dart`
- `settings/presentation/widgets/settings_sections.dart`

## Tasks

<task type="auto">
  <name>Write core module tests</name>
  <files>
    test/core/exceptions/app_exception_test.dart (new)
    test/core/services/rewarded_ad_service_test.dart (new)
    test/core/utils/connectivity_monitor_test.dart (new)
    test/core/utils/extensions_test.dart (new)
  </files>
  <action>
    1. **app_exception_test:** Test all sealed class variants (network, auth, storage, payment,
       generation, unknown), verify `message` and `code` fields, test `when/maybeWhen` pattern matching
    2. **rewarded_ad_service_test:** Mock Google Mobile Ads SDK. Test ad loading, showing,
       reward callback, error handling, and daily limit tracking
    3. **connectivity_monitor_test:** Mock connectivity_plus. Test online/offline state transitions
    4. **extensions_test:** Test all extension methods (string, context, etc.)

    Use mocktail for mocking. Keep tests focused and fast.

    - What to avoid: Do NOT test generated freezed code (constructors/copyWith are auto-tested).
      Do NOT make real network or ad SDK calls.
  </action>
  <verify>flutter test test/core/ --reporter expanded</verify>
  <done>4 new test files; all tests GREEN</done>
</task>

<task type="auto">
  <name>Write settings feature tests</name>
  <files>
    test/features/settings/data/notifications_provider_test.dart (new)
    test/features/settings/presentation/widgets/settings_sections_test.dart (new)
  </files>
  <action>
    1. **notifications_provider_test:** Test the shared preferences-backed notification
       toggle provider reads and writes correctly
    2. **settings_sections_test:** Widget test ensuring all section tiles render, theme toggle works,
       notification toggle works, about dialog opens, and account-related actions call correct handlers

    Follow existing test patterns in `test/features/settings/`.

    - What to avoid: Do NOT test platform-specific notification permissions (out of scope).
  </action>
  <verify>flutter test test/features/settings/ --reporter expanded</verify>
  <done>2 new test files; all tests GREEN</done>
</task>

## Success Criteria
- [ ] Core: 10+ test files (was 6)
- [ ] Settings: 4+ test files (was 2)
- [ ] All new tests pass
- [ ] All existing tests still pass
- [ ] `flutter analyze` clean
- [ ] Total test file count: 70+ (was 61)
