---
phase: reward-ad-ssv
plan: 3
wave: 2
---

# Plan 3: Flutter Client — 2-Step Ad Reward Flow + SSV Options

## Objective
Update the Flutter client to use the new 2-step nonce flow (request nonce → show ad → claim reward) and set `ServerSideVerificationOptions` for future AdMob SSV support.

## Context
- .gsd/phases/reward-ad-ssv/RESEARCH.md (Option B client flow)
- lib/core/services/rewarded_ad_service.dart (ad loading + showing)
- lib/features/credits/presentation/providers/ad_reward_provider.dart (orchestrates ad-watch → reward)
- lib/features/credits/data/repositories/credit_repository.dart (calls Edge Function)
- lib/features/credits/domain/repositories/i_credit_repository.dart (interface)

## Tasks

<task type="auto">
  <name>Add nonce methods to repository layer</name>
  <files>
    lib/features/credits/domain/repositories/i_credit_repository.dart
    lib/features/credits/data/repositories/credit_repository.dart
  </files>
  <action>
    1. **Interface `ICreditRepository`** — add method:
       ```dart
       /// Request a one-time nonce for ad reward claim.
       Future<String> requestAdNonce();
       ```

    2. **`CreditRepository`** — implement `requestAdNonce()`:
       ```dart
       @override
       Future<String> requestAdNonce() async {
         try {
           final response = await _supabase.functions.invoke(
             'reward-ad',
             queryParameters: {'action': 'request-nonce'},
           );
           // Parse response same pattern as rewardAdCredits
           // Handle 429 (daily limit reached)
           // Return nonce string from response data
         } catch ...
       }
       ```

    3. **`CreditRepository.rewardAdCredits()`** — update to accept nonce parameter:
       - Change signature to `rewardAdCredits({required String nonce})`
       - Update Edge Function call to include `queryParameters: {'action': 'claim'}` and body `{'nonce': nonce}`
       - Update interface accordingly

    **DO NOT** change `fetchAdsRemainingToday()` or `fetchBalance()` — those are unchanged.
  </action>
  <verify>Run: flutter analyze --no-pub</verify>
  <done>
    - ICreditRepository has `requestAdNonce()` method
    - CreditRepository implements nonce request via Edge Function
    - rewardAdCredits now requires a nonce parameter
    - flutter analyze passes
  </done>
</task>

<task type="auto">
  <name>Update AdRewardNotifier + RewardedAdService for 2-step flow</name>
  <files>
    lib/features/credits/presentation/providers/ad_reward_provider.dart
    lib/core/services/rewarded_ad_service.dart
  </files>
  <action>
    1. **`RewardedAdService`** — add `setServerSideVerification` method:
       ```dart
       /// Configure SSV options on the loaded ad.
       /// Call AFTER ad is loaded and BEFORE showing.
       void setServerSideVerification({
         required String userId,
         required String customData,
       }) {
         _rewardedAd?.serverSideVerificationOptions =
           ServerSideVerificationOptions(
             userId: userId,
             customData: customData,
           );
       }
       ```
       - Import `ServerSideVerificationOptions` from `google_mobile_ads`

    2. **`AdRewardNotifier.watchAdAndReward()`** — update to 2-step flow:
       ```dart
       Future<({int creditsAwarded, int newBalance, int adsRemaining})>
           watchAdAndReward() async {
         final adService = ref.read(rewardedAdServiceProvider);
         final repo = ref.read(creditRepositoryProvider);

         if (!adService.isAdLoaded) {
           throw const AppException.network(
             message: 'No ad loaded. Please wait and try again.',
           );
         }

         // Step 1: Request nonce from server BEFORE showing ad
         final nonce = await repo.requestAdNonce();

         // Step 2: Set SSV options with nonce as custom_data
         final user = ref.read(supabaseClientProvider).auth.currentUser;
         if (user != null) {
           adService.setServerSideVerification(
             userId: user.id,
             customData: nonce,
           );
         }

         // Step 3: Show the ad
         final earned = await adService.showAd();
         if (!earned) {
           throw const AppException.network(
             message: 'Ad was dismissed before earning reward.',
           );
         }

         // Step 4: Claim reward with nonce
         final result = await repo.rewardAdCredits(nonce: nonce);

         // Refresh UI state
         ref
           ..invalidateSelf()
           ..invalidate(creditBalanceNotifierProvider);

         return result;
       }
       ```

       - Add necessary imports: `supabaseClientProvider`
       - The key security improvement: nonce is requested BEFORE ad shown, claimed AFTER — server controls the flow

    **DO NOT** change the `build()` method or `_isRewarding` state management in `insufficient_credits_sheet.dart` — those are independent.
  </action>
  <verify>Run: flutter analyze --no-pub</verify>
  <done>
    - RewardedAdService has setServerSideVerification method
    - AdRewardNotifier uses 2-step flow: requestNonce → showAd → claimReward
    - ServerSideVerificationOptions set with userId + nonce
    - flutter analyze passes
  </done>
</task>

<task type="auto">
  <name>Run build_runner and verify tests</name>
  <files>
    lib/features/credits/data/repositories/credit_repository.g.dart
    lib/features/credits/presentation/providers/ad_reward_provider.g.dart
  </files>
  <action>
    1. Run `dart run build_runner build --delete-conflicting-outputs` to regenerate .g.dart files
    2. Run `flutter test` to check for test failures
    3. If tests fail due to mock changes (new `requestAdNonce` method), update the mocks:
       - Find test files that mock `ICreditRepository` and add the new method stub
       - Run `dart run build_runner build` again if using mockito codegen
    4. Fix any resulting compilation errors

    **Expected:** Some tests may need mock updates for the new `requestAdNonce()` method and the changed `rewardAdCredits(nonce:)` signature. Fix these.
  </action>
  <verify>Run: flutter test</verify>
  <done>
    - build_runner completes without errors
    - All existing tests pass (with mock updates as needed)
    - No analyzer warnings related to changed files
  </done>
</task>

## Success Criteria
- [ ] Client uses 2-step flow: request nonce → show ad with SSV → claim with nonce
- [ ] ServerSideVerificationOptions set on RewardedAd before showing
- [ ] flutter analyze passes with 0 errors
- [ ] flutter test passes
- [ ] Nonce is requested server-side, not generated client-side
