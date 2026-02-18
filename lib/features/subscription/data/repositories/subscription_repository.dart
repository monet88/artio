import 'package:artio/core/exceptions/app_exception.dart';
import 'package:artio/features/subscription/domain/entities/subscription_package.dart';
import 'package:artio/features/subscription/domain/entities/subscription_status.dart';
import 'package:artio/features/subscription/domain/repositories/i_subscription_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
              identifier: p.identifier,
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
      final result =
          await Purchases.purchase(PurchaseParams.package(nativePkg));
      return _mapCustomerInfo(result.customerInfo);
    } on PlatformException catch (e) {
      // RevenueCat error code 1 = purchase cancelled by user
      if (e.code == '1') {
        throw const AppException.payment(
          message: 'Purchase cancelled',
          code: 'user_cancelled',
        );
      }
      throw AppException.payment(
        message: e.message ?? 'Purchase failed',
        code: e.code,
      );
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
