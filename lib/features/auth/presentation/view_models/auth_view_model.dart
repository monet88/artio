import 'dart:async';

import 'package:artio/core/config/sentry_config.dart';
import 'package:artio/core/exceptions/app_exception.dart';
import 'package:artio/core/state/user_scoped_providers.dart';
import 'package:artio/core/utils/app_exception_mapper.dart';
import 'package:artio/features/auth/domain/entities/user_model.dart';
import 'package:artio/features/auth/domain/providers/auth_repository_provider.dart';
import 'package:artio/features/auth/domain/providers/onboarding_provider.dart';
import 'package:artio/features/auth/presentation/state/auth_state.dart';
import 'package:artio/routing/routes/app_routes.dart';
import 'package:artio/utils/logger_service.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    as supabase
    show AuthState;

part 'auth_view_model.g.dart';

@riverpod
class AuthViewModel extends _$AuthViewModel implements Listenable {
  VoidCallback? _routerListener;
  StreamSubscription<supabase.AuthState>? _authSubscription;
  Timer? _oauthTimeoutTimer;
  static const _oauthTimeoutDuration = Duration(minutes: 3);

  /// Cached onboarding completion flag — loaded async, used sync in redirect().
  bool _onboardingDone = true; // Optimistic: assume done to avoid flicker

  @override
  AuthState build() {
    final authRepo = ref.watch(authRepositoryProvider);

    // Fix subscription race: create new subscription before canceling old one
    // to avoid missing auth events during the swap.
    final oldSub = _authSubscription;
    _authSubscription = authRepo.onAuthStateChange.listen(
      (data) {
        _oauthTimeoutTimer?.cancel();
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

    ref.onDispose(() {
      _authSubscription?.cancel();
      _oauthTimeoutTimer?.cancel();
    });

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
    // Load onboarding flag after determining auth state.
    await _loadOnboardingFlag();
    _notifyRouter();
  }

  Future<void> _loadOnboardingFlag() async {
    try {
      _onboardingDone = await ref
          .read(onboardingDoneProvider.future)
          .timeout(const Duration(seconds: 2), onTimeout: () => true);
    } on Object {
      _onboardingDone = true; // On error, skip onboarding to avoid soft-lock
    }
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
    if (email.trim().isEmpty) {
      state = const AuthState.error('Email is required');
      return;
    }
    if (password.isEmpty) {
      state = const AuthState.error('Password is required');
      return;
    }
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
    if (email.trim().isEmpty) {
      state = const AuthState.error('Email is required');
      return;
    }
    if (password.isEmpty) {
      state = const AuthState.error('Password is required');
      return;
    }
    if (password.length < 6) {
      state = const AuthState.error('Password must be at least 6 characters');
      return;
    }
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
    _oauthTimeoutTimer?.cancel();
    _oauthTimeoutTimer = Timer(_oauthTimeoutDuration, () {
      if (state is AuthStateAuthenticating) {
        state = const AuthState.error('Sign in timed out. Please try again.');
      }
    });
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.signInWithGoogle();
      // Only set to success if user actually got populated. In case of cancellation,
      // the repo returns void, but user state listener will reset to unauthenticated.
    } on Exception catch (e) {
      _oauthTimeoutTimer?.cancel();
      // Revert loading on error.
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
    if (trimmed.isEmpty ||
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed)) {
      throw const AppException.auth(
        message: 'Please enter a valid email address',
      );
    }
    // Generic UI handler: Even on failure, mask it so we do not expose valid/invalid emails.
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.resetPassword(trimmed);
    } on Exception catch (e) {
      if (e is AppException &&
          e.message == 'Please enter a valid email address') {
        rethrow;
      }
      // We log but DO NOT leak errors about user not existing to the UI
      Log.i('Failed to send reset email non-fatally: $e');
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

    final isAuthRoute =
        currentPath == const LoginRoute().location ||
        currentPath == const RegisterRoute().location ||
        currentPath.startsWith('/forgot-password');

    final isOnboardingRoute = currentPath == const OnboardingRoute().location;

    // Splash always goes to Home (or onboarding if first time).
    if (currentPath == const SplashRoute().location) {
      return isLoggedIn && !_onboardingDone
          ? const OnboardingRoute().location
          : const HomeRoute().location;
    }

    // After login: redirect to onboarding if not yet done.
    if (isLoggedIn && !_onboardingDone && !isOnboardingRoute) {
      return const OnboardingRoute().location;
    }

    // Logged-in users shouldn't see auth screens.
    if (isLoggedIn && isAuthRoute) {
      return const HomeRoute().location;
    }

    // Logged-in users who finished onboarding shouldn't see onboarding again.
    if (isLoggedIn && _onboardingDone && isOnboardingRoute) {
      return const HomeRoute().location;
    }

    // Force unauthenticated users to login on protected routes.
    if (!isLoggedIn &&
        !isAuthRoute &&
        currentPath != const SplashRoute().location) {
      return const LoginRoute().location;
    }

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
