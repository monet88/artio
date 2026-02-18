// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_balance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreditBalanceImpl _$$CreditBalanceImplFromJson(Map<String, dynamic> json) =>
    _$CreditBalanceImpl(
      userId: json['user_id'] as String,
      balance: (json['balance'] as num).toInt(),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$CreditBalanceImplToJson(_$CreditBalanceImpl instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'balance': instance.balance,
      'updated_at': instance.updatedAt.toIso8601String(),
    };
