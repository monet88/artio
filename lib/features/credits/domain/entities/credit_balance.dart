import 'package:freezed_annotation/freezed_annotation.dart';

part 'credit_balance.freezed.dart';
part 'credit_balance.g.dart';

@freezed
class CreditBalance with _$CreditBalance {
  const factory CreditBalance({
    required String userId,
    required int balance,
    required DateTime updatedAt,
  }) = _CreditBalance;

  factory CreditBalance.fromJson(Map<String, dynamic> json) =>
      _$CreditBalanceFromJson(_normalizeJson(json));

  static Map<String, dynamic> _normalizeJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    normalized['userId'] ??= json['user_id'];
    normalized['updatedAt'] ??= json['updated_at'];
    return normalized;
  }
}
