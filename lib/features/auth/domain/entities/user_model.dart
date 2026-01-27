import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    String? displayName,
    String? avatarUrl,
    @Default(0) int credits,
    @Default(false) bool isPremium,
    DateTime? premiumExpiresAt,
    DateTime? createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  factory UserModel.fromSupabaseUser(
    User user, {
    Map<String, dynamic>? profile,
  }) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      displayName: profile?['display_name'] ?? user.userMetadata?['name'],
      avatarUrl: profile?['avatar_url'] ?? user.userMetadata?['avatar_url'],
      credits: profile?['credits'] ?? 0,
      isPremium: profile?['is_premium'] ?? false,
      premiumExpiresAt: profile?['premium_expires_at'] != null
          ? DateTime.parse(profile!['premium_expires_at'])
          : null,
      createdAt: user.createdAt.isNotEmpty ? DateTime.parse(user.createdAt) : null,
    );
  }
}
