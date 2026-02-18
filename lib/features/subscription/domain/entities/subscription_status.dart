import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_status.freezed.dart';
part 'subscription_status.g.dart';

/// String constants for subscription tier identifiers.
abstract final class SubscriptionTiers {
  static const pro = 'pro';
  static const ultra = 'ultra';
}

@freezed
class SubscriptionStatus with _$SubscriptionStatus {
  const factory SubscriptionStatus({
    /// 'pro', 'ultra', or null for free users
    String? tier,
    @Default(false) bool isActive,
    DateTime? expiresAt,
    @Default(false) bool willRenew,
  }) = _SubscriptionStatus;

  const SubscriptionStatus._();

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionStatusFromJson(json);

  /// User is on the Pro plan.
  bool get isPro => isActive && tier == SubscriptionTiers.pro;

  /// User is on the Ultra plan.
  bool get isUltra => isActive && tier == SubscriptionTiers.ultra;

  /// User is on the free tier (no active subscription).
  bool get isFree => !isPro && !isUltra;

  /// Monthly credits for the current tier.
  int get monthlyCredits {
    if (isUltra) return 500;
    if (isPro) return 200;
    return 0;
  }
}
