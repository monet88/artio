// ignore_for_file: invalid_annotation_target, Freezed uses @JsonKey on factory params intentionally
import 'package:freezed_annotation/freezed_annotation.dart';

part 'credit_balance.freezed.dart';
part 'credit_balance.g.dart';

@freezed
class CreditBalance with _$CreditBalance {
  const factory CreditBalance({
    @JsonKey(name: 'user_id') required String userId,
    required int balance,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _CreditBalance;

  factory CreditBalance.fromJson(Map<String, dynamic> json) =>
      _$CreditBalanceFromJson(json);
}
