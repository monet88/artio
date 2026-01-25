import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import '../../../exceptions/app_exception.dart';
import '../model/user_model.dart';

part 'auth_repository.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) => AuthRepository();

class AuthRepository {
  final _supabase = Supabase.instance.client;

  Stream<AuthState> get onAuthStateChange => _supabase.auth.onAuthStateChange;

  User? get currentUser => _supabase.auth.currentUser;
  Session? get currentSession => _supabase.auth.currentSession;

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

  Future<void> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'com.artio.app://login-callback',
      );
    } catch (e) {
      throw AppException.auth(message: e.toString());
    }
  }

  Future<void> signInWithApple() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'com.artio.app://login-callback',
      );
    } catch (e) {
      throw AppException.auth(message: e.toString());
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: 'com.artio.app://reset-password',
    );
  }

  Future<UserModel?> getCurrentUserWithProfile() async {
    final user = currentUser;
    if (user == null) return null;
    final profile = await _fetchUserProfile(user.id);
    return UserModel.fromSupabaseUser(user, profile: profile);
  }

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
      'credits': 5,
      'is_premium': false,
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
