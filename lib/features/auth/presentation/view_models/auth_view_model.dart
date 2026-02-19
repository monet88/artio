import 'dart:async';

import 'package:artio/core/config/sentry_config.dart';
import 'package:artio/core/exceptions/app_exception.dart';
import 'package:artio/core/state/user_scoped_providers.dart';
import 'package:artio/core/utils/app_exception_mapper.dart';
import 'package:artio/features/auth/domain/entities/user_model.dart';
import 'package:artio/features/auth/domain/providers/auth_repository_provider.dart';
import 'package:artio/features/auth/presentation/state/auth_state.dart';
import 'package:artio/routing/routes/app_routes.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase show AuthState;

part 'auth_view_model.g.dart';

@riverpod
class AuthViewModel extends _$AuthViewModel implements Listenable {
  VoidCallback? _routerListener;
  StreamSubscription<supabase.AuthState>? _authSubscription;

  @override
  AuthState build() {
    final authRepo = ref.watch(authRepositoryProvider);

    // Fix subscription race: create new subscription before canceling old one
    // to avoid missing auth events during the swap.
    final oldSub = _authSubscription;
    _authSubscription = authRepo.onAuthStateChange.listen(
      (data) {
        if (data.session != null) {
          _handleSignedIn();
        } else {
          state = const AuthState.unauthenticated();
          _notifyRouter();
        }
      },
      onError: (Object e, StackTrace st) async {
        await SentryConfig.captureException(e, stackTrace: st);
      },
    );
    oldSub?.cancel();

    ref.onDispose(() => _authSubscription?.cancel());

    _checkAuthentication();
    return const AuthState.initial();
  }

  Future<void> _checkAuthentication() async {
    state = const AuthState.authenticating();
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final user = await authRepo.getCurrentUserWithProfile();
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = const AuthState.unauthenticated();
      }
    } on Object catch (e, st) {
      await SentryConfig.captureException(e, stackTrace: st);
      state = const AuthState.unauthenticated();
    }
    _notifyRouter();
  }

  Future<void> _handleSignedIn() async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final user = await authRepo.getCurrentUserWithProfile();
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = const AuthState.unauthenticated();
      }
    } on Exception catch (e) {
      state = AuthState.error(AppExceptionMapper.toUserMessage(e));
    } finally {
      _notifyRouter();
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    if (state is AuthStateAuthenticating) return;
    state = const AuthState.authenticating();
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final user = await authRepo.signInWithEmail(email, password);
      state = AuthState.authenticated(user);
      _notifyRouter();
    } on Exception catch (e) {
      state = AuthState.error(_parseErrorMessage(e));
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    if (state is AuthStateAuthenticating) return;
    state = const AuthState.authenticating();
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final user = await authRepo.signUpWithEmail(email, password);
      state = AuthState.authenticated(user);
      _notifyRouter();
    } on Exception catch (e) {
      state = AuthState.error(_parseErrorMessage(e));
    }
  }

  Future<void> signInWithGoogle() async {
    if (state is AuthStateAuthenticating) return;
    state = const AuthState.authenticating();
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.signInWithGoogle();
    } on Exception catch (e) {
      state = AuthState.error(_parseErrorMessage(e));
    }
  }

  Future<void> signInWithApple() async {
    if (state is AuthStateAuthenticating) return;
    state = const AuthState.authenticating();
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.signInWithApple();
    } on Exception catch (e) {
      state = AuthState.error(_parseErrorMessage(e));
    }
  }

  Future<void> signOut() async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.signOut();
    } on Object catch (e, st) {
      // Log error but do not rethrow — local state must be cleared
      // regardless of API success to avoid stuck authenticated state.
      await SentryConfig.captureException(e, stackTrace: st);
    } finally {
      invalidateUserScopedProviders(ref);
      state = const AuthState.unauthenticated();
      _notifyRouter();
    }
  }

  Future<void> resetPassword(String email) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed)) {
      throw const AppException.auth(message: 'Please enter a valid email address');
    }
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.resetPassword(trimmed);
    } on Exception catch (e) {
      if (e is AppException) rethrow;
      throw const AppException.auth(message: 'Failed to send reset email');
    }
  }

  UserModel? get currentUser => switch (state) {
        AuthStateAuthenticated(user: final u) => u,
        _ => null,
      };

  bool get isLoggedIn => state is AuthStateAuthenticated;

  String? redirect({required String currentPath}) {
    final isAuthenticating = switch (state) {
      AuthStateInitial() || AuthStateAuthenticating() => true,
      _ => false,
    };
    if (isAuthenticating) return null;

    final isAuthRoute = currentPath == const LoginRoute().location ||
        currentPath == const RegisterRoute().location ||
        currentPath.startsWith('/forgot-password');

    // Splash always goes to Home
    if (currentPath == const SplashRoute().location) {
      return const HomeRoute().location;
    }

    // Logged-in users shouldn't see auth screens
    if (isLoggedIn && isAuthRoute) {
      return const HomeRoute().location;
    }

    // No forced login redirect — allow unauthenticated users everywhere
    return null;
  }

  void _notifyRouter() => _routerListener?.call();

  String _parseErrorMessage(Object e) {
    return AppExceptionMapper.toUserMessage(e);
  }

  @override
  void addListener(VoidCallback listener) => _routerListener = listener;

  @override
  void removeListener(VoidCallback listener) => _routerListener = null;
}
