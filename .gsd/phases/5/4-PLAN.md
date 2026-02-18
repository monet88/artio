---
phase: 5
plan: 4
wave: 2
---

# Plan 5.4: Hide Ads for Subscribers, Settings Integration & Tests

## Objective
Complete the subscriber experience: hide ads for subscribers, show subscription status in settings, and write unit tests for the subscription module.

## Context
- `.gsd/SPEC.md` — Subscribers see no ads
- `lib/core/services/rewarded_ad_service.dart` — Ad loading service
- `lib/features/credits/presentation/providers/ad_reward_provider.dart` — Ad reward logic
- `lib/features/settings/presentation/settings_screen.dart` — Settings UI
- `lib/features/subscription/` — Subscription module from Plans 5.2-5.3
- `test/features/credits/` — Existing test patterns

## Tasks

<task type="auto">
  <name>Hide ads for subscribers and update settings</name>
  <files>
    lib/core/services/rewarded_ad_service.dart
    lib/features/credits/presentation/widgets/insufficient_credits_sheet.dart
    lib/features/settings/presentation/settings_screen.dart
  </files>
  <action>
    1. Update `RewardedAdService` provider:
       - The provider should check subscription status before loading ads
       - If user is a subscriber (`SubscriptionStatus.isActive`), don't load ads
       - Option A (simpler): Don't change service; instead hide ad UI in sheets when subscriber
       - Option B: Pass subscription status to provider, skip loadAd() — CHOOSE OPTION A
       - In `InsufficientCreditsSheet`: hide the "Watch Ad" button entirely for subscribers
       - Subscribers only see the tier comparison / current plan info
    
    2. Update `SettingsScreen`:
       - Add a "Subscription" section:
         - If subscriber: Show current tier (Pro/Ultra), renewal date, "Manage Subscription" button
         - "Manage Subscription" → Opens platform subscription management (App Store / Google Play)
           Use `Purchases.getManagementURL()` or platform-specific deep link
         - If free user: Show "Upgrade to Premium" button → navigates to PaywallScreen
       - Place the subscription section after user profile card, before theme toggle
    
    Important:
    - Don't break existing ad flow for free users
    - Keep settings screen manageable (extract subscription section to separate widget if needed)
    - Use `SubscriptionNotifier` state for reactive UI updates
  </action>
  <verify>flutter analyze — no errors</verify>
  <done>Ads hidden for subscribers, settings shows subscription status with manage/upgrade CTA</done>
</task>

<task type="auto">
  <name>Write unit tests for subscription module</name>
  <files>
    test/features/subscription/data/repositories/subscription_repository_test.dart
    test/features/subscription/presentation/providers/subscription_provider_test.dart
  </files>
  <action>
    1. Create `subscription_repository_test.dart`:
       - Mock `Purchases` static methods (or use a wrapper if needed for testability)
       - Test `getStatus()` maps CustomerInfo to SubscriptionStatus correctly:
         - Active 'pro' entitlement → isPro=true, isUltra=false
         - Active 'ultra' entitlement → isUltra=true
         - No active entitlements → isFree=true
       - Test `restore()` returns correct status
       - Test error handling (PlatformException → AppException)
    
    2. Create `subscription_provider_test.dart`:
       - Mock `ISubscriptionRepository`
       - Test initial build fetches status
       - Test `purchase()` updates state
       - Test `restore()` updates state
       - Test error states
    
    Important:
    - Use `mocktail` for mocking (project standard)
    - If `Purchases` static methods are hard to mock, the repository may need a thin wrapper
      around the static calls — adjust in repository if needed
    - Follow existing test patterns in `test/features/credits/`
    - Create `test/features/subscription/` directory structure mirroring `lib/`
  </action>
  <verify>flutter test test/features/subscription/ — all tests pass</verify>
  <done>Repository and provider tests pass, covering happy path and error cases</done>
</task>

## Success Criteria
- [ ] Subscribers don't see ad-related UI in InsufficientCreditsSheet
- [ ] Settings screen shows subscription tier and manage/upgrade options  
- [ ] Subscription repository tests cover all CustomerInfo → SubscriptionStatus mappings
- [ ] Subscription provider tests cover build, purchase, restore, and error states
- [ ] All existing tests still pass (`flutter test`)
