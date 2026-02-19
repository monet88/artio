---
phase: 5
plan: 1
wave: 1
depends_on: []
files_modified:
  - admin/pubspec.yaml
  - lib/features/credits/domain/entities/credit_balance.dart
  - lib/theme/app_theme.dart
  - pubspec.yaml
  - lib/core/services/rewarded_ad_service.dart
  - lib/features/credits/presentation/providers/ad_reward_provider.dart
  - lib/features/subscription/domain/repositories/i_subscription_repository.dart
  - lib/features/template_engine/domain/policies/generation_policy.dart
  - test/core/helpers/pump_app.dart
  - test/features/auth/presentation/view_models/auth_view_model_redirect_test.dart
  - test/features/credits/presentation/providers/credit_balance_provider_test.dart
autonomous: true
user_setup: []

must_haves:
  truths:
    - "flutter analyze reports 0 issues (0 warnings, 0 info)"
    - "All existing tests still pass"
    - "No functional behavior changed"
  artifacts:
    - "No new files created (except possibly admin/.env placeholder)"
---

# Plan 5.1: Fix All Analyzer Warnings & Info Hints

<objective>
Resolve all 13 issues reported by `flutter analyze`: 4 warnings and 9 info-level hints.

Purpose: Achieve a clean analyzer output for CI/CD readiness and code hygiene.
Output: 0 issues from `flutter analyze`, all tests passing.
</objective>

<context>
Load for context:
- .gsd/ROADMAP.md (Phase 5 scope)
- Output of `flutter analyze` (13 issues)
</context>

<tasks>

<task type="auto">
  <name>Fix 4 warnings</name>
  <files>
    admin/pubspec.yaml
    lib/features/credits/domain/entities/credit_balance.dart
    lib/theme/app_theme.dart
  </files>
  <action>
    1. **`asset_does_not_exist`** — `admin/pubspec.yaml:45`
       Remove the `.env` asset entry from `admin/pubspec.yaml` flutter section.
       The admin dashboard loads env at runtime via `flutter_dotenv`, which reads
       from the filesystem — it doesn't need to be declared as a flutter asset.
       AVOID: Creating a placeholder `.env` file — it would be committed to git
       and might contain stale/wrong values.

    2. **`invalid_annotation_target` × 2** — `credit_balance.dart:9,11`
       Add `// ignore_for_file: invalid_annotation_target` at the top of the file
       (after imports, before `part` directives). This is the standard Freezed
       pattern — `@JsonKey` on factory constructor params is intentional and
       Freezed handles it correctly.
       AVOID: Removing the `@JsonKey` annotations — they're required for correct
       JSON serialization of snake_case DB column names.

    3. **`unused_field`** — `app_theme.dart:17`
       Remove the unused `_borderRadiusSm = 8.0` constant. It's not referenced
       anywhere in the theme config.
       AVOID: Replacing usages elsewhere to "use" it — that changes visual behavior.
  </action>
  <verify>flutter analyze 2>&1 | grep -c "warning" shows 0 warnings</verify>
  <done>All 4 warnings resolved; 0 warning-level issues remain</done>
</task>

<task type="auto">
  <name>Fix 9 info hints</name>
  <files>
    pubspec.yaml
    lib/core/services/rewarded_ad_service.dart
    lib/features/credits/presentation/providers/ad_reward_provider.dart
    lib/features/subscription/domain/repositories/i_subscription_repository.dart
    lib/features/template_engine/domain/policies/generation_policy.dart
    test/core/helpers/pump_app.dart
    test/features/auth/presentation/view_models/auth_view_model_redirect_test.dart
    test/features/credits/presentation/providers/credit_balance_provider_test.dart
  </files>
  <action>
    4. **`sort_pub_dependencies` × 2** — `pubspec.yaml:14,66`
       Sort `dependencies` and `dev_dependencies` alphabetically by package name.
       Keep SDK deps (`flutter`, `flutter_localizations`, `flutter_test`,
       `flutter_driver`, `integration_test`) at the top of their sections, then
       sort the rest alphabetically. Remove section comment headers (e.g.,
       `# State Management`) that break the alphabetical order.
       AVOID: Reordering SDK dependencies or changing version constraints.

    5. **`deprecated_member_use`** — `pump_app.dart:44`
       The `parent` parameter on `ProviderScope` is deprecated. The
       `pumpAppWithRouter` method is never called anywhere in the test suite.
       Remove the `parent` parameter entirely from `pumpAppWithRouter` and the
       corresponding `ProviderScope(parent: parent, ...)` usage.
       AVOID: Keeping dead parameters — they cause deprecation warnings and
       ProviderScope.parent is being removed in Riverpod 3.0.

    6. **`cascade_invocations` × 4** — 4 files
       Apply cascade operator (`..`) where the analyzer identifies unnecessary
       receiver duplication:

       a) `rewarded_ad_service.dart:21` — Change:
          ```dart
          final service = RewardedAdService();
          service.loadAd();
          ```
          To:
          ```dart
          final service = RewardedAdService()..loadAd();
          ```

       b) `ad_reward_provider.dart:47` — Change:
          ```dart
          ref.invalidateSelf();
          ref.invalidate(creditBalanceNotifierProvider);
          ```
          To:
          ```dart
          ref
            ..invalidateSelf()
            ..invalidate(creditBalanceNotifierProvider);
          ```

       c) `auth_view_model_redirect_test.dart:155` — Change:
          ```dart
          container.listen(authViewModelProvider, (_, __) {});
          final notifier = container.read(authViewModelProvider.notifier);
          ```
          To:
          ```dart
          container.listen(authViewModelProvider, (_, __) {});
          final notifier = container.read(authViewModelProvider.notifier);
          ```
          If cascade doesn't cleanly apply (need return value from `.read()`),
          suppress with `// ignore: cascade_invocations` on the second line.

       d) `credit_balance_provider_test.dart:53` — Change:
          ```dart
          final controller = StreamController<CreditBalance>();
          controller.addError(Exception('Stream error'));
          ```
          To:
          ```dart
          final controller = StreamController<CreditBalance>()
            ..addError(Exception('Stream error'));
          ```

    7. **`one_member_abstracts`** — `generation_policy.dart:5`
       Suppress with `// ignore: one_member_abstracts` on the line above
       `abstract class IGenerationPolicy`. The interface exists for testability
       and dependency inversion — this is an intentional architectural pattern.
       AVOID: Removing the abstract class or converting to a mixin — it would
       break the provider type and DI pattern.

    8. **`eol_at_end_of_file`** — `i_subscription_repository.dart:16`
       Ensure the file ends with exactly one trailing newline (no extra blank
       lines after the closing `}`).
  </action>
  <verify>flutter analyze 2>&1 | grep -c "info" shows 0 info issues</verify>
  <done>All 9 info hints resolved; 0 info-level issues remain</done>
</task>

<task type="auto">
  <name>Verify clean analyzer and passing tests</name>
  <files>-</files>
  <action>
    Run `flutter analyze` and confirm 0 issues.
    Run `flutter test` and confirm all tests pass.
    AVOID: Skipping the test run — cascade and deprecation fixes could
    introduce subtle breakages.
  </action>
  <verify>
    flutter analyze → "No issues found"
    flutter test → all tests pass (606+ tests)
  </verify>
  <done>0 analyzer issues, all tests passing, no functional changes</done>
</task>

</tasks>

<verification>
After all tasks, verify:
- [ ] `flutter analyze` reports "No issues found" (0 errors, 0 warnings, 0 info)
- [ ] `flutter test` passes with 606+ tests, 0 failures
- [ ] No behavioral changes — all fixes are cosmetic/lint-only
</verification>

<success_criteria>
- [ ] All 13 issues resolved
- [ ] Must-haves confirmed
- [ ] Clean commit ready
</success_criteria>
