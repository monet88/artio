import 'package:freezed_annotation/freezed_annotation.dart';

part 'credit_transaction.freezed.dart';
part 'credit_transaction.g.dart';

@freezed
class CreditTransaction with _$CreditTransaction {
  const factory CreditTransaction({
    required String id,
    required String userId,
    required int amount,
    /// One of: 'generation', 'welcome_bonus', 'ad_reward', 'subscription', 'refund', 'manual'
    required String type,
    required DateTime createdAt,
    String? referenceId,
  }) = _CreditTransaction;

  factory CreditTransaction.fromJson(Map<String, dynamic> json) =>
      _$CreditTransactionFromJson(_normalizeJson(json));

  static Map<String, dynamic> _normalizeJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    normalized['userId'] ??= json['user_id'];
    normalized['referenceId'] ??= json['reference_id'];
    normalized['createdAt'] ??= json['created_at'];
    return normalized;
  }
}
