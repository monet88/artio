import 'package:artio/features/auth/domain/entities/user_model.dart';

/// Test data factories for [UserModel]
class UserFixtures {
  /// Creates an authenticated user with optional overrides
  static UserModel authenticated({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    int? credits,
    bool? isPremium,
    DateTime? premiumExpiresAt,
    DateTime? createdAt,
  }) =>
      UserModel(
        id: id ?? 'test-user-${DateTime.now().millisecondsSinceEpoch}',
        email: email ?? 'test@example.com',
        displayName: displayName ?? 'Test User',
        avatarUrl: avatarUrl ?? 'https://example.com/avatar.png',
        credits: credits ?? 10,
        isPremium: isPremium ?? false,
        premiumExpiresAt: premiumExpiresAt,
        createdAt: createdAt ?? DateTime.now().subtract(const Duration(days: 30)),
      );

  /// Creates a guest/unauthenticated user
  static UserModel guest() => const UserModel(
        id: 'guest-user-id',
        email: 'guest@example.com',
        displayName: 'Guest',
      );

  /// Creates a premium user
  static UserModel premium({
    String? id,
    String? email,
  }) =>
      UserFixtures.authenticated(
        id: id,
        email: email,
        isPremium: true,
        premiumExpiresAt: DateTime.now().add(const Duration(days: 30)),
        credits: 100,
      );

  /// Creates a user with zero credits
  static UserModel noCredits({
    String? id,
    String? email,
  }) =>
      UserFixtures.authenticated(
        id: id,
        email: email,
        credits: 0,
        isPremium: false,
      );
}
