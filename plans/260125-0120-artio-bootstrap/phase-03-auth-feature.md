---
title: "Phase 3: Auth Feature"
status: completed
effort: 5h
---

# Phase 3: Auth Feature

## Context Links

- [Supabase Flutter Auth](https://supabase.com/docs/reference/dart/auth-signinwithpassword)
- [go_router + Riverpod Auth Pattern](https://q.agency/blog/handling-authentication-state-with-go_router-and-riverpod/)

## Overview

Implement authentication with Supabase including email/password, social logins (Google, Apple), and auth state management with go_router integration.

## Key Insights

- **AuthNotifier extends Notifier AND implements Listenable** for router integration
- Supabase handles session persistence automatically via `supabase_flutter`
- `onAuthStateChange` stream provides real-time auth updates
- Apple Sign-In required on iOS if other social logins present

## Requirements

### Functional
- Email/password sign up and sign in
- Google OAuth sign in
- Apple Sign In (iOS only)
- Password reset via Email OTP
- Sign out
- Auth state persisted across sessions
- Onboarding: 2-3 feature slides

### Non-Functional
- Router automatically redirects on auth changes
- Loading states during auth operations
- Error messages user-friendly

## Architecture

### Auth State Machine
```
AuthStateInitial (app start)
    ↓ checkIfAuthenticated()
AuthStateAuthenticating
    ↓
┌───────────────────┐
│ AuthStateAuthenticated │ ← signIn success
└───────────────────┘
         ↑ ↓
┌────────────────────┐
│ AuthStateUnauthenticated │ ← signOut / token expired
└────────────────────┘
```

### Feature Structure
```
lib/features/auth/
├── domain/
│   ├── entities/
│   │   └── auth_user.dart
│   └── repositories/
│       └── i_auth_repository.dart (interface)
├── data/
│   ├── data_sources/
│   │   └── auth_remote_data_source.dart
│   ├── dtos/
│   │   └── user_dto.dart
│   └── repositories/
│       └── auth_repository_impl.dart
└── presentation/
    ├── providers/
    │   └── auth_provider.dart
    ├── pages/
    │   ├── login_page.dart
    │   ├── register_page.dart
    │   ├── onboarding_page.dart
    │   └── forgot_password_page.dart
    └── widgets/
        ├── social_login_buttons.dart
        └── auth_form_field.dart
```

## Related Code Files

### Create
- `lib/features/auth/data/models/user_model.dart`
- `lib/features/auth/data/repositories/auth_repository.dart`
- `lib/features/auth/domain/auth_state.dart`
- `lib/features/auth/domain/auth_notifier.dart`
- `lib/features/auth/presentation/pages/login_page.dart`
- `lib/features/auth/presentation/pages/register_page.dart`
- `lib/features/auth/presentation/pages/forgot_password_page.dart`
- `lib/features/auth/presentation/widgets/social_login_buttons.dart`

## Implementation Steps

### 1. User Model with Freezed
```dart
// lib/features/auth/data/models/user_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

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

  factory UserModel.fromSupabaseUser(User user, {Map<String, dynamic>? profile}) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      displayName: profile?['display_name'] ?? user.userMetadata?['name'],
      avatarUrl: profile?['avatar_url'] ?? user.userMetadata?['avatar_url'],
      credits: profile?['credits'] ?? 0,
      isPremium: profile?['is_premium'] ?? false,
      premiumExpiresAt: profile?['premium_expires_at'] != null
          ? DateTime.parse(profile!['premium_expires_at'])
          : null,
      createdAt: user.createdAt != null
          ? DateTime.parse(user.createdAt!)
          : null,
    );
  }
}
```

### 2. Auth State
```dart
// lib/features/auth/domain/auth_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../data/models/user_model.dart';

part 'auth_state.freezed.dart';

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthStateInitial;
  const factory AuthState.authenticating() = AuthStateAuthenticating;
  const factory AuthState.authenticated(UserModel user) = AuthStateAuthenticated;
  const factory AuthState.unauthenticated() = AuthStateUnauthenticated;
  const factory AuthState.error(String message) = AuthStateError;
}
```

### 3. Auth Repository
```dart
// lib/features/auth/data/repositories/auth_repository.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../models/user_model.dart';

part 'auth_repository.g.dart';

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) => AuthRepository();

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
    } on AuthException catch (e) {
      throw AppException.auth(message: e.message, code: e.statusCode);
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
      // Create user profile with initial credits
      await _createUserProfile(response.user!.id, email);
      return UserModel.fromSupabaseUser(response.user!);
    } on AuthException catch (e) {
      throw AppException.auth(message: e.message, code: e.statusCode);
    }
  }

  Future<UserModel> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'com.artio.app://login-callback',
      );
      // OAuth flow handles redirect; user will be available after
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const AppException.auth(message: 'Google sign in failed');
      }
      final profile = await _fetchOrCreateProfile(user);
      return UserModel.fromSupabaseUser(user, profile: profile);
    } on AuthException catch (e) {
      throw AppException.auth(message: e.message, code: e.statusCode);
    }
  }

  Future<UserModel> signInWithApple() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'com.artio.app://login-callback',
      );
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const AppException.auth(message: 'Apple sign in failed');
      }
      final profile = await _fetchOrCreateProfile(user);
      return UserModel.fromSupabaseUser(user, profile: profile);
    } on AuthException catch (e) {
      throw AppException.auth(message: e.message, code: e.statusCode);
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

  Future<Map<String, dynamic>?> _fetchUserProfile(String userId) async {
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return response;
  }

  Future<Map<String, dynamic>?> _fetchOrCreateProfile(User user) async {
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
      'credits': 5, // Initial free credits
      'is_premium': false,
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
```

### 4. Auth Notifier with Listenable
```dart
// lib/features/auth/domain/auth_notifier.dart
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/auth_repository.dart';
import 'auth_state.dart';
import '../../../core/router/route_names.dart';

part 'auth_notifier.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier implements Listenable {
  VoidCallback? _routerListener;

  @override
  AuthState build() {
    final authRepo = ref.watch(authRepositoryProvider);

    // Listen to auth state changes from Supabase
    authRepo.onAuthStateChange.listen((data) {
      if (data.session != null) {
        _handleSignedIn();
      } else {
        state = const AuthState.unauthenticated();
        _notifyRouter();
      }
    });

    // Check initial auth state
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
      state = AuthState.error(e.toString());
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
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AuthState.authenticating();
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.signInWithGoogle();
      // OAuth redirect will trigger onAuthStateChange
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signInWithApple() async {
    state = const AuthState.authenticating();
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.signInWithApple();
    } catch (e) {
      state = AuthState.error(e.toString());
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

  // --- Router Integration ---

  String? redirect({required String currentPath}) {
    final isAuthenticating = switch (state) {
      AuthStateInitial() || AuthStateAuthenticating() => true,
      _ => false,
    };
    if (isAuthenticating) return null; // Still loading

    final isLoggedIn = switch (state) {
      AuthStateAuthenticated() => true,
      _ => false,
    };

    final isAuthRoute = currentPath == RouteNames.login ||
        currentPath == RouteNames.register ||
        currentPath.startsWith('/forgot-password');

    // Not logged in trying to access protected route
    if (!isLoggedIn && !isAuthRoute && currentPath != RouteNames.splash) {
      return RouteNames.login;
    }

    // Logged in trying to access auth route
    if (isLoggedIn && isAuthRoute) {
      return RouteNames.home;
    }

    // Splash screen redirect
    if (currentPath == RouteNames.splash) {
      return isLoggedIn ? RouteNames.home : RouteNames.login;
    }

    return null; // Allow access
  }

  void _notifyRouter() {
    _routerListener?.call();
  }

  @override
  void addListener(VoidCallback listener) => _routerListener = listener;

  @override
  void removeListener(VoidCallback listener) => _routerListener = null;
}
```

### 5. Login Page UI
```dart
// lib/features/auth/presentation/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/auth_notifier.dart';
import '../../domain/auth_state.dart';
import '../widgets/social_login_buttons.dart';
import '../../../../core/router/route_names.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      ref.read(authNotifierProvider.notifier).signInWithEmail(
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthStateAuthenticating;

    ref.listen<AuthState>(authNotifierProvider, (_, state) {
      if (state is AuthStateError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message)),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                Text(
                  'Welcome to Artio',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Art Made Simple',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: isLoading ? null : _handleLogin,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Sign In'),
                ),
                const SizedBox(height: 24),
                const SocialLoginButtons(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () => context.push(RouteNames.register),
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

## Todo List

- [x] Create profiles table in Supabase with RLS policies
- [x] Implement user_model.dart with Freezed
- [x] Implement auth_state.dart sealed class
- [x] Implement auth_repository.dart with all methods
- [x] Implement auth_notifier.dart with Listenable
- [x] Create login_page.dart UI
- [x] Create register_page.dart UI
- [x] Create forgot_password_page.dart
- [x] Create social_login_buttons.dart widget
- [ ] Configure OAuth providers in Supabase dashboard
- [ ] Set up deep link handling for OAuth callbacks
- [x] Run build_runner and verify
- [ ] Test complete auth flow

## Success Criteria

- Email sign up/in works
- Google/Apple OAuth works
- Router redirects correctly on auth changes
- Session persists across app restarts
- Sign out clears session and redirects to login

## Risk Assessment

| Risk | Mitigation |
|------|------------|
| OAuth redirect not working | Test deep links on each platform |
| Session not persisting | Verify supabase_flutter storage |
| Race conditions in auth state | Use proper async/await |

## Security Considerations

- Never store passwords locally
- Use Supabase's built-in session management
- Implement RLS policies on profiles table
- Sanitize OAuth user data before storing

## Next Steps

→ Phase 4: Template Engine
