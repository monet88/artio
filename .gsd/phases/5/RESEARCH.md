# Phase 5 Research: RevenueCat Subscription Integration

## SDK & Version

- **Package**: `purchases_flutter: ^9.0.0` (already in pubspec.yaml)
- **Min Flutter**: 3.27.0+
- **Min iOS**: 11.0+, **Min Android SDK**: 21

## RevenueCat Core Concepts

| Concept | Description |
|---------|-------------|
| **Product** | SKU configured in App Store Connect / Google Play Console |
| **Entitlement** | Logical access level (e.g., "pro", "ultra") unlocked by products |
| **Offering** | Group of packages shown to users (current paywall) |
| **Package** | A product inside an offering (e.g., Monthly, Annual) |
| **CustomerInfo** | User's purchase state — active entitlements, subscriptions |

## Architecture Decision: Client SDK vs Webhooks

### Option A: Client-side only (SDK checks entitlements)
- RevenueCat SDK handles purchase, restore, entitlement checking
- App reads `CustomerInfo` to check active subscriptions
- **Problem**: Credits must be granted server-side (security)

### Option B: Client SDK + Server Webhook (CHOSEN)
- Client handles purchase UX via RevenueCat SDK
- RevenueCat webhook → Supabase Edge Function → grant credits + update profiles
- Client reads entitlement status from RevenueCat SDK for UI gating
- Server-side credit granting prevents manipulation

## Integration Points with Existing Codebase

### 1. UserModel (`lib/features/auth/domain/entities/user_model.dart`)
- Already has `isPremium` (bool) and `premiumExpiresAt` (DateTime?)
- Currently read from `profiles` table (`is_premium`, `premium_expires_at`)
- **Action**: Webhook updates `profiles.is_premium` and `profiles.premium_expires_at`

### 2. Profiles Table (`supabase/migrations/`)
- Already has `is_premium` and `premium_expires_at` columns? Need to check 
- **Action**: New migration to add these columns if missing, plus `subscription_tier` column

### 3. Credit System (`user_credits` / `credit_transactions`)
- Existing `deduct_credits()` and `refund_credits()` SQL functions
- `credit_transactions.type` already includes `'subscription'`
- **Action**: New `grant_subscription_credits()` SQL function

### 4. InsufficientCreditsSheet 
- Currently only shows "Watch Ad" option
- **Action**: Add "Subscribe" button that opens paywall

### 5. PremiumModelSheet
- Has `TODO(phase-5)` to navigate to subscription purchase screen
- **Action**: Wire up to RevenueCat paywall screen

### 6. AdMob (`rewarded_ad_service.dart`)
- **Action**: Don't load/show ads when user has active subscription

### 7. EnvConfig
- Already has `revenuecatAppleKey` and `revenuecatGoogleKey` getters
- **Action**: Add keys to `.env.*` files

## RevenueCat SDK Integration Pattern

```dart
// 1. Initialize (in main.dart)
await Purchases.configure(
  PurchasesConfiguration(Platform.isIOS 
    ? EnvConfig.revenuecatAppleKey 
    : EnvConfig.revenuecatGoogleKey)
  ..appUserID = supabaseUserId  // Link to Supabase user
);

// 2. Set app user ID on login
await Purchases.logIn(userId);

// 3. Get offerings (for paywall)
final offerings = await Purchases.getOfferings();
final current = offerings.current;

// 4. Purchase
final customerInfo = await Purchases.purchasePackage(package);

// 5. Check entitlement
final isEntitled = customerInfo.entitlements.active.containsKey('pro');

// 6. Listen for updates
Purchases.addCustomerInfoUpdateListener((info) => ...);

// 7. Restore purchases
final customerInfo = await Purchases.restorePurchases();

// 8. Logout
await Purchases.logOut();
```

## Webhook Edge Function Design

**Endpoint**: `supabase/functions/revenuecat-webhook/`

**Events to handle**:
| Event | Action |
|-------|--------|
| `INITIAL_PURCHASE` | Set `is_premium=true`, grant credits, record transaction |
| `RENEWAL` | Grant monthly credits, record transaction |
| `CANCELLATION` | Mark `premium_expires_at` (still active until expiry) |
| `EXPIRATION` | Set `is_premium=false` |
| `BILLING_ISSUE` | Log warning (grace period handled by stores) |
| `PRODUCT_CHANGE` | Update tier, adjust credits if upgrading |

**Security**:
- Verify webhook auth header (shared secret)
- Idempotent via `event_id` tracking in `credit_transactions.reference_id`
- Only service_role can modify `profiles.is_premium`

**Credit granting SQL function**:
```sql
CREATE OR REPLACE FUNCTION grant_subscription_credits(
  p_user_id UUID,
  p_amount INTEGER,
  p_description TEXT,
  p_reference_id TEXT
) RETURNS VOID AS $$
BEGIN
  UPDATE user_credits SET balance = balance + p_amount WHERE user_id = p_user_id;
  INSERT INTO credit_transactions (user_id, amount, type, description, reference_id)
  VALUES (p_user_id, p_amount, 'subscription', p_description, p_reference_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## Products Configuration (RevenueCat Dashboard)

| Product ID | Tier | Price | Credits |
|-----------|------|-------|---------|
| `artio_pro_monthly` | Pro | $9.99/mo | 200 |
| `artio_pro_annual` | Pro | $79.99/yr | 200/mo |
| `artio_ultra_monthly` | Ultra | $19.99/mo | 500 |
| `artio_ultra_annual` | Ultra | $149.99/yr | 500/mo |

**Entitlements**: `pro`, `ultra`
**Offering**: `default` with packages: Monthly Pro, Annual Pro, Monthly Ultra, Annual Ultra

## File Plan

### New Files
1. `lib/features/subscription/` — New feature module
   - `data/repositories/subscription_repository.dart`
   - `domain/entities/subscription_status.dart`
   - `domain/repositories/i_subscription_repository.dart`
   - `presentation/providers/subscription_provider.dart`
   - `presentation/screens/paywall_screen.dart`
   - `presentation/widgets/tier_comparison_card.dart`
2. `supabase/functions/revenuecat-webhook/index.ts`
3. `supabase/migrations/20260219000000_add_subscription_fields.sql`

### Modified Files
1. `lib/main.dart` — Initialize RevenueCat
2. `lib/features/auth/data/repositories/auth_repository.dart` — Link RC user on login
3. `lib/features/credits/presentation/widgets/insufficient_credits_sheet.dart` — Add subscribe button
4. `lib/features/credits/presentation/widgets/premium_model_sheet.dart` — Wire to paywall
5. `lib/core/services/rewarded_ad_service.dart` — Skip for subscribers
6. `lib/features/settings/presentation/settings_screen.dart` — Show subscription status
7. `lib/routing/app_router.dart` — Add paywall route
