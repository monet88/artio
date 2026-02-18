import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_status.freezed.dart';
part 'subscription_status.g.dart';

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
  bool get isPro => isActive && tier == 'pro';

  /// User is on the Ultra plan.
  bool get isUltra => isActive && tier == 'ultra';

  /// User is on the free tier (no active subscription).
  bool get isFree => !isActive || tier == null;

  /// Monthly credits for the current tier.
  int get monthlyCredits {
    if (isUltra) return 500;
    if (isPro) return 200;
    return 0;
  }
}
