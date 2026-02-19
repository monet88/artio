import 'package:artio/features/subscription/domain/entities/subscription_package.dart';
import 'package:artio/features/subscription/domain/entities/subscription_status.dart';

abstract class ISubscriptionRepository {
  /// Get the current subscription status from RevenueCat.
  Future<SubscriptionStatus> getStatus();

  /// Get available subscription packages for the paywall.
  Future<List<SubscriptionPackage>> getOfferings();

  /// Purchase a subscription package.
  Future<SubscriptionStatus> purchase(SubscriptionPackage package);

  /// Restore previous purchases.
  Future<SubscriptionStatus> restore();
}
