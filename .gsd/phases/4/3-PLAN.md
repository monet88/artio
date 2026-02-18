---
phase: 4
plan: 3
wave: 2
---

# Plan 4.3: Wire Ad Rewards into Credit UI

## Objective
Connect the RewardedAdService and reward-ad Edge Function to the existing credit UI. Update the InsufficientCreditsSheet "Watch Ad" button to actually show ads and award credits. Add an AdRewardNotifier that tracks today's ad count and manages the show-ad → call-server → update-balance flow. After this plan, users can earn 5 credits by watching a rewarded ad, up to 10 times per day.

## Context
- `.gsd/SPEC.md` — 5 credits/ad, max 10/day, "Watch Ad" in insufficient credits dialog
- `lib/core/services/rewarded_ad_service.dart` — RewardedAdService from Plan 4.1
- `lib/features/credits/presentation/widgets/insufficient_credits_sheet.dart` — Current "Watch ad for credits" button (no-op, just Navigator.pop)
- `lib/features/credits/domain/repositories/i_credit_repository.dart` — ICreditRepository interface
- `lib/features/credits/data/repositories/credit_repository.dart` — CreditRepository implementation
- `lib/features/credits/presentation/providers/credit_balance_provider.dart` — CreditBalanceNotifier
- `lib/core/providers/supabase_provider.dart` — Supabase client provider

## Tasks

<task type="auto">
  <name>Add ad reward methods to repository + create AdRewardNotifier</name>
  <files>
    lib/features/credits/domain/repositories/i_credit_repository.dart (MODIFY)
    lib/features/credits/data/repositories/credit_repository.dart (MODIFY)
    lib/features/credits/presentation/providers/ad_reward_provider.dart (CREATE)
    lib/features/credits/presentation/providers/ad_reward_provider.g.dart (GENERATED)
  </files>
  <action>
    1. Modify `ICreditRepository` — Add methods:
       ```dart
       /// Call the reward-ad Edge Function to award credits for watching an ad.
       /// Returns a record with (creditsAwarded, newBalance, adsRemaining).
       Future<({int creditsAwarded, int newBalance, int adsRemaining})> rewardAdCredits();

       /// Fetch today's remaining ad count from ad_views table.
       Future<int> fetchAdsRemainingToday();
       ```

    2. Modify `CreditRepository` — Implement the new methods:
       - `rewardAdCredits()`:
         - Call `_supabase.functions.invoke('reward-ad')` (POST, no body needed — JWT is auto-attached)
         - Parse response JSON
         - If status 429 → throw `AppException.validation(message: 'Daily ad limit reached')`
         - If error → throw appropriate `AppException`
         - Return the parsed record
       - `fetchAdsRemainingToday()`:
         - Query `ad_views` table for today: `_supabase.from('ad_views').select('view_count').eq('view_date', todayDate).maybeSingle()`
         - If no row → return 10 (all ads available)
         - Otherwise → return `10 - viewCount`

    3. Create `ad_reward_provider.dart`:
       - `@riverpod` class `AdRewardNotifier` extends `_$AdRewardNotifier`
       - State: `AsyncValue<int>` representing ads remaining today
       - `build()`: calls `repo.fetchAdsRemainingToday()` and returns the count
       - `watchAdAndReward(RewardedAdService adService)` method:
         - If `adService.isAdLoaded` is false, throw/return error
         - Show ad via `adService.showAd()`
         - If user didn't earn reward (dismissed early), return without awarding
         - Call `repo.rewardAdCredits()`
         - Invalidate self to refresh ads remaining count
         - Invalidate `creditBalanceNotifierProvider` to refresh balance display
         - Return the result (creditsAwarded, newBalance, adsRemaining)

    4. Run `dart run build_runner build --delete-conflicting-outputs`

    AVOID:
    - Do NOT call the Edge Function directly from the widget — use the provider
    - Do NOT skip the adService.showAd() step — credits should only be awarded after watching
    - Do NOT cache the ads remaining count aggressively — refresh after each ad watch
  </action>
  <verify>
    dart analyze lib/features/credits/ — zero errors
    test -f lib/features/credits/presentation/providers/ad_reward_provider.g.dart
  </verify>
  <done>
    - ICreditRepository has `rewardAdCredits()` and `fetchAdsRemainingToday()` methods
    - CreditRepository implements both using Edge Function + ad_views query
    - AdRewardNotifier manages the full show-ad → reward → refresh flow
    - Ads remaining count is available as async state
    - All generated code compiles
  </done>
</task>

<task type="auto">
  <name>Wire "Watch Ad" button in InsufficientCreditsSheet</name>
  <files>
    lib/features/credits/presentation/widgets/insufficient_credits_sheet.dart (MODIFY)
  </files>
  <action>
    1. Modify `InsufficientCreditsSheet`:
       - Convert from `StatelessWidget` to `ConsumerWidget` (needs ref for providers)
       - Watch `adRewardNotifierProvider` for ads remaining count
       - Watch `rewardedAdServiceProvider` for ad availability
       - Update the "Watch ad for credits" button:
         - Show ads remaining count: "Watch ad for +5 credits (X left today)"
         - Disable button if:
           - No ads remaining (daily limit reached)
           - Ad not loaded yet (show loading indicator)
           - Currently awarding credits (show progress indicator)
         - On press:
           - Call `ref.read(adRewardNotifierProvider.notifier).watchAdAndReward(adService)`
           - On success: show SnackBar "Earned 5 credits! Balance: X", then pop the sheet
           - On failure (daily limit): show SnackBar "Daily ad limit reached"
           - On failure (ad not ready): show SnackBar "Ad not ready, try again"
       - Add a small text below the button showing "X/10 ads watched today"

    AVOID:
    - Do NOT remove the "Dismiss" button — it should always be available
    - Do NOT auto-dismiss after ad reward — let the SnackBar show briefly, then pop
    - Do NOT add complex state management in the widget itself — delegate to AdRewardNotifier
    - Keep the widget under 120 lines
  </action>
  <verify>
    dart analyze lib/features/credits/presentation/widgets/insufficient_credits_sheet.dart — zero errors
    grep -q "adRewardNotifierProvider" lib/features/credits/presentation/widgets/insufficient_credits_sheet.dart
    grep -q "ConsumerWidget" lib/features/credits/presentation/widgets/insufficient_credits_sheet.dart
  </verify>
  <done>
    - "Watch Ad" button shows real rewarded ad when tapped
    - Button shows ads remaining count
    - Button disabled when daily limit reached or ad not loaded
    - Success awards 5 credits and shows confirmation
    - Daily limit (10 ads) enforced on both client and server side
    - Sheet dismisses after successful ad reward
    - All existing tests still pass
  </done>
</task>

## Success Criteria
- [ ] ICreditRepository has `rewardAdCredits()` and `fetchAdsRemainingToday()` methods
- [ ] CreditRepository calls the `reward-ad` Edge Function
- [ ] AdRewardNotifier orchestrates the ad-show → reward → refresh flow
- [ ] "Watch Ad" button works end-to-end: shows ad → calls server → awards credits
- [ ] Daily ad limit displayed to user (X/10)
- [ ] Button disabled at daily limit or when ad not loaded
- [ ] `dart analyze` passes with zero errors
- [ ] Code generation succeeds
