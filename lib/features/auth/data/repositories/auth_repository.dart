import 'package:artio/core/config/env_config.dart';
import 'package:artio/core/constants/app_constants.dart';
import 'package:artio/core/exceptions/app_exception.dart';
import 'package:artio/core/providers/supabase_provider.dart';
import 'package:artio/features/auth/domain/entities/user_model.dart';
import 'package:artio/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:artio/utils/logger_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

part 'auth_repository.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
}

class AuthRepository implements IAuthRepository {
  const AuthRepository(this._supabase);
  final SupabaseClient _supabase;

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
      await _revenuecatLogIn(response.user!.id);
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
      await _revenuecatLogIn(response.user!.id);
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
    } on AuthException catch (e) {
      if (e.message.contains('canceled') || e.message.contains('cancelled')) {
        return;
      }
      throw AppException.auth(message: e.message);
    } catch (e) {
      if (e.toString().contains('canceled') ||
          e.toString().contains('cancelled')) {
        return;
      }
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
    } on AuthException catch (e) {
      if (e.message.contains('canceled') || e.message.contains('cancelled')) {
        return;
      }
      throw AppException.auth(message: e.message);
    } catch (e) {
      if (e.toString().contains('canceled') ||
          e.toString().contains('cancelled')) {
        return;
      }
      throw AppException.auth(message: e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    await _revenuecatLogOut();
    await _supabase.auth.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: AppConstants.resetPasswordCallback,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException.auth(message: e.toString());
    }
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
    await _revenuecatLogIn(user.id);
    var profile = await _fetchUserProfile(user.id);
    if (profile == null) {
      await _createUserProfile(user.id, user.email ?? '');
      profile = await _fetchUserProfile(user.id);
    }
    return profile;
  }

  Future<void> _createUserProfile(String userId, String email) async {
    try {
      await _supabase.from('profiles').insert({
        'id': userId,
        'email': email,
        'credits': AppConstants.defaultCredits,
        'is_premium': false,
        'created_at': DateTime.now().toIso8601String(),
      });
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        return; // unique_violation — profile already exists
      }
      rethrow;
    }
  }

  /// Link RevenueCat user identity to Supabase user ID.
  /// Errors are logged but never block the auth flow.
  Future<void> _revenuecatLogIn(String userId) async {
    if (EnvConfig.revenuecatAppleKey.isEmpty &&
        EnvConfig.revenuecatGoogleKey.isEmpty) {
      return;
    }
    try {
      await Purchases.logIn(userId);
      await _supabase
          .from('profiles')
          .update({'revenuecat_app_user_id': userId})
          .eq('id', userId);
    } on Object catch (e) {
      Log.w('RevenueCat logIn failed (non-blocking): $e');
    }
  }

  /// Clear RevenueCat user identity on logout.
  Future<void> _revenuecatLogOut() async {
    if (EnvConfig.revenuecatAppleKey.isEmpty &&
        EnvConfig.revenuecatGoogleKey.isEmpty) {
      return;
    }
    try {
      await Purchases.logOut();
    } on Object catch (e) {
      Log.w('RevenueCat logOut failed (non-blocking): $e');
    }
  }
}
