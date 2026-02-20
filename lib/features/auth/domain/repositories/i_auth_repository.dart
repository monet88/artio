import 'package:artio/features/auth/domain/entities/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthState, Session, User;

/// Authentication repository interface.
/// Defines contract for all auth operations.

abstract class IAuthRepository {
  Stream<AuthState> get onAuthStateChange;
  User? get currentUser;
  Session? get currentSession;

  /// Returns [UserModel] on success.
  /// Throws an auth exception on failure.
  Future<UserModel> signInWithEmail(String email, String password);

  /// Signs up user with email and password.
  /// Returns [UserModel] on success.
  Future<UserModel> signUpWithEmail(String email, String password);
  Future<void> signInWithGoogle();
  Future<void> signInWithApple();
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<UserModel?> getCurrentUserWithProfile();
  Future<UserModel> refreshCurrentUser();
  Future<Map<String, dynamic>?> fetchOrCreateProfile(User user);
}
