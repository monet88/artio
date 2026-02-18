---
phase: pr-fixes
plan: 2
wave: 1
---

# Plan PR-Fixes.2: UX Logic & Cleanup Fixes

## Objective
Fix incorrect UX logic for subscribers with exhausted credits, add architectural TODO,
fix formatting artifacts, and guard against web platform crash.

- **M2**: InsufficientCreditsSheet shows "Get More Credits" (paywall) to subscribers who ran out — useless since they're already subscribed
- **M3**: RevenueCat `Package` type leaks into domain layer interface
- **N3**: Settings screen has inline formatting artifact (two lines where `[` and next statement are on same line)
- **N4**: `main.dart` uses `Platform.isIOS` without guarding against web platform

## Context
- `lib/features/credits/presentation/widgets/insufficient_credits_sheet.dart`
- `lib/features/subscription/domain/repositories/i_subscription_repository.dart`
- `lib/features/subscription/domain/entities/subscription_status.dart`
- `lib/features/settings/presentation/settings_screen.dart`
- `lib/main.dart`

## Tasks

<task type="auto">
  <name>Fix InsufficientCreditsSheet for subscribers with exhausted credits</name>
  <files>lib/features/credits/presentation/widgets/insufficient_credits_sheet.dart</files>
  <action>
    The current logic is inverted — `_isSubscriber` returns true for subscribers, then shows
    a "Get More Credits" button that navigates to the Paywall. But they're already subscribed,
    so the paywall is useless.

    Fix the logic:
    1. When `_isSubscriber(ref)` is true, show a renewal message + BOTH options:
       - Primary text: "Your monthly credits will refresh on {date}" (from subscription expiresAt)
       - Still show the ad button (subscribers CAN watch ads for extra credits if needed)
       - Add a secondary "Manage Subscription" link to PaywallRoute

    2. When NOT a subscriber (free user), show:
       - The ad button (existing behavior)
       - An "Upgrade to Premium" link to PaywallRoute (new — gives free users a path to subscribe)

    The key insight: subscribers who exhausted credits should see their renewal date and
    still have the ad option. Free users should see both ads and upgrade option.

    Implementation:
    ```dart
    // For subscribers:
    if (_isSubscriber(ref)) ...[
      // Show renewal info
      _buildRenewalInfo(ref, theme),
      const SizedBox(height: AppSpacing.sm),
      // Still allow watching ads
      _buildAdButton(adsRemainingAsync, adService),
      const SizedBox(height: AppSpacing.sm),
      // Manage subscription link
      _buildManageSubscriptionButton(),
    ] else ...[
      // Free user: ad button + upgrade link
      _buildAdButton(adsRemainingAsync, adService),
      const SizedBox(height: AppSpacing.sm),
      _buildUpgradeButton(),
    ],
    ```

    Add helper methods:
    - `_buildRenewalInfo(WidgetRef ref, ThemeData theme)` — reads expiresAt from subscription status, displays "Credits refresh on {date}"
    - `_buildManageSubscriptionButton()` — OutlinedButton navigating to PaywallRoute
    - `_buildUpgradeButton()` — OutlinedButton with star icon, navigating to PaywallRoute

    Remove the old `_buildSubscribeButton()` method.
  </action>
  <verify>
    ```bash
    cd /Users/gold/workspace/artio && dart analyze lib/features/credits/presentation/widgets/insufficient_credits_sheet.dart
    ```
  </verify>
  <done>
    - Subscribers see renewal date + ad option + manage subscription
    - Free users see ad button + upgrade option
    - No analyzer warnings
  </done>
</task>

<task type="auto">
  <name>Add TODO, fix formatting, guard Platform access</name>
  <files>
    lib/features/subscription/domain/repositories/i_subscription_repository.dart
    lib/features/settings/presentation/settings_screen.dart
    lib/main.dart
  </files>
  <action>
    **M3 — Domain layer TODO:**
    In `i_subscription_repository.dart`, add a TODO comment above the `purchases_flutter` import:
    ```dart
    // TODO(arch): Abstract Package type to a domain entity to decouple from RevenueCat SDK.
    ```
    This is a pragmatic acknowledgment — no code change needed now.

    **N3 — Settings screen formatting:**
    In `settings_screen.dart`, fix the two lines where `[` and the next statement are on the same line:
    - Line 208: `if (creditBalance != null) ...[                        const SizedBox(height: 4),`
      → Split into two lines
    - Line 260: `if (creditBalance != null) ...[                const SizedBox(height: AppSpacing.xs),`
      → Split into two lines

    **N4 — Guard Platform.isIOS in main.dart:**
    In `main.dart`, wrap the `Platform.isIOS` check with `kIsWeb`:
    ```dart
    // Initialize RevenueCat SDK (skip if keys not configured or running on web)
    if (!kIsWeb) {
      final rcKey = Platform.isIOS
          ? EnvConfig.revenuecatAppleKey
          : EnvConfig.revenuecatGoogleKey;
      if (rcKey.isNotEmpty) {
        await Purchases.configure(PurchasesConfiguration(rcKey));
      }
    }
    ```
    Note: `kIsWeb` is already imported from `package:flutter/foundation.dart`.
  </action>
  <verify>
    ```bash
    cd /Users/gold/workspace/artio && dart analyze lib/features/subscription/domain/repositories/i_subscription_repository.dart lib/features/settings/presentation/settings_screen.dart lib/main.dart
    ```
  </verify>
  <done>
    - TODO comment added to domain interface acknowledging RevenueCat coupling
    - Settings screen formatting artifacts fixed (each statement on its own line)
    - `Platform.isIOS` guarded with `kIsWeb` check to prevent web crash
    - No analyzer warnings on any modified file
  </done>
</task>

## Success Criteria
- [ ] Subscribers with exhausted credits see renewal date and ad option (not a useless paywall)
- [ ] Free users see both ad button and upgrade option
- [ ] `i_subscription_repository.dart` has TODO comment about abstracting Package type
- [ ] Settings screen formatting is clean (no inline list artifacts)
- [ ] `main.dart` won't crash on web due to `Platform.isIOS` access
- [ ] `dart analyze` clean on all modified files
