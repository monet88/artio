---
phase: 4
plan: 1
wave: 1
---

# Plan 4.1: Credits & Subscription Test Coverage

## Objective
Close critical test gaps in the two newest features. Both have low test ratios:
- **credits**: 9 source files, 3 test files (33% file coverage)
- **subscription**: 7 source files, 2 test files (29% file coverage)

Priority: repository tests and provider tests for untested files.

## Context
- lib/features/credits/ (9 source files)
- lib/features/subscription/ (7 source files)
- test/features/credits/ (3 existing tests)
- test/features/subscription/ (2 existing tests)

**Existing tests:**
- credits: `credit_repository_test.dart`, `credit_balance_provider_test.dart`, `ad_reward_provider_test.dart`
- subscription: `subscription_status_test.dart`, `paywall_screen_test.dart`

**Missing coverage candidates:**
- `credits/domain/entities/credit_balance.dart` (entity test)
- `credits/domain/entities/credit_transaction.dart` (entity test)
- `credits/presentation/widgets/insufficient_credits_sheet.dart` (widget test)
- `credits/presentation/widgets/premium_model_sheet.dart` (widget test)
- `subscription/data/repositories/subscription_repository.dart` (repository test)
- `subscription/presentation/providers/subscription_provider.dart` (provider test)

## Tasks

<task type="auto">
  <name>Write credits feature tests</name>
  <files>
    test/features/credits/domain/entities/credit_balance_test.dart (new)
    test/features/credits/domain/entities/credit_transaction_test.dart (new)
    test/features/credits/presentation/widgets/insufficient_credits_sheet_test.dart (new)
    test/features/credits/presentation/widgets/premium_model_sheet_test.dart (new)
  </files>
  <action>
    1. **Entity tests:** Test freezed constructors, equality, copyWith, JSON serialization
       for `CreditBalance` and `CreditTransaction` entities
    2. **Widget tests:** Test `InsufficientCreditsSheet` renders correctly, shows "Watch Ad" and
       "Subscribe" options, and calls correct callbacks when tapped.
       Test `PremiumModelSheet` renders correctly with model info, shows subscribe CTA.

    Use mocktail for mocking providers. Follow existing test patterns in `test/features/credits/`.

    - What to avoid: Do NOT test generated code (.g.dart / .freezed.dart logic).
      Focus on behavior, not implementation details.
  </action>
  <verify>flutter test test/features/credits/ --reporter expanded</verify>
  <done>4 new test files; all tests GREEN</done>
</task>

<task type="auto">
  <name>Write subscription feature tests</name>
  <files>
    test/features/subscription/data/repositories/subscription_repository_test.dart (new)
    test/features/subscription/presentation/providers/subscription_provider_test.dart (new)
  </files>
  <action>
    1. **Repository test:** Mock `Purchases` (RevenueCat SDK) using mocktail. Test:
       - `getStatus()` maps `CustomerInfo` to `SubscriptionStatus` correctly
       - `getOfferings()` returns parsed offerings
       - `purchase()` handles success and error
       - `restore()` handles restoration flow
    2. **Provider test:** Test the Riverpod provider initialization, state transitions
       on purchase/restore, and error handling.

    - What to avoid: Do NOT make real RevenueCat API calls. All SDK methods must be mocked.
      Follow the existing `paywall_screen_test.dart` mock patterns.
  </action>
  <verify>flutter test test/features/subscription/ --reporter expanded</verify>
  <done>2 new test files; all tests GREEN</done>
</task>

## Success Criteria
- [ ] Credits: 7+ test files (was 3)
- [ ] Subscription: 4+ test files (was 2)
- [ ] All new tests pass
- [ ] All existing tests still pass
- [ ] `flutter analyze` clean
