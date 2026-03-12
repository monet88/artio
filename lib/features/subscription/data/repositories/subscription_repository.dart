import 'package:artio/core/exceptions/app_exception.dart';
import 'package:artio/features/subscription/domain/entities/subscription_package.dart';
import 'package:artio/features/subscription/domain/entities/subscription_status.dart';
import 'package:artio/features/subscription/domain/repositories/i_subscription_repository.dart';
import 'package:artio/utils/logger_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'subscription_repository.g.dart';

@riverpod
SubscriptionRepository subscriptionRepository(Ref ref) =>
    const SubscriptionRepository();

class SubscriptionRepository implements ISubscriptionRepository {
  const SubscriptionRepository();

  @override
  Future<SubscriptionStatus> getStatus() async {
    try {
      final info = await Purchases.getCustomerInfo();
      return _mapCustomerInfo(info);
    } on PlatformException catch (e) {
      throw AppException.payment(
        message: e.message ?? 'Failed to get subscription status',
        code: e.code,
      );
    }
  }

  @override
  Future<List<SubscriptionPackage>> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      final packages = offerings.current?.availablePackages ?? <Package>[];
      return packages
          .map(
            (p) => SubscriptionPackage(
              identifier: p.storeProduct.identifier,
              priceString: p.storeProduct.priceString,
              nativePackage: p,
            ),
          )
          .toList();
    } on PlatformException catch (e) {
      throw AppException.payment(
        message: e.message ?? 'Failed to load offerings',
        code: e.code,
      );
    }
  }

  @override
  Future<SubscriptionStatus> purchase(SubscriptionPackage package) async {
    try {
      final nativePkg = package.nativePackage as Package;
      final result = await Purchases.purchase(
        PurchaseParams.package(nativePkg),
      );

      // Always call verify-google-purchase after successful RC purchase.
      // transactionIdentifier on Android = orderId (GPA.xxx) — may be empty
      // for new subscriptions with free trials. Use timestamp fallback so edge
      // function is always called and Supabase is always updated.
      final rawToken = result.storeTransaction.transactionIdentifier;
      final productId = package.identifier;
      final purchaseRef = rawToken.isNotEmpty
          ? rawToken
          : 'rc-${productId}-${DateTime.now().millisecondsSinceEpoch}';
      await _verifyWithGooglePlay(purchaseRef, productId);

      return _mapCustomerInfo(result.customerInfo);
    } on PlatformException catch (e) {
      Log.e('[RC] purchase error code=${e.code} message=${e.message}');
      // RevenueCat error code 1 = purchase cancelled by user
      if (e.code == '1') {
        throw const AppException.payment(
          message: 'Purchase cancelled',
          code: 'user_cancelled',
        );
      }
      // RC error code 28 = ITEM_ALREADY_OWNED (Google Play).
      // User already has an active subscription — fetch current CustomerInfo
      // directly instead of calling restorePurchases(), which can fail with
      // allowSharingPlayStoreAccount=false when the receipt was made under a
      // different RC user session.
      if (e.code == '28') {
        Log.w('[RC] ITEM_ALREADY_OWNED — fetching current CustomerInfo');
        return getStatus();
      }
      throw AppException.payment(
        message: e.message ?? 'Purchase failed',
        code: e.code,
      );
    }
  }

  /// Validate purchase with Google Play Publisher API via Supabase edge function.
  /// Non-blocking: errors logged but do NOT throw (don't break purchase flow).
  Future<void> _verifyWithGooglePlay(String purchaseToken, String productId) async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.functions.invoke(
        'verify-google-purchase',
        body: {'purchaseToken': purchaseToken, 'productId': productId},
      );
      final body = response.data as Map<String, dynamic>?;
      if (body?['verified'] == true) {
        Log.i('[RC] GP verify OK: tier=${body?['tier']}, credits=${body?['credits']}');
      } else {
        Log.w('[RC] GP verify skipped: ${body?['reason']}');
      }
    } on Object catch (e) {
      Log.w('[RC] verify-google-purchase failed (non-blocking): $e');
    }
  }

  @override
  Future<SubscriptionStatus> restore() async {
    try {
      final info = await Purchases.restorePurchases();
      return _mapCustomerInfo(info);
    } on PlatformException catch (e) {
      throw AppException.payment(
        message: e.message ?? 'Failed to restore purchases',
        code: e.code,
      );
    }
  }

  /// Maps RevenueCat [CustomerInfo] to our domain entity.
  SubscriptionStatus _mapCustomerInfo(CustomerInfo info) {
    final active = info.entitlements.active;
    Log.d('[RC] active entitlements: ${active.keys.toList()}');

    String? tier;
    if (active.containsKey(SubscriptionTiers.ultra)) {
      tier = SubscriptionTiers.ultra;
    } else if (active.containsKey(SubscriptionTiers.pro)) {
      tier = SubscriptionTiers.pro;
    }

    final entitlement = active[tier];
    final expiresAt = entitlement?.expirationDate != null
        ? DateTime.tryParse(entitlement!.expirationDate!)
        : null;
    final willRenew = entitlement?.willRenew ?? false;

    return SubscriptionStatus(
      tier: tier,
      isActive: tier != null,
      expiresAt: expiresAt,
      willRenew: willRenew,
    );
  }
}
