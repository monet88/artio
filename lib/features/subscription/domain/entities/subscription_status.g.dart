// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubscriptionStatusImpl _$$SubscriptionStatusImplFromJson(
  Map<String, dynamic> json,
) => _$SubscriptionStatusImpl(
  tier: json['tier'] as String?,
  isActive: json['isActive'] as bool? ?? false,
  expiresAt: json['expiresAt'] == null
      ? null
      : DateTime.parse(json['expiresAt'] as String),
  willRenew: json['willRenew'] as bool? ?? false,
);

Map<String, dynamic> _$$SubscriptionStatusImplToJson(
  _$SubscriptionStatusImpl instance,
) => <String, dynamic>{
  'tier': instance.tier,
  'isActive': instance.isActive,
  'expiresAt': instance.expiresAt?.toIso8601String(),
  'willRenew': instance.willRenew,
};
