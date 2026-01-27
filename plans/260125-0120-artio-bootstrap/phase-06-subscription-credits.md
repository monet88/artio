---
title: "Phase 6: Subscription & Credits"
status: pending
effort: 8h
---

# Phase 6: Subscription & Credits

## Context Links

- [RevenueCat Flutter SDK](https://www.revenuecat.com/docs/getting-started/quickstart/flutter)
- [RevenueCat Web Support (Beta)](https://www.revenuecat.com/blog/engineering/flutter-sdk-web-support-beta/)
- [Stripe Flutter Web](https://stripe.com/docs/payments/quickstart)
- [Google Mobile Ads - Rewarded](https://developers.google.com/admob/flutter/rewarded)

## Overview

**Priority**: P1 (High)
**Status**: pending
**Effort**: 8h

Implement hybrid monetization with subscription plans, credits system, rewarded ads (mobile), and a payment abstraction layer for platform-specific implementations.

## Key Insights

- **RevenueCat SDK v9.0.0** supports Flutter Web (beta) with limitations
- Use **Payment Abstraction Interface** - RevenueCat for mobile, Stripe for web
- Rewarded ads only on mobile (google_mobile_ads doesn't support web)
- `kIsWeb` check for platform-specific logic
- Credits stored in Supabase profiles table

## Requirements

### Functional
- Subscription tiers: Basic ($6.99/mo, 100 credits), Pro ($9.99/mo, 200 credits)
- Credits system (1K=1 credit, 2K=2 credits, 4K=4 credits)
- Credit packs: $1.99/50, $3.99/100, $6.99/200
- Rewarded ads → earn credits (mobile only, 1 credit/ad, max 5/day)
- Signup bonus (web): 10 credits
- Purchase subscription via RevenueCat (mobile) / Stripe (web)
- Check entitlements before generation
- Display current credits and subscription status
- Credits kept until period end on cancellation
- No rollover for monthly credits
- Earned credits expire in 30 days, purchased never expire

### Non-Functional
- Offline entitlement caching
- Graceful handling of payment failures
- Receipt validation server-side

## Architecture

### Payment Abstraction Pattern
```
PaymentService (interface)
├── RevenueCatPaymentService (iOS/Android)
└── StripePaymentService (Web)

PaymentServiceProvider
└── Returns correct implementation based on platform
```

### Business Logic
```
Subscription Tiers:
┌─────────────┬──────────────────┬────────────────┬──────────────────────┐
│ Tier        │ Credits/Month    │ Price          │ Benefits             │
├─────────────┼──────────────────┼────────────────┼──────────────────────┤
│ Free        │ 0 (bonus only)   │ Free           │ Basic access         │
│ Basic       │ 100              │ $6.99/month    │ Priority + 2K max    │
│ Pro         │ 200              │ $9.99/mo       │ All + 4K resolution  │
└─────────────┴──────────────────┴────────────────┴──────────────────────┘

Credit Pricing (output quality):
- 1K (1024x1024): 1 credit
- 2K (2048x2048): 2 credits
- 4K (4096x4096): 4 credits

Credit Packs (purchase):
- Small: $1.99 / 50 credits
- Medium: $3.99 / 100 credits
- Large: $6.99 / 200 credits

Credit Expiry:
- Subscription monthly: End of period (no rollover)
- Purchased: Never expire
- Earned (ads): 30 days
- Signup bonus (web): Never expire

Credit Earning (Free Users):
- Mobile: Watch rewarded ad → +1 credit (max 5/day)
- Web: Signup bonus only (10 credits)
```

### Feature Structure
```
lib/features/subscription/
├── domain/
│   ├── entities/
│   │   ├── subscription.dart
│   │   ├── product.dart
│   │   └── credit_pack.dart
│   └── repositories/
│       └── i_subscription_repository.dart
├── data/
│   ├── data_sources/
│   │   ├── payment_remote_data_source.dart
│   │   └── credits_remote_data_source.dart
│   ├── dtos/
│   │   └── subscription_dto.dart
│   ├── services/
│   │   ├── payment_service.dart (interface)
│   │   ├── revenuecat_payment_service.dart
│   │   └── stripe_payment_service.dart
│   └── repositories/
│       └── subscription_repository_impl.dart
└── presentation/
    ├── providers/
    │   ├── subscription_provider.dart
    │   └── credits_provider.dart
    ├── pages/
    │   └── subscription_page.dart
    └── widgets/
        ├── subscription_card.dart
        ├── credit_pack_card.dart
        ├── credits_display.dart
        └── rewarded_ad_button.dart
```

## Related Code Files

### Files to Create
- `lib/features/subscription/data/models/subscription_model.dart`
- `lib/features/subscription/data/models/product_model.dart`
- `lib/features/subscription/data/services/payment_service.dart`
- `lib/features/subscription/data/services/revenuecat_payment_service.dart`
- `lib/features/subscription/data/services/stripe_payment_service.dart`
- `lib/features/subscription/data/repositories/subscription_repository.dart`
- `lib/features/subscription/domain/subscription_notifier.dart`
- `lib/features/subscription/domain/credits_notifier.dart`
- `lib/features/subscription/presentation/pages/subscription_page.dart`
- `lib/features/subscription/presentation/widgets/rewarded_ad_button.dart`

### Files to Modify
- `lib/main.dart` - Initialize RevenueCat/AdMob SDK
- `lib/core/router/app_router.dart` - Add subscription routes
- `pubspec.yaml` - Add dependencies (purchases_flutter, google_mobile_ads, stripe_flutter)

### Files to Delete
- None

### Database Schema
```sql
-- Subscriptions table (for web/Stripe)
CREATE TABLE subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
  tier TEXT NOT NULL DEFAULT 'free',
  status TEXT NOT NULL DEFAULT 'none',
  stripe_customer_id TEXT,
  stripe_subscription_id TEXT,
  stripe_price_id TEXT,
  expires_at TIMESTAMPTZ,
  cancel_at_period_end BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- RLS
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own subscription" ON subscriptions FOR SELECT USING (auth.uid() = user_id);

-- Profiles table update (add credits column)
ALTER TABLE profiles ADD COLUMN credits INTEGER DEFAULT 0;

-- Credit functions
CREATE OR REPLACE FUNCTION add_credits(user_id UUID, amount INTEGER)
RETURNS void AS $$
BEGIN
  UPDATE profiles SET credits = credits + amount WHERE id = user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION deduct_credits(user_id UUID, amount INTEGER)
RETURNS void AS $$
BEGIN
  UPDATE profiles SET credits = GREATEST(0, credits - amount) WHERE id = user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE subscriptions;
```

## Implementation Steps

### 1. Payment Service Interface
```dart
// lib/features/subscription/data/services/payment_service.dart
import '../models/product_model.dart';
import '../models/subscription_model.dart';

abstract class PaymentService {
  Future<void> initialize(String userId);
  Future<List<ProductModel>> getProducts();
  Future<SubscriptionModel?> getActiveSubscription();
  Future<bool> purchaseProduct(String productId);
  Future<bool> restorePurchases();
  Stream<SubscriptionModel?> get subscriptionStream;
}
```

### 2. Subscription Model
```dart
// lib/features/subscription/data/models/subscription_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_model.freezed.dart';
part 'subscription_model.g.dart';

enum SubscriptionTier { free, basic, pro }
enum SubscriptionStatus { active, expired, cancelled, none }

@freezed
class SubscriptionModel with _$SubscriptionModel {
  const factory SubscriptionModel({
    required SubscriptionTier tier,
    required SubscriptionStatus status,
    DateTime? expiresAt,
    String? productId,
    @Default(false) bool willRenew,
  }) = _SubscriptionModel;

  const SubscriptionModel._();

  bool get isActive => (tier == SubscriptionTier.basic || tier == SubscriptionTier.pro) && status == SubscriptionStatus.active;
  bool get isPro => tier == SubscriptionTier.pro && isActive;
  bool get isBasic => tier == SubscriptionTier.basic && isActive;

  factory SubscriptionModel.free() => const SubscriptionModel(
    tier: SubscriptionTier.free,
    status: SubscriptionStatus.none,
  );

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionModelFromJson(json);
}
```

### 3. RevenueCat Implementation
```dart
// lib/features/subscription/data/services/revenuecat_payment_service.dart
import 'dart:async';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show Platform;
import 'payment_service.dart';
import '../models/product_model.dart';
import '../models/subscription_model.dart';

class RevenueCatPaymentService implements PaymentService {
  final _subscriptionController = StreamController<SubscriptionModel?>.broadcast();

  @override
  Future<void> initialize(String userId) async {
    final apiKey = Platform.isIOS
        ? dotenv.env['REVENUECAT_APPLE_KEY']!
        : dotenv.env['REVENUECAT_GOOGLE_KEY']!;

    await Purchases.configure(PurchasesConfiguration(apiKey)..appUserID = userId);

    // Listen to customer info changes
    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      _subscriptionController.add(_mapCustomerInfo(customerInfo));
    });
  }

  @override
  Future<List<ProductModel>> getProducts() async {
    final offerings = await Purchases.getOfferings();
    final current = offerings.current;

    if (current == null) return [];

    return current.availablePackages.map((package) {
      return ProductModel(
        id: package.storeProduct.identifier,
        title: package.storeProduct.title,
        description: package.storeProduct.description,
        price: package.storeProduct.priceString,
        priceAmount: package.storeProduct.price,
        currencyCode: package.storeProduct.currencyCode,
        packageType: package.packageType.name,
      );
    }).toList();
  }

  @override
  Future<SubscriptionModel?> getActiveSubscription() async {
    final customerInfo = await Purchases.getCustomerInfo();
    return _mapCustomerInfo(customerInfo);
  }

  @override
  Future<bool> purchaseProduct(String productId) async {
    try {
      final offerings = await Purchases.getOfferings();
      final package = offerings.current?.availablePackages
          .firstWhere((p) => p.storeProduct.identifier == productId);

      if (package == null) return false;

      await Purchases.purchasePackage(package);
      return true;
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) {
        return false;
      }
      rethrow;
    }
  }

  @override
  Future<bool> restorePurchases() async {
    try {
      await Purchases.restorePurchases();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Stream<SubscriptionModel?> get subscriptionStream => _subscriptionController.stream;

  SubscriptionModel? _mapCustomerInfo(CustomerInfo info) {
    final entitlement = info.entitlements.all['pro'];

    if (entitlement == null || !entitlement.isActive) {
      return SubscriptionModel.free();
    }

    return SubscriptionModel(
      tier: SubscriptionTier.pro,
      status: SubscriptionStatus.active,
      expiresAt: entitlement.expirationDate != null
          ? DateTime.parse(entitlement.expirationDate!)
          : null,
      productId: entitlement.productIdentifier,
      willRenew: entitlement.willRenew,
    );
  }
}
```

### 4. Stripe Web Implementation
```dart
// lib/features/subscription/data/services/stripe_payment_service.dart
import 'dart:async';
import 'dart:html' as html;
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'payment_service.dart';
import '../models/product_model.dart';
import '../models/subscription_model.dart';

class StripePaymentService implements PaymentService {
  final _subscriptionController = StreamController<SubscriptionModel?>.broadcast();
  final _dio = Dio();
  String? _userId;

  @override
  Future<void> initialize(String userId) async {
    _userId = userId;
    // Listen to subscription changes via Supabase Realtime
    Supabase.instance.client
        .from('subscriptions')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .listen((data) {
          if (data.isNotEmpty) {
            _subscriptionController.add(_mapSubscription(data.first));
          }
        });
  }

  @override
  Future<List<ProductModel>> getProducts() async {
    // Fetch products from your backend or hardcode for now
    return [
      const ProductModel(
        id: 'price_pro_monthly',
        title: 'Artio Pro',
        description: 'Unlimited generations',
        price: '\$9.99/month',
        priceAmount: 9.99,
        currencyCode: 'USD',
        packageType: 'monthly',
      ),
    ];
  }

  @override
  Future<SubscriptionModel?> getActiveSubscription() async {
    final response = await Supabase.instance.client
        .from('subscriptions')
        .select()
        .eq('user_id', _userId!)
        .eq('status', 'active')
        .maybeSingle();

    return response != null ? _mapSubscription(response) : SubscriptionModel.free();
  }

  @override
  Future<bool> purchaseProduct(String productId) async {
    // Create Stripe Checkout session via Edge Function
    final response = await Supabase.instance.client.functions.invoke(
      'create-checkout-session',
      body: {
        'price_id': productId,
        'success_url': '${html.window.location.origin}/subscription/success',
        'cancel_url': '${html.window.location.origin}/subscription',
      },
    );

    if (response.status != 200) return false;

    final checkoutUrl = response.data['url'] as String;
    html.window.location.href = checkoutUrl;
    return true;
  }

  @override
  Future<bool> restorePurchases() async {
    // On web, subscriptions are already synced via webhooks
    return true;
  }

  @override
  Stream<SubscriptionModel?> get subscriptionStream => _subscriptionController.stream;

  SubscriptionModel _mapSubscription(Map<String, dynamic> data) {
    return SubscriptionModel(
      tier: data['tier'] == 'pro' ? SubscriptionTier.pro : SubscriptionTier.free,
      status: SubscriptionStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => SubscriptionStatus.none,
      ),
      expiresAt: data['expires_at'] != null
          ? DateTime.parse(data['expires_at'])
          : null,
      productId: data['stripe_price_id'],
      willRenew: data['cancel_at_period_end'] != true,
    );
  }
}
```

### 5. Payment Service Provider
```dart
// lib/features/subscription/data/services/payment_service_provider.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'payment_service.dart';
import 'revenuecat_payment_service.dart';
import 'stripe_payment_service.dart';

part 'payment_service_provider.g.dart';

@riverpod
PaymentService paymentService(PaymentServiceRef ref) {
  if (kIsWeb) {
    return StripePaymentService();
  } else {
    return RevenueCatPaymentService();
  }
}
```

### 6. Credits Notifier
```dart
// lib/features/subscription/domain/credits_notifier.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/services/payment_service_provider.dart';

part 'credits_notifier.g.dart';

@riverpod
class CreditsNotifier extends _$CreditsNotifier {
  @override
  Future<int> build() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return 0;

    final response = await Supabase.instance.client
        .from('profiles')
        .select('credits')
        .eq('id', userId)
        .single();

    return response['credits'] as int;
  }

  Future<bool> hasEnoughCredits(int required) async {
    // Check if user is premium first
    final paymentService = ref.read(paymentServiceProvider);
    final subscription = await paymentService.getActiveSubscription();

    if (subscription?.isPro == true) return true;

    final currentCredits = state.value ?? 0;
    return currentCredits >= required;
  }

  Future<void> addCredits(int amount) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    await Supabase.instance.client.rpc(
      'add_credits',
      params: {'user_id': userId, 'amount': amount},
    );

    ref.invalidateSelf();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
```

### 7. Rewarded Ad Button (Mobile Only)
```dart
// lib/features/subscription/presentation/widgets/rewarded_ad_button.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show Platform;
import '../../domain/credits_notifier.dart';

class RewardedAdButton extends ConsumerStatefulWidget {
  const RewardedAdButton({super.key});

  @override
  ConsumerState<RewardedAdButton> createState() => _RewardedAdButtonState();
}

class _RewardedAdButtonState extends ConsumerState<RewardedAdButton> {
  RewardedAd? _rewardedAd;
  bool _isLoading = false;
  int _adsWatchedToday = 0;
  static const _maxAdsPerDay = 10;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _loadAd();
    }
  }

  String get _adUnitId {
    if (Platform.isAndroid) {
      return dotenv.env['ADMOB_REWARDED_ANDROID'] ?? 'ca-app-pub-3940256099942544/5224354917'; // Test ID
    } else {
      return dotenv.env['ADMOB_REWARDED_IOS'] ?? 'ca-app-pub-3940256099942544/1712485313'; // Test ID
    }
  }

  void _loadAd() {
    setState(() => _isLoading = true);

    RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          setState(() {
            _rewardedAd = ad;
            _isLoading = false;
          });
        },
        onAdFailedToLoad: (error) {
          setState(() => _isLoading = false);
          debugPrint('Rewarded ad failed to load: ${error.message}');
        },
      ),
    );
  }

  void _showAd() {
    if (_rewardedAd == null || _adsWatchedToday >= _maxAdsPerDay) return;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadAd(); // Load next ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadAd();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        ref.read(creditsNotifierProvider.notifier).addCredits(1);
        setState(() => _adsWatchedToday++);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('+1 credit earned!')),
        );
      },
    );
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Don't show on web
    if (kIsWeb) return const SizedBox.shrink();

    final canWatch = _adsWatchedToday < _maxAdsPerDay;

    return Card(
      child: ListTile(
        leading: const Icon(Icons.play_circle_fill),
        title: const Text('Watch Ad for Credit'),
        subtitle: Text('${_maxAdsPerDay - _adsWatchedToday} remaining today'),
        trailing: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : FilledButton(
                onPressed: canWatch && _rewardedAd != null ? _showAd : null,
                child: const Text('Watch'),
              ),
      ),
    );
  }
}
```

### 8. Subscription Page
```dart
// lib/features/subscription/presentation/pages/subscription_page.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/subscription_notifier.dart';
import '../../domain/credits_notifier.dart';
import '../widgets/rewarded_ad_button.dart';
import '../widgets/subscription_card.dart';

class SubscriptionPage extends ConsumerWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionState = ref.watch(subscriptionNotifierProvider);
    final creditsState = ref.watch(creditsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Subscription')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current status card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Plan',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    subscriptionState.when(
                      data: (sub) => Row(
                        children: [
                          Icon(
                            sub?.isPro == true ? Icons.star : Icons.person,
                            color: sub?.isPro == true
                                ? Colors.amber
                                : Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            sub?.isPro == true ? 'Pro' : 'Free',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (_, __) => const Text('Error loading subscription'),
                    ),
                    if (subscriptionState.value?.isPro != true) ...[
                      const Divider(height: 24),
                      Row(
                        children: [
                          const Icon(Icons.toll),
                          const SizedBox(width: 8),
                          creditsState.when(
                            data: (credits) => Text(
                              '$credits credits remaining',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            loading: () => const Text('Loading...'),
                            error: (_, __) => const Text('--'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Pro plan card (only for free users)
            if (subscriptionState.value?.isPro != true) ...[
              Text(
                'Upgrade to Pro',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const SubscriptionCard(
                title: 'Artio Pro',
                price: '\$9.99/month',
                features: [
                  'Unlimited image generations',
                  'Priority processing',
                  'Access to premium templates',
                  'No ads',
                ],
                productId: 'artio_pro_monthly',
              ),
              const SizedBox(height: 24),

              // Rewarded ads (mobile only)
              if (!kIsWeb) ...[
                Text(
                  'Earn Free Credits',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const RewardedAdButton(),
              ],
            ],

            // Restore purchases
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => ref.read(subscriptionNotifierProvider.notifier).restorePurchases(),
              child: const Text('Restore Purchases'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Todo List

- [ ] Create subscription_model.dart
- [ ] Create product_model.dart
- [ ] Create payment_service.dart interface
- [ ] Implement revenuecat_payment_service.dart
- [ ] Implement stripe_payment_service.dart
- [ ] Create payment_service_provider.dart
- [ ] Implement subscription_notifier.dart
- [ ] Implement credits_notifier.dart
- [ ] Create subscription_page.dart
- [ ] Create subscription_card.dart widget
- [ ] Create rewarded_ad_button.dart widget
- [ ] Configure RevenueCat products and offerings
- [ ] Configure Stripe products and prices
- [ ] Create Stripe checkout Edge Function
- [ ] Create Stripe webhook Edge Function
- [ ] Set up Supabase subscriptions table
- [ ] Add add_credits and deduct_credits functions
- [ ] Initialize AdMob in main.dart (mobile only)
- [ ] Test purchase flow on iOS
- [ ] Test purchase flow on Android
- [ ] Test Stripe checkout on Web

## Success Criteria

- [ ] Free users see credits balance
- [ ] Rewarded ads work on mobile
- [ ] Subscription purchase completes
- [ ] Pro users have unlimited access
- [ ] Credits deducted on generation (free users)
- [ ] Subscription status syncs in real-time

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| RevenueCat web beta limitations | High | Medium | Use Stripe directly for web |
| Ad revenue low | Medium | Low | Focus on subscription conversion |
| Payment failures | Medium | High | Graceful error handling + retry |
| Receipt validation bypass | Low | High | Server-side validation via RevenueCat/Stripe webhooks |

## Security Considerations

- Never validate purchases client-side only
- RevenueCat/Stripe handle receipt validation
- Use Supabase Edge Functions for Stripe webhooks
- Service role key for webhook handler

## Next Steps

→ Phase 7: Settings Feature
