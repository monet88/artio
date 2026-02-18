import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_package.freezed.dart';

/// A domain-level subscription package, decoupled from RevenueCat SDK.
@freezed
class SubscriptionPackage with _$SubscriptionPackage {
  const factory SubscriptionPackage({
    /// Store product identifier (e.g., 'artio_pro_monthly').
    required String identifier,

    /// Localized price string (e.g., '$9.99/month').
    required String priceString,

    /// The native SDK package object (cast back in the data layer).
    required Object nativePackage,
  }) = _SubscriptionPackage;
}
