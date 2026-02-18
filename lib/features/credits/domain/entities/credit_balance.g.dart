// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_balance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreditBalanceImpl _$$CreditBalanceImplFromJson(Map<String, dynamic> json) =>
    _$CreditBalanceImpl(
      userId: json['userId'] as String,
      balance: (json['balance'] as num).toInt(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$CreditBalanceImplToJson(_$CreditBalanceImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'balance': instance.balance,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
