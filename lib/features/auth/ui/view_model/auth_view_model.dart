import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../routing/app_router.dart';
import '../../model/user_model.dart';
import '../../repository/auth_repository.dart';
import '../state/auth_state.dart';

part 'auth_view_model.g.dart';

@riverpod
class AuthViewModel extends _$AuthViewModel implements Listenable {
  VoidCallback? _routerListener;
  StreamSubscription? _authSubscription;

  @override
  AuthState build() {
    final authRepo = ref.watch(authRepositoryProvider);

    _authSubscription?.cancel();
    _authSubscription = authRepo.onAuthStateChange.listen((data) {
      if (data.session != null) {
        _handleSignedIn();
      } else {
        state = const AuthState.unauthenticated();
        _notifyRouter();
      }
    });

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
    } catch (e) {
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
        _notifyRouter();
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const AuthState.authenticating();
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final user = await authRepo.signInWithEmail(email, password);
      state = AuthState.authenticated(user);
      _notifyRouter();
    } catch (e) {
      state = AuthState.error(_parseErrorMessage(e));
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    state = const AuthState.authenticating();
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final user = await authRepo.signUpWithEmail(email, password);
      state = AuthState.authenticated(user);
      _notifyRouter();
    } catch (e) {
      state = AuthState.error(_parseErrorMessage(e));
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AuthState.authenticating();
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.signInWithGoogle();
    } catch (e) {
      state = AuthState.error(_parseErrorMessage(e));
    }
  }

  Future<void> signInWithApple() async {
    state = const AuthState.authenticating();
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.signInWithApple();
    } catch (e) {
      state = AuthState.error(_parseErrorMessage(e));
    }
  }

  Future<void> signOut() async {
    final authRepo = ref.read(authRepositoryProvider);
    await authRepo.signOut();
    state = const AuthState.unauthenticated();
    _notifyRouter();
  }

  Future<void> resetPassword(String email) async {
    final authRepo = ref.read(authRepositoryProvider);
    await authRepo.resetPassword(email);
  }

  UserModel? get currentUser => switch (state) {
        AuthStateAuthenticated(user: final u) => u,
        _ => null,
      };

  String? redirect({required String currentPath}) {
    final isAuthenticating = switch (state) {
      AuthStateInitial() || AuthStateAuthenticating() => true,
      _ => false,
    };
    if (isAuthenticating) return null;

    final isLoggedIn = switch (state) {
      AuthStateAuthenticated() => true,
      _ => false,
    };

    final isAuthRoute = currentPath == AppRoutes.login ||
        currentPath == AppRoutes.register ||
        currentPath.startsWith('/forgot-password');

    if (!isLoggedIn && !isAuthRoute && currentPath != AppRoutes.splash) {
      return AppRoutes.login;
    }

    if (isLoggedIn && isAuthRoute) {
      return AppRoutes.home;
    }

    if (currentPath == AppRoutes.splash) {
      return isLoggedIn ? AppRoutes.home : AppRoutes.login;
    }

    return null;
  }

  void _notifyRouter() => _routerListener?.call();

  String _parseErrorMessage(Object e) {
    final msg = e.toString();
    if (msg.contains('Invalid login credentials')) {
      return 'Invalid email or password';
    }
    if (msg.contains('User already registered')) {
      return 'An account with this email already exists';
    }
    if (msg.contains('Email not confirmed')) {
      return 'Please verify your email before signing in';
    }
    return msg.replaceAll('Exception: ', '');
  }

  @override
  void addListener(VoidCallback listener) => _routerListener = listener;

  @override
  void removeListener(VoidCallback listener) => _routerListener = null;
}
