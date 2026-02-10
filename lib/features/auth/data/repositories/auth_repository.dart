import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../domain/entities/user_model.dart';
import '../../domain/repositories/i_auth_repository.dart';

part 'auth_repository.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
}

class AuthRepository implements IAuthRepository {
  final SupabaseClient _supabase;

  const AuthRepository(this._supabase);

  @override
  Stream<AuthState> get onAuthStateChange => _supabase.auth.onAuthStateChange;

  @override
  User? get currentUser => _supabase.auth.currentUser;
  @override
  Session? get currentSession => _supabase.auth.currentSession;

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw const AppException.auth(message: 'Sign in failed');
      }
      final profile = await _fetchUserProfile(response.user!.id);
      return UserModel.fromSupabaseUser(response.user!, profile: profile);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException.auth(message: e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmail(String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw const AppException.auth(message: 'Sign up failed');
      }
      await _createUserProfile(response.user!.id, email);
      return UserModel.fromSupabaseUser(response.user!);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException.auth(message: e.toString());
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : AppConstants.loginCallback,
      );
    } catch (e) {
      throw AppException.auth(message: e.toString());
    }
  }

  @override
  Future<void> signInWithApple() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: AppConstants.loginCallback,
      );
    } catch (e) {
      throw AppException.auth(message: e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: AppConstants.resetPasswordCallback,
    );
  }

  @override
  Future<UserModel?> getCurrentUserWithProfile() async {
    final user = currentUser;
    if (user == null) return null;
    final profile = await _fetchUserProfile(user.id);
    return UserModel.fromSupabaseUser(user, profile: profile);
  }

  @override
  Future<UserModel> refreshCurrentUser() async {
    final user = currentUser;
    if (user == null) {
      throw const AppException.auth(message: 'No authenticated user');
    }
    final profile = await _fetchUserProfile(user.id);
    return UserModel.fromSupabaseUser(user, profile: profile);
  }

  Future<Map<String, dynamic>?> _fetchUserProfile(String userId) async {
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return response;
  }

  @override
  Future<Map<String, dynamic>?> fetchOrCreateProfile(User user) async {
    var profile = await _fetchUserProfile(user.id);
    if (profile == null) {
      await _createUserProfile(user.id, user.email ?? '');
      profile = await _fetchUserProfile(user.id);
    }
    return profile;
  }

  Future<void> _createUserProfile(String userId, String email) async {
    await _supabase.from('profiles').insert({
      'id': userId,
      'email': email,
      'credits': AppConstants.defaultCredits,
      'is_premium': false,
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
