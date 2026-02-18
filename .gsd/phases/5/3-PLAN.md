---
phase: 5
plan: 3
wave: 2
---

# Plan 5.3: Paywall Screen & Subscription Comparison UI

## Objective
Build the paywall screen that shows subscription tier comparison (Free vs Pro vs Ultra), package prices from RevenueCat, and handles purchase/restore flows. Wire it into existing UI surfaces (PremiumModelSheet, InsufficientCreditsSheet).

## Context
- `.gsd/SPEC.md` — Pricing table, tier features
- `.gsd/phases/5/RESEARCH.md` — Product IDs, offering structure
- `lib/features/subscription/` — Subscription module from Plan 5.2
- `lib/features/credits/presentation/widgets/premium_model_sheet.dart` — Has `TODO(phase-5)`
- `lib/features/credits/presentation/widgets/insufficient_credits_sheet.dart` — Needs subscribe button
- `lib/routing/app_router.dart` — Route definitions

## Tasks

<task type="auto">
  <name>Create paywall screen with tier comparison</name>
  <files>
    lib/features/subscription/presentation/screens/paywall_screen.dart
    lib/features/subscription/presentation/widgets/tier_comparison_card.dart
  </files>
  <action>
    1. Create `TierComparisonCard` widget:
       - Displays a single subscription tier (Pro or Ultra)
       - Shows: tier name, monthly price, annual price (with savings %), monthly credits, features list
       - Highlighted state for "recommended" tier
       - Two CTA buttons: "Monthly" and "Annual" — each calls `onPurchase(package)`
       - Use existing design system (AppSpacing, AppColors, theme)
    
    2. Create `PaywallScreen` (ConsumerStatefulWidget):
       - Watches `subscriptionNotifierProvider` for current status
       - Fetches offerings via `ref.watch(offeringsProvider)` (create as simple FutureProvider)
       - Layout:
         - App bar with "Choose Your Plan" title and close button
         - Current plan indicator (if subscriber, show "Current: Pro/Ultra")
         - Tier comparison: Free tier summary + Pro card + Ultra card
         - Features table showing what each tier gets:
           | Feature | Free | Pro | Ultra |
           | Monthly Credits | Earn via ads | 200 | 500 |
           | Premium Models | ❌ | ✅ | ✅ |
           | Ads | ✅ | ❌ | ❌ |
           | Watermark | ✅ | ❌ | ❌ |
         - "Restore Purchases" text button at bottom
       - Handle loading/error states
       - On purchase success: show success snackbar, pop to previous screen
       - On purchase error: show error snackbar
       - On purchase cancelled by user: do nothing (don't show error)
    
    Important:
    - Get prices from RevenueCat Package objects, NOT hardcoded (stores may vary by region/currency)
    - The paywall should work even if offerings fail to load (show hardcoded prices as fallback)
    - Match existing app styling (dark theme compatible)
  </action>
  <verify>flutter analyze lib/features/subscription/presentation/ — no errors</verify>
  <done>Paywall screen renders tier comparison with real offering prices and handles purchase flow</done>
</task>

<task type="auto">
  <name>Wire paywall into existing UI and routing</name>
  <files>
    lib/features/credits/presentation/widgets/insufficient_credits_sheet.dart
    lib/features/credits/presentation/widgets/premium_model_sheet.dart
    lib/routing/app_router.dart
  </files>
  <action>
    1. Add `PaywallRoute` to app router:
       - Full-screen modal route (slide up transition)
       - Path: `/paywall`
       - No auth guard needed (only logged-in users reach this point)
    
    2. Update `PremiumModelSheet`:
       - Replace the `TODO(phase-5)` — "Upgrade to Premium" button navigates to PaywallScreen
       - Use `context.push(PaywallRoute().location)` or equivalent
    
    3. Update `InsufficientCreditsSheet`:
       - Add a new "Subscribe for more credits" `OutlinedButton` between the ad button and dismiss
       - Button navigates to PaywallScreen  
       - Only show if user is NOT already a subscriber (check subscription status)
    
    Important:
    - Do NOT change the ad watching flow — subscribe button is an additional option
    - For subscribers who run out of credits, only show "Subscribe" if they're on a lower tier (or hide it)
  </action>
  <verify>flutter analyze — no errors relating to modified files</verify>
  <done>PremiumModelSheet and InsufficientCreditsSheet navigate to paywall; route registered</done>
</task>

## Success Criteria
- [ ] PaywallScreen shows tier comparison with prices from RevenueCat offerings
- [ ] Purchase flow works: tap package → RevenueCat purchase → success feedback
- [ ] Restore purchases button works
- [ ] PremiumModelSheet "Upgrade to Premium" navigates to paywall
- [ ] InsufficientCreditsSheet shows "Subscribe" option alongside "Watch Ad"
- [ ] PaywallRoute registered in app router
