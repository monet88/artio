import 'package:supabase_flutter/supabase_flutter.dart' show AuthState, User, Session;
import '../entities/user_model.dart';

abstract class IAuthRepository {
  Stream<AuthState> get onAuthStateChange;
  User? get currentUser;
  Session? get currentSession;

  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> signUpWithEmail(String email, String password);
  Future<void> signInWithGoogle();
  Future<void> signInWithApple();
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<UserModel?> getCurrentUserWithProfile();
  Future<UserModel> refreshCurrentUser();
  Future<Map<String, dynamic>?> fetchOrCreateProfile(User user);
}
