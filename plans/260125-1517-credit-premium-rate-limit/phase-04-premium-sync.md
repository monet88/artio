# Phase 4: Premium Hybrid Sync

## Context

- Parent: [plan.md](./plan.md)
- Depends on: [Phase 2](./phase-02-credit-availability.md)

## Overview

| Field | Value |
|-------|-------|
| Priority | P1 - Critical |
| Status | Pending |
| Effort | 1.5h |

Implement hybrid premium sync: instant local override + Supabase Realtime for webhook consistency.

## Key Insights

- RevenueCat SDK already in dependencies (`purchases_flutter: ^9.0.0`)
- Webhook delay: 2-30s from purchase to DB update
- User expects instant unlock after payment
- Solution: local override + Realtime sync

## Requirements

### Functional
- On purchase success: immediately set `isPremiumOverride = true`
- Subscribe to `profiles` table changes via Realtime
- Update local state when webhook lands in DB
- Premium users bypass daily credit limit

### Non-Functional
- < 1s perceived latency for premium unlock
- Handle subscription expiry gracefully

## Architecture

```
Purchase Flow:
  RevenueCat.purchase() → Success Callback
                              ↓
              Local: isPremiumOverride = true (instant UI)
              Background: Webhook → Supabase → profiles.is_premium = true
                              ↓
              Realtime Subscription → Update UserModel
```

## Related Code Files

### Modify
- `lib/features/auth/repository/auth_repository.dart` - Add Realtime subscription
- `lib/features/auth/ui/view_model/auth_view_model.dart` - Handle profile updates
- `lib/features/auth/model/user_model.dart` - Add `isPremiumOverride` handling

### Create
- `lib/features/premium/repository/premium_repository.dart` - RevenueCat integration
- `lib/features/premium/ui/view_model/premium_view_model.dart` - Purchase state

## Implementation Steps

### 1. Add Realtime Subscription to AuthRepository

```dart
// lib/features/auth/repository/auth_repository.dart

StreamSubscription<List<Map<String, dynamic>>>? _profileSubscription;

Stream<Map<String, dynamic>> watchProfile(String userId) {
  return _supabase
      .from('profiles')
      .stream(primaryKey: ['id'])
      .eq('id', userId)
      .map((data) => data.isNotEmpty ? data.first : <String, dynamic>{});
}

void dispose() {
  _profileSubscription?.cancel();
}
```

### 2. Update AuthViewModel to Subscribe

```dart
// lib/features/auth/ui/view_model/auth_view_model.dart

StreamSubscription<Map<String, dynamic>>? _profileSubscription;
bool _isPremiumOverride = false;

bool get isPremiumEffective =>
    _isPremiumOverride || (currentUser?.isPremium ?? false);

void _subscribeToProfile(String userId) {
  _profileSubscription?.cancel();
  final authRepo = ref.read(authRepositoryProvider);
  _profileSubscription = authRepo.watchProfile(userId).listen((profile) {
    if (profile.isNotEmpty) {
      _updateUserFromProfile(profile);
    }
  });
}

void _updateUserFromProfile(Map<String, dynamic> profile) {
  final current = currentUser;
  if (current == null) return;

  final updated = current.copyWith(
    isPremium: profile['is_premium'] ?? false,
    premiumExpiresAt: profile['premium_expires_at'] != null
        ? DateTime.parse(profile['premium_expires_at'])
        : null,
  );

  state = AuthState.authenticated(updated);

  // Clear override once DB confirms
  if (updated.isPremium) {
    _isPremiumOverride = false;
  }
}

void setPremiumOverride(bool value) {
  _isPremiumOverride = value;
  // Trigger UI rebuild by notifying
  final current = currentUser;
  if (current != null) {
    state = AuthState.authenticated(current);
  }
}
```

### 3. Create PremiumRepository (RevenueCat)

```dart
// lib/features/premium/repository/premium_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'premium_repository.g.dart';

@riverpod
PremiumRepository premiumRepository(Ref ref) => PremiumRepository();

class PremiumRepository {
  Future<void> initialize(String userId) async {
    await Purchases.configure(
      PurchasesConfiguration('YOUR_REVENUECAT_API_KEY')
        ..appUserID = userId,
    );
  }

  Future<CustomerInfo> purchasePremium() async {
    final offerings = await Purchases.getOfferings();
    final package = offerings.current?.availablePackages.firstOrNull;
    if (package == null) throw Exception('No offerings available');

    final result = await Purchases.purchasePackage(package);
    return result;
  }

  Future<bool> checkPremiumStatus() async {
    final customerInfo = await Purchases.getCustomerInfo();
    return customerInfo.entitlements.active.containsKey('premium');
  }

  Stream<CustomerInfo> get customerInfoStream => Purchases.customerInfoStream;
}
```

### 4. Update CreditAvailabilityNotifier for Premium

```dart
// lib/features/template_engine/ui/view_model/credit_availability_notifier.dart

@riverpod
class CreditAvailabilityNotifier extends _$CreditAvailabilityNotifier {
  @override
  Future<int> build() async {
    final authVM = ref.watch(authViewModelProvider.notifier);
    if (authVM.isPremiumEffective) {
      return -1; // Unlimited
    }

    final repo = ref.read(generationRepositoryProvider);
    final usedToday = await repo.getDailyGenerationCount();
    return kDailyLimit - usedToday;
  }
  // ...
}
```

### 5. Update UI to Show Premium Status

```dart
// TemplateDetailScreen - premium users see "Unlimited"
creditAsync.when(
  data: (available) => Text(
    available < 0
        ? 'Unlimited (Premium)'
        : '$available generations remaining today',
  ),
  // ...
);
```

## Todo List

- [ ] Add `watchProfile()` to AuthRepository
- [ ] Add Realtime subscription in AuthViewModel
- [ ] Add `isPremiumOverride` and `setPremiumOverride()`
- [ ] Create PremiumRepository with RevenueCat
- [ ] Update CreditAvailabilityNotifier for premium check
- [ ] Update UI to show "Unlimited" for premium
- [ ] Run `dart run build_runner build`
- [ ] Test: Purchase → instant UI unlock
- [ ] Test: Realtime updates after webhook
- [ ] Test: Premium bypass credit limit

## Success Criteria

- [ ] Premium UI unlocks < 1s after purchase
- [ ] Realtime syncs DB state to client
- [ ] Premium users see "Unlimited"
- [ ] Credit limit bypassed for premium

## Risk Assessment

| Risk | Mitigation |
|------|------------|
| RevenueCat init fails | Graceful fallback, show error |
| Realtime disconnection | Re-subscribe on reconnect |
| Override persists after expiry | Check `premiumExpiresAt` |

## Security Considerations

- `isPremiumOverride` is local only, server still validates
- Never trust client `isPremium` for feature gating on server
- Webhook must be verified with RevenueCat signature

## Next Steps

→ Phase 5: Input Validation
