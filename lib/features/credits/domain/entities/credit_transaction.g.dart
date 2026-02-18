// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreditTransactionImpl _$$CreditTransactionImplFromJson(
  Map<String, dynamic> json,
) => _$CreditTransactionImpl(
  id: json['id'] as String,
  userId: json['userId'] as String,
  amount: (json['amount'] as num).toInt(),
  type: json['type'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  referenceId: json['referenceId'] as String?,
);

Map<String, dynamic> _$$CreditTransactionImplToJson(
  _$CreditTransactionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'amount': instance.amount,
  'type': instance.type,
  'createdAt': instance.createdAt.toIso8601String(),
  'referenceId': instance.referenceId,
};
