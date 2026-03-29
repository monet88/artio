// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AdminUserModelImpl _$$AdminUserModelImplFromJson(Map<String, dynamic> json) =>
    _$AdminUserModelImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String?,
      role: json['role'] as String? ?? 'user',
      isPremium: json['is_premium'] as bool? ?? false,
      subscriptionTier: json['subscription_tier'] as String?,
      creditBalance: (json['credit_balance'] as num?)?.toInt() ?? 0,
      isBanned: json['is_banned'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$AdminUserModelImplToJson(
  _$AdminUserModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'display_name': instance.displayName,
  'role': instance.role,
  'is_premium': instance.isPremium,
  'subscription_tier': instance.subscriptionTier,
  'credit_balance': instance.creditBalance,
  'is_banned': instance.isBanned,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
