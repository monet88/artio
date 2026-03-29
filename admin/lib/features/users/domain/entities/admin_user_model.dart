// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_user_model.freezed.dart';
part 'admin_user_model.g.dart';

@freezed
class AdminUserModel with _$AdminUserModel {
  const factory AdminUserModel({
    required String id,
    required String email,
    @JsonKey(name: 'display_name') String? displayName,
    @Default('user') String role,
    @JsonKey(name: 'is_premium') @Default(false) bool isPremium,
    @JsonKey(name: 'subscription_tier') String? subscriptionTier,
    @JsonKey(name: 'credit_balance') @Default(0) int creditBalance,
    @JsonKey(name: 'is_banned') @Default(false) bool isBanned,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _AdminUserModel;

  const AdminUserModel._();

  factory AdminUserModel.fromJson(Map<String, dynamic> json) =>
      _$AdminUserModelFromJson(json);

  /// Display label for tier badge (uppercase)
  String get tierBadgeLabel =>
      (subscriptionTier ?? 'free').toUpperCase();
}
