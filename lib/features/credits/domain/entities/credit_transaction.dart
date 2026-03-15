import 'package:freezed_annotation/freezed_annotation.dart';

part 'credit_transaction.freezed.dart';
part 'credit_transaction.g.dart';

@freezed
class CreditTransaction with _$CreditTransaction {
  const factory CreditTransaction({
    required String id,
    required String userId,
    required int amount,

    /// One of: 'welcome_bonus', 'ad_reward', 'generation', 'refund',
    /// 'subscription', 'purchase', 'daily_reset', 'admin_grant', 'manual'
    required String type,
    required DateTime createdAt,
    String? referenceId,

    /// Human-readable description of the transaction.
    /// Populated server-side by SECURITY DEFINER functions.
    String? description,
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
