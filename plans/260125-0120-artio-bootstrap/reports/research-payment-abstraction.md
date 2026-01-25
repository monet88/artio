# Research: Payment Abstraction Layer

## Summary

Architecture for platform-agnostic payment handling using RevenueCat (mobile) and Stripe (web).

## Problem

- RevenueCat handles iOS/Android in-app purchases via App Store/Play Store
- Web payments cannot use native IAP - must use Stripe directly
- Need unified interface for app code

## Solution: Strategy Pattern

### Interface Definition

```dart
abstract class PaymentService {
  Future<void> initialize(String userId);
  Future<List<ProductModel>> getProducts();
  Future<SubscriptionModel?> getActiveSubscription();
  Future<bool> purchaseProduct(String productId);
  Future<bool> restorePurchases();
  Stream<SubscriptionModel?> get subscriptionStream;
}
```

### Implementations

| Platform | Implementation | Payment Method |
|----------|---------------|----------------|
| iOS | RevenueCatPaymentService | App Store IAP |
| Android | RevenueCatPaymentService | Play Store IAP |
| Web | StripePaymentService | Stripe Checkout |

### Provider

```dart
@riverpod
PaymentService paymentService(Ref ref) {
  if (kIsWeb) {
    return StripePaymentService();
  }
  return RevenueCatPaymentService();
}
```

## RevenueCat Details

### SDK Version
- `purchases_flutter: ^9.0.0` (includes web beta support)

### Configuration
```dart
await Purchases.configure(
  PurchasesConfiguration(apiKey)
    ..appUserID = userId
);
```

### Entitlements
- Check `customerInfo.entitlements.all['pro']`
- RevenueCat syncs across platforms automatically

### Web Support (Beta)
- Released May 2025
- Uses RevenueCat Web Billing
- Limitations: No attributes, no product operations, no restore

## Stripe Web Details

### Flow
1. Flutter calls Edge Function `create-checkout-session`
2. Edge Function creates Stripe Checkout session
3. Returns checkout URL
4. Flutter redirects to Stripe hosted checkout
5. Stripe redirects back on success/cancel
6. Webhook updates Supabase subscriptions table

### Edge Function
```typescript
const session = await stripe.checkout.sessions.create({
  customer: customerId,
  line_items: [{ price: priceId, quantity: 1 }],
  mode: 'subscription',
  success_url: successUrl,
  cancel_url: cancelUrl,
});
```

### Webhook Handler
- Listen to `checkout.session.completed`
- Listen to `customer.subscription.updated`
- Update Supabase subscriptions table

## Data Model

```dart
@freezed
class SubscriptionModel with _$SubscriptionModel {
  const factory SubscriptionModel({
    required SubscriptionTier tier,
    required SubscriptionStatus status,
    DateTime? expiresAt,
    String? productId,
    @Default(false) bool willRenew,
  }) = _SubscriptionModel;

  bool get isPro => tier == SubscriptionTier.pro &&
                    status == SubscriptionStatus.active;
}
```

## Supabase Schema

```sql
CREATE TABLE subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) UNIQUE,
  tier TEXT DEFAULT 'free',
  status TEXT DEFAULT 'none',
  stripe_customer_id TEXT,
  stripe_subscription_id TEXT,
  expires_at TIMESTAMPTZ,
  cancel_at_period_end BOOLEAN DEFAULT false
);
```

## References

- https://www.revenuecat.com/docs/getting-started/quickstart/flutter
- https://www.revenuecat.com/blog/engineering/flutter-sdk-web-support-beta/
- https://stripe.com/docs/payments/checkout
