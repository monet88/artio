---
phase: 1
plan: 2
wave: 1
depends_on: []
files_modified:
  - lib/features/auth/presentation/view_models/auth_view_model.dart
  - lib/features/auth/data/repositories/auth_repository.dart
autonomous: true
must_haves:
  truths:
    - "Double-clicking sign-in only produces one request"
    - "Concurrent profile creation does not crash"
    - "_notifyRouter called in all code paths of _handleSignedIn"
  artifacts:
    - "Guard check in signInWithEmail, signUpWithEmail, signInWithGoogle, signInWithApple"
    - "PostgreSQL 23505 handling in _createUserProfile"
    - "_notifyRouter in finally block of _handleSignedIn"
---

# Plan 1.2: Auth Concurrency Guards + State Notification Fix

<objective>
Fix three auth bugs:
1. No guard on sign-in methods — user can double-click and fire parallel auth requests
2. Profile creation TOCTOU race — concurrent requests can both try INSERT, causing unique constraint violation
3. `_notifyRouter()` missing in 2 code paths of `_handleSignedIn()` — causes router desync

Purpose: Prevent double-submit, race condition crashes, and router desync during authentication.
Output: Guarded auth methods + graceful conflict handling + consistent router notification
</objective>

<context>
Load for context:
- lib/features/auth/presentation/view_models/auth_view_model.dart (full file, 201 lines)
- lib/features/auth/data/repositories/auth_repository.dart (fetchOrCreateProfile + _createUserProfile)
- lib/features/auth/presentation/state/auth_state.dart (state types)
- artifacts/superpowers/brainstorm.md (verification evidence)
</context>

<tasks>

<task type="auto">
  <name>Add authenticating guard to sign-in methods</name>
  <files>
    lib/features/auth/presentation/view_models/auth_view_model.dart
  </files>
  <action>
    Add early-return guard at the START of these 4 methods:
    - `signInWithEmail()` (line 80)
    - `signUpWithEmail()` (line 92)
    - `signInWithGoogle()` (line 104)
    - `signInWithApple()` (line 114)

    Pattern for each:
    ```dart
    Future<void> signInWithEmail(String email, String password) async {
      if (state is AuthStateAuthenticating) return;  // ← ADD THIS
      state = const AuthState.authenticating();
      // ... rest unchanged
    }
    ```

    Use `state is AuthStateAuthenticating` — this matches the existing pattern already used in login_screen.dart and register_screen.dart (line 48/51).

    AVOID: Don't add guard to `signOut()` — it uses a different pattern (always clears state in finally).
    AVOID: Don't add guard to `_handleSignedIn()` or `_checkAuthentication()` — these are internal methods called from stream listeners, not user actions.
  </action>
  <verify>
    flutter analyze lib/features/auth/
    grep -n "is AuthStateAuthenticating" lib/features/auth/presentation/view_models/auth_view_model.dart → should show 4 guards
  </verify>
  <done>
    - All 4 user-facing auth methods have authenticating guard
    - Double-click on sign-in button produces only 1 request
  </done>
</task>

<task type="auto">
  <name>Handle unique constraint in profile creation</name>
  <files>
    lib/features/auth/data/repositories/auth_repository.dart
  </files>
  <action>
    Find the `_createUserProfile` method (or equivalent INSERT into profiles).
    Wrap the insert in a try-catch for PostgrestException:

    ```dart
    Future<void> _createUserProfile(String userId, String email) async {
      try {
        await _supabase.from('profiles').insert({
          'id': userId,
          'email': email,
        });
      } on PostgrestException catch (e) {
        if (e.code == '23505') return;  // unique_violation — profile already exists
        rethrow;
      }
    }
    ```

    This handles the TOCTOU race where two concurrent requests both check "profile exists? no" then both try to INSERT.

    AVOID: Don't use upsert — the race condition is specifically about the check-then-act pattern. Catching 23505 is the correct fix because it means another request already created the profile.
    AVOID: Don't change `fetchOrCreateProfile` logic — only add try-catch around the INSERT.
  </action>
  <verify>
    flutter analyze lib/features/auth/
    grep -n "23505" lib/features/auth/data/repositories/auth_repository.dart → should find the handler
  </verify>
  <done>
    - Profile creation race condition handled gracefully
    - Duplicate INSERT returns silently instead of crashing
    - Existing auth tests still pass
  </done>
</task>

<task type="auto">
  <name>Fix _notifyRouter missing in _handleSignedIn</name>
  <files>
    lib/features/auth/presentation/view_models/auth_view_model.dart
  </files>
  <action>
    Refactor `_handleSignedIn()` (lines 67-78) to ensure `_notifyRouter()` is called in ALL code paths:

    ```dart
    Future<void> _handleSignedIn() async {
      try {
        final authRepo = ref.read(authRepositoryProvider);
        final user = await authRepo.getCurrentUserWithProfile();
        if (user != null) {
          state = AuthState.authenticated(user);
        } else {
          state = const AuthState.unauthenticated();
        }
      } catch (e) {
        state = AuthState.error(AppExceptionMapper.toUserMessage(e));
      } finally {
        _notifyRouter();
      }
    }
    ```

    Changes:
    - Add `else` branch setting state to unauthenticated (was missing)
    - Move `_notifyRouter()` to `finally` block (was only in if-true branch)

    AVOID: Don't touch any other methods in this file — they already have correct _notifyRouter() calls (verified via Serena).
  </action>
  <verify>
    flutter test test/features/auth/
    grep -n "_notifyRouter" lib/features/auth/presentation/view_models/auth_view_model.dart → should show finally block
  </verify>
  <done>
    - _notifyRouter() called in all 3 paths: success, null user, error
    - Auth tests still pass
  </done>
</task>

</tasks>

<verification>
After all tasks, verify:
- [ ] `flutter test test/features/auth/` passes
- [ ] `flutter analyze` clean
- [ ] 4 guard checks in auth_view_model.dart
- [ ] 23505 handling in auth_repository.dart
- [ ] `_notifyRouter()` in finally block of `_handleSignedIn()`
</verification>

<success_criteria>
- [ ] Concurrent auth operations prevented at presentation layer
- [ ] Profile creation race handled at data layer
- [ ] Router always notified after auth state change
- [ ] No regression in auth flow
</success_criteria>
