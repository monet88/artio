---
plan: 2
wave: 1
pr: "fix(credits): credit check policy, provider disposal, stream recovery"
---

# Plan 2: Credit Fixes

## Objective
Replace the stub `FreeBetaPolicy` with a real credit-checking policy, ensure
credit providers are invalidated on logout, and add error recovery to the
credit balance stream. Three related credit-system fixes in one PR.

## Context
- @plans/260220-0845-edge-case-fixes/plan.md — Full plan with code snippets
- @lib/features/template_engine/data/policies/free_beta_policy.dart — DELETE this
- @lib/features/template_engine/domain/policies/generation_policy.dart — Interface
- @lib/features/template_engine/presentation/providers/generation_policy_provider.dart — Update
- @lib/features/template_engine/presentation/view_models/generation_view_model.dart — NO changes (verify only)
- @lib/core/state/user_scoped_providers.dart — Add credit invalidation
- @lib/core/state/credit_balance_state_provider.dart — Barrel export
- @lib/features/credits/data/repositories/credit_repository.dart — Stream fix
- @lib/features/credits/presentation/providers/credit_balance_provider.dart — Provider ref

## Tasks

<task type="auto">
  <name>Replace FreeBetaPolicy with CreditCheckPolicy</name>
  <files>
    lib/features/template_engine/data/policies/credit_check_policy.dart (NEW)
    lib/features/template_engine/presentation/providers/generation_policy_provider.dart
    lib/features/template_engine/data/policies/free_beta_policy.dart (DELETE)
  </files>
  <action>
    1. Create `lib/features/template_engine/data/policies/credit_check_policy.dart`:
       - Class `CreditCheckPolicy implements IGenerationPolicy`
       - Constructor takes `Ref _ref`
       - `canGenerate()` reads `creditBalanceNotifierProvider` from ref
       - If balance is null (not loaded) → return `GenerationEligibility.allowed()`
       - If balance < 4 (minimumCost) → return `GenerationEligibility.denied(reason: 'Insufficient credits')`
       - Otherwise → return `GenerationEligibility.allowed(remainingCredits: balance)`

    2. Update `generation_policy_provider.dart`:
       - Change import from `free_beta_policy.dart` to `credit_check_policy.dart`
       - Change import from domain provider to data policies
       - Return `CreditCheckPolicy(ref)` instead of `const FreeBetaPolicy()`

    3. Delete `free_beta_policy.dart`

    4. Search codebase for any remaining imports of `free_beta_policy.dart` and remove them.
       Known references:
       - `generation_policy_provider.dart` (import)
       - `test/.../generation_policy_provider_test.dart` (import + test assertions)
       - `test/.../free_beta_policy_test.dart` (entire file — DELETE)

    5. Run `dart run build_runner build --delete-conflicting-outputs` to regenerate
       provider code (generation_policy_provider.g.dart).

    DO NOT modify generation_policy.dart (the interface) — keep signature unchanged.
    DO NOT modify generation_view_model.dart — it already uses canGenerate() correctly.
  </action>
  <verify>flutter analyze lib/features/template_engine/</verify>
  <done>
    - credit_check_policy.dart exists with CreditCheckPolicy class
    - generation_policy_provider returns CreditCheckPolicy(ref)
    - free_beta_policy.dart deleted
    - No orphan imports
    - No analyzer warnings in template_engine feature
  </done>
</task>

<task type="auto">
  <name>Add creditBalanceNotifierProvider to logout invalidation</name>
  <files>lib/core/state/user_scoped_providers.dart</files>
  <action>
    1. Add import: `import 'package:artio/core/state/credit_balance_state_provider.dart';`

    2. Add to the cascade chain (after `createFormNotifierProvider`):
       `..invalidate(creditBalanceNotifierProvider)`

    Keep existing cascade style (..invalidate). Add comment: `// Prevent stale credits on re-login`

    DO NOT remove or reorder existing invalidations.
  </action>
  <verify>flutter analyze lib/core/state/user_scoped_providers.dart</verify>
  <done>
    - creditBalanceNotifierProvider added to invalidation cascade
    - Import added
    - No analyzer warnings
  </done>
</task>

<task type="auto">
  <name>Add error recovery to watchBalance() stream</name>
  <files>lib/features/credits/data/repositories/credit_repository.dart</files>
  <action>
    1. Add import: `import 'package:artio/core/config/sentry_config.dart';`

    2. Update `watchBalance()` method:
       - Change the `if (rows.isEmpty)` block from throwing `AppException` to
         returning a default CreditBalance:
         ```dart
         return CreditBalance(userId: '', balance: 0, updatedAt: DateTime.now());
         ```
         Note: CreditBalance requires userId, balance, updatedAt (all required).
         The row may not exist
         yet due to race condition between signup trigger and first stream event.
       - Chain `.handleError()` after `.map()`:
         ```dart
         .handleError(
           (Object error, StackTrace stackTrace) {
             SentryConfig.captureException(error, stackTrace: stackTrace);
           },
         )
         ```
         This logs errors to Sentry but doesn't kill the stream.

    DO NOT add rxdart dependency.
    DO NOT change the stream primaryKey or filter logic.
  </action>
  <verify>flutter analyze lib/features/credits/data/repositories/credit_repository.dart</verify>
  <done>
    - Empty rows return CreditBalance(balance: 0) instead of throwing
    - .handleError() logs to Sentry without killing stream
    - No analyzer warnings
  </done>
</task>

<task type="auto">
  <name>Write unit tests for credit fixes</name>
  <files>
    test/features/template_engine/data/policies/credit_check_policy_test.dart (NEW)
    test/features/credits/data/repositories/credit_repository_test.dart
  </files>
  <action>
    Create credit_check_policy_test.dart:
    - 'returns denied when balance < 4'
    - 'returns allowed when balance >= 4'
    - 'returns allowed with remainingCredits when balance is sufficient'
    - 'returns allowed when balance is null (not loaded)'

    Mock creditBalanceNotifierProvider using ProviderContainer overrides.

    Update credit_repository_test.dart (add test cases):
    - 'watchBalance returns CreditBalance(balance: 0) when rows empty'
    - 'watchBalance continues after handleError'

    Use `mocktail` for mocking.
  </action>
  <verify>
    flutter test test/features/template_engine/data/policies/credit_check_policy_test.dart
    flutter test test/features/credits/data/repositories/credit_repository_test.dart
  </verify>
  <done>
    - All 6+ test cases pass
    - CreditCheckPolicy logic verified for all edge cases
  </done>
</task>

## Success Criteria
- [ ] `flutter analyze` — 0 issues
- [ ] `FreeBetaPolicy` deleted, no orphan references
- [ ] CreditCheckPolicy blocks generation when balance < 4
- [ ] Credit balance stream doesn't throw on empty rows
- [ ] Logout invalidates credit providers
- [ ] All new tests pass
