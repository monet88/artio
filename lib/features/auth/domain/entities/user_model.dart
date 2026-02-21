import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// Safely parse DateTime string; returns null on failure.
DateTime? _tryParseDateTime(String? value) {
  if (value == null || value.isEmpty) return null;

  return DateTime.tryParse(value);
}

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
    final metadata = user.userMetadata;

    return UserModel(
      id: user.id,
      email: user.email ?? '',
      displayName: (profile?['display_name'] as String?) ??
          (metadata?['name'] as String?),
      avatarUrl: (profile?['avatar_url'] as String?) ??
          (metadata?['avatar_url'] as String?),
      credits: (profile?['credits'] as num?)?.toInt() ?? 0,
      isPremium: (profile?['is_premium'] as bool? ?? false) ||
          profile?['role'] == 'admin',
      premiumExpiresAt: _tryParseDateTime(
        profile?['premium_expires_at'] as String?,
      ),
      createdAt: _tryParseDateTime(user.createdAt),
    );
  }
}
