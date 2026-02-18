---
phase: 4
plan: 4
wave: 3
---

# Plan 4.4: Ad Reward Tests

## Objective
Write tests for the ad reward feature: CreditRepository's new methods, AdRewardNotifier logic, and InsufficientCreditsSheet widget behavior. After this plan, the ad reward feature has regression-safe test coverage.

## Context
- `test/features/credits/` — Existing credit test files
- `lib/features/credits/data/repositories/credit_repository.dart` — rewardAdCredits(), fetchAdsRemainingToday()
- `lib/features/credits/presentation/providers/ad_reward_provider.dart` — AdRewardNotifier
- `lib/features/credits/presentation/widgets/insufficient_credits_sheet.dart` — Updated widget
- `lib/core/services/rewarded_ad_service.dart` — RewardedAdService (needs mock)
- `test/core/fixtures/` — Existing test fixture patterns

## Tasks

<task type="auto">
  <name>Test AdRewardNotifier and CreditRepository ad methods</name>
  <files>
    test/features/credits/presentation/providers/ad_reward_provider_test.dart (CREATE)
    test/features/credits/data/repositories/credit_repository_ad_test.dart (CREATE)
  </files>
  <action>
    1. Create `credit_repository_ad_test.dart`:
       - Mock `SupabaseClient`, `FunctionsClient`, `SupabaseQueryBuilder`
       - Test `rewardAdCredits()`:
         - Success case: Edge Function returns 200 with JSON → parsed record
         - 429 case: Daily limit → throws `AppException.validation`
         - Error case: Network failure → throws `AppException.network`
       - Test `fetchAdsRemainingToday()`:
         - No row (first ad today) → returns 10
         - Existing row with view_count = 3 → returns 7
         - Full row with view_count = 10 → returns 0

    2. Create `ad_reward_provider_test.dart`:
       - Mock `ICreditRepository` and `RewardedAdService` using mocktail
       - Test `watchAdAndReward()`:
         - Happy path: ad shown → user earned reward → server called → credits awarded
         - Ad not loaded: returns early/error without calling server
         - User dismissed ad early: doesn't call server
         - Server returns daily limit error: propagates error
         - Server returns network error: propagates error

    3. Run tests to verify all pass

    AVOID:
    - Do NOT test the actual Google Mobile Ads SDK — mock RewardedAdService entirely
    - Do NOT create integration tests (those need real Supabase) — unit tests only
    - Keep test files under 200 lines each
  </action>
  <verify>
    flutter test test/features/credits/ — all tests pass
    dart analyze test/features/credits/ — zero errors
  </verify>
  <done>
    - CreditRepository ad methods have unit tests (success + error cases)
    - AdRewardNotifier has unit tests (full flow + edge cases)
    - All tests pass
    - No flaky tests (proper async handling)
  </done>
</task>

<task type="checkpoint:human-verify">
  <name>Verify rewarded ad flow works on device/emulator</name>
  <files>None — manual verification</files>
  <action>
    1. Run the app on an emulator or device
    2. Log in as a user with low credits
    3. Try to generate with a model that costs more credits than available
    4. Verify InsufficientCreditsSheet appears
    5. Tap "Watch Ad" button
    6. Verify a test rewarded ad plays
    7. After completion, verify:
       - SnackBar shows "+5 credits"
       - Ads remaining count decremented
       - Credit balance updated
    8. Repeat until daily limit (10) — verify button disables

    NOTE: This requires the reward-ad Edge Function to be deployed to the Supabase project.
    If testing locally, the Edge Function can be run with `supabase functions serve reward-ad`.
  </action>
  <verify>Manual verification by user</verify>
  <done>
    - Rewarded ad plays successfully (test ad)
    - Credits awarded after ad completion
    - Daily limit enforced (button disabled after 10 ads)
    - Balance updates in real-time after reward
  </done>
</task>

## Success Criteria
- [ ] Unit tests for CreditRepository ad methods (3+ test cases)
- [ ] Unit tests for AdRewardNotifier (4+ test cases)
- [ ] All tests pass: `flutter test test/features/credits/`
- [ ] Manual verification on device/emulator (checkpoint)
