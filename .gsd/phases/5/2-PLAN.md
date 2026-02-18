---
phase: 5
plan: 2
wave: 1
---

# Plan 5.2: RevenueCat SDK Initialization & Subscription Service

## Objective
Initialize the RevenueCat SDK in the app, create the subscription feature module (data/domain/presentation layers), and wire up login/logout with RevenueCat user identity.

## Context
- `.gsd/SPEC.md` — Subscription tiers, pricing
- `.gsd/phases/5/RESEARCH.md` — SDK initialization pattern, entitlement concepts
- `lib/core/config/env_config.dart` — Already has `revenuecatAppleKey`/`revenuecatGoogleKey` getters
- `lib/features/auth/data/repositories/auth_repository.dart` — Login/logout flow
- `lib/features/credits/` — Existing credit feature module pattern to follow
- `lib/main.dart` — App initialization

## Tasks

<task type="auto">
  <name>Create subscription feature module (domain + data + providers)</name>
  <files>
    lib/features/subscription/domain/entities/subscription_status.dart
    lib/features/subscription/domain/repositories/i_subscription_repository.dart
    lib/features/subscription/data/repositories/subscription_repository.dart
    lib/features/subscription/presentation/providers/subscription_provider.dart
  </files>
  <action>
    1. Create `SubscriptionStatus` freezed entity:
       - `tier` (String? — 'pro', 'ultra', or null for free)
       - `isActive` (bool)
       - `expiresAt` (DateTime?)
       - `willRenew` (bool)
       - Convenience getters: `isPro`, `isUltra`, `isFree`, `monthlyCredits`
    
    2. Create `ISubscriptionRepository` abstract class:
       - `Future<SubscriptionStatus> getStatus()` — current subscription status
       - `Future<List<Package>> getOfferings()` — available packages for paywall
       - `Future<SubscriptionStatus> purchase(Package package)` — purchase a package
       - `Future<SubscriptionStatus> restore()` — restore purchases
    
    3. Create `SubscriptionRepository` implementing the interface:
       - `getStatus()` → `Purchases.getCustomerInfo()` → map `CustomerInfo.entitlements.active` to `SubscriptionStatus`
       - `getOfferings()` → `Purchases.getOfferings()` → return `offerings.current?.availablePackages ?? []`
       - `purchase(package)` → `Purchases.purchasePackage(package)` → return mapped status
       - `restore()` → `Purchases.restorePurchases()` → return mapped status
       - Private helper `_mapCustomerInfo(CustomerInfo) → SubscriptionStatus`:
         Check `active.containsKey('ultra')` → ultra tier
         Check `active.containsKey('pro')` → pro tier
         Otherwise → free
       - Wrap all calls in try/catch, map `PlatformException` to `AppException`
    
    4. Create `subscriptionProvider` (Riverpod `@riverpod`):
       - `SubscriptionNotifier extends _$SubscriptionNotifier`
       - `AsyncNotifier<SubscriptionStatus>` that:
         - `build()` → fetches initial status via `getStatus()`
         - `purchase(Package)` → calls repo, updates state
         - `restore()` → calls repo, updates state
       - Also create `subscriptionRepositoryProvider` 
    
    Important:
    - Follow the exact same pattern as `CreditRepository` / `CreditBalanceNotifier`
    - Import `package:purchases_flutter/purchases_flutter.dart`
    - The `Package` type comes from `purchases_flutter`
    - Add `part '*.g.dart'` for all providers
  </action>
  <verify>flutter analyze lib/features/subscription/ — no errors (allow info)</verify>
  <done>Subscription feature module compiles with domain entities, repository, and provider</done>
</task>

<task type="auto">
  <name>Initialize RevenueCat SDK and link auth flow</name>
  <files>
    lib/main.dart
    lib/features/auth/data/repositories/auth_repository.dart
  </files>
  <action>
    1. In `main.dart` after Supabase init:
       - Add RevenueCat configuration:
         ```dart
         await Purchases.configure(
           PurchasesConfiguration(
             Platform.isIOS 
               ? EnvConfig.revenuecatAppleKey 
               : EnvConfig.revenuecatGoogleKey,
           ),
         );
         ```
       - Only configure if key is non-empty (graceful skip in development without keys)
       - Import `dart:io` for `Platform.isIOS`
    
    2. In `AuthRepository` (or wherever login is handled):
       - After successful login: `await Purchases.logIn(user.id)` — links RC user to Supabase user ID
       - After logout: `await Purchases.logOut()` — clears RC user
       - Wrap in try/catch — RC errors should not block auth flow (log and continue)
    
    Important:
    - Do NOT set `appUserID` in `PurchasesConfiguration` at init time (user may not be logged in yet)
    - Call `Purchases.logIn()` only after successful Supabase auth
    - Guard RC calls with a check that the key is non-empty
  </action>
  <verify>
    flutter analyze lib/main.dart lib/features/auth/ — no errors
  </verify>
  <done>RevenueCat initializes at startup, links/unlinks user on login/logout</done>
</task>

<task type="auto">
  <name>Run codegen and ensure compilation</name>
  <files>lib/features/subscription/**/*.dart</files>
  <action>
    Run `dart run build_runner build --delete-conflicting-outputs` to generate:
    - `.freezed.dart` for SubscriptionStatus
    - `.g.dart` for all `@riverpod` providers
    
    Verify the full app compiles with `flutter analyze`.
  </action>
  <verify>
    dart run build_runner build --delete-conflicting-outputs && flutter analyze — 0 errors
  </verify>
  <done>All generated code is up to date, no analysis errors</done>
</task>

## Success Criteria
- [ ] `SubscriptionStatus` entity with `isPro`, `isUltra`, `isFree` getters
- [ ] `SubscriptionRepository` wraps RevenueCat SDK for status, offerings, purchase, restore
- [ ] `SubscriptionNotifier` manages subscription state reactively
- [ ] RevenueCat SDK configured in `main.dart` with platform-specific keys
- [ ] Login calls `Purchases.logIn(userId)`, logout calls `Purchases.logOut()`
- [ ] `flutter analyze` passes with 0 errors
