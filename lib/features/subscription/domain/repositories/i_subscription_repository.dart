import 'package:artio/features/subscription/domain/entities/subscription_status.dart';
// TODO(arch): Abstract Package type to a domain entity to decouple from RevenueCat SDK.
import 'package:purchases_flutter/purchases_flutter.dart';

abstract class ISubscriptionRepository {
  /// Get the current subscription status from RevenueCat.
  Future<SubscriptionStatus> getStatus();

  /// Get available subscription packages for the paywall.
  Future<List<Package>> getOfferings();

  /// Purchase a subscription package.
  Future<SubscriptionStatus> purchase(Package package);

  /// Restore previous purchases.
  Future<SubscriptionStatus> restore();
}
