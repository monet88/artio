---
phase: 7
plan: 2
wave: 1
---

# Plan 7.2: Client-Side Architecture & Safety Fixes

## Objective
Fix the 3 P2 issues — domain layer SDK leakage, inconsistent subscription reads during async ops, and webhook constant-time auth comparison.

## Context
- `.gsd/ROADMAP.md` — Phase 7 task list
- `lib/features/subscription/domain/repositories/i_subscription_repository.dart`
- `lib/features/subscription/domain/entities/subscription_status.dart`
- `lib/features/subscription/data/repositories/subscription_repository.dart`
- `lib/features/subscription/presentation/providers/subscription_provider.dart`
- `lib/features/subscription/presentation/screens/paywall_screen.dart`
- `lib/features/gallery/presentation/pages/image_viewer_page.dart`
- `supabase/functions/revenuecat-webhook/index.ts`

## Tasks

<task type="auto">
  <name>Abstract Package SDK type from domain layer</name>
  <files>
    lib/features/subscription/domain/entities/subscription_package.dart (NEW)
    lib/features/subscription/domain/repositories/i_subscription_repository.dart
    lib/features/subscription/data/repositories/subscription_repository.dart
    lib/features/subscription/presentation/providers/subscription_provider.dart
    lib/features/subscription/presentation/screens/paywall_screen.dart
  </files>
  <action>
    1. Create `lib/features/subscription/domain/entities/subscription_package.dart`:
       ```dart
       import 'package:freezed_annotation/freezed_annotation.dart';
       part 'subscription_package.freezed.dart';

       @freezed
       class SubscriptionPackage with _$SubscriptionPackage {
         const factory SubscriptionPackage({
           required String identifier,
           required String priceString,
           required Object nativePackage,
         }) = _SubscriptionPackage;
       }
       ```
       `nativePackage` stores the original `Package` as `Object` so the data layer can cast it back.

    2. Update `i_subscription_repository.dart`:
       - Remove the `purchases_flutter` import and TODO comment
       - Replace `Package` with `SubscriptionPackage` in `getOfferings()` and `purchase()` signatures
       - Add import for `subscription_package.dart`

    3. Update `subscription_repository.dart`:
       - Keep the `purchases_flutter` import (data layer is allowed to depend on SDK)
       - In `getOfferings()`: map `Package` list to `SubscriptionPackage` list
       - In `purchase()`: cast `package.nativePackage as Package` to get the SDK type back

    4. Update `subscription_provider.dart`:
       - Replace `Package` import with `SubscriptionPackage` import
       - Update `purchase()` method parameter type

    5. Update `paywall_screen.dart`:
       - Replace `Package` import with `SubscriptionPackage`
       - Update `_selectedPackage` type to `SubscriptionPackage?`
       - Use `pkg.identifier` and `pkg.priceString` (already exposed by our domain type)

    6. Run `dart run build_runner build --delete-conflicting-outputs` to generate Freezed code

    - Do NOT change the tier comparison logic or UI layout
    - Do NOT add JSON serialization (not needed — this is only used in-memory)
    - Keep `nativePackage` as `Object` to avoid Freezed issues with SDK types
  </action>
  <verify>dart analyze lib/features/subscription/ 2>&1 | head -5</verify>
  <done>Domain layer has zero imports from `purchases_flutter`; data layer maps between SDK and domain types</done>
</task>

<task type="auto">
  <name>Capture _isFreeUser once per async operation</name>
  <files>lib/features/gallery/presentation/pages/image_viewer_page.dart</files>
  <action>
    In `_download()` and `_share()` methods, capture the subscription state once at the top
    instead of using the `_isFreeUser` getter repeatedly:

    ```dart
    Future<void> _download() async {
      final isFreeUser = _isFreeUser; // Capture once
      // ... use isFreeUser instead of _isFreeUser throughout
    }
    ```

    Same for `_share()`.

    - Do NOT remove the `_isFreeUser` getter (it's still useful for the build method)
    - Do NOT change any other logic in these methods
    - This is a 2-line change per method (add local variable + find/replace `_isFreeUser` → `isFreeUser`)
  </action>
  <verify>grep -n "final isFreeUser = _isFreeUser" lib/features/gallery/presentation/pages/image_viewer_page.dart</verify>
  <done>Both `_download` and `_share` capture `_isFreeUser` into a local variable at method start</done>
</task>

<task type="auto">
  <name>Use constant-time comparison for webhook auth</name>
  <files>supabase/functions/revenuecat-webhook/index.ts</files>
  <action>
    Replace the direct string comparison on line 36:
    ```typescript
    if (!authHeader || authHeader !== `Bearer ${REVENUECAT_WEBHOOK_SECRET}`) {
    ```
    With a timing-safe comparison using the Web Crypto API available in Deno:
    ```typescript
    const expectedAuth = `Bearer ${REVENUECAT_WEBHOOK_SECRET}`;
    const encoder = new TextEncoder();
    const authValid = authHeader !== null
        && authHeader.length === expectedAuth.length
        && crypto.subtle.timingSafeEqual
            ? await crypto.subtle.timingSafeEqual(encoder.encode(authHeader), encoder.encode(expectedAuth))
            : authHeader === expectedAuth;
    if (!authValid) {
    ```

    Note: Deno supports `crypto.subtle.timingSafeEqual` natively.
    The length check is needed because timingSafeEqual requires equal-length buffers.
    The fallback (`authHeader === expectedAuth`) handles environments where `timingSafeEqual` isn't available.

    - Do NOT change the error response format or status code
    - Do NOT modify any other part of the auth check
  </action>
  <verify>grep -n "timingSafeEqual" supabase/functions/revenuecat-webhook/index.ts</verify>
  <done>Webhook auth uses constant-time comparison; falls back to string comparison if unavailable</done>
</task>

## Success Criteria
- [ ] `i_subscription_repository.dart` has zero imports from `purchases_flutter`
- [ ] `_download()` and `_share()` each capture `_isFreeUser` into a local at method start
- [ ] Webhook auth uses timing-safe comparison
- [ ] `dart run build_runner build` succeeds (Freezed codegen for new entity)
- [ ] `dart analyze` clean
- [ ] All existing tests pass
