---
plan: 1
wave: 1
pr: "fix(auth): input validation and OAuth timeout"
---

# Plan 1: Auth Fixes

## Objective
Add input validation to email/password auth methods and implement OAuth timeout
to prevent stuck authenticating state. Both changes are in a single file
(`auth_view_model.dart`) so they ship as one atomic PR.

## Context
- @plans/260220-0845-edge-case-fixes/plan.md — Full plan with code snippets
- @lib/features/auth/presentation/view_models/auth_view_model.dart — Target file
- @lib/features/auth/presentation/state/auth_state.dart — State types
- @test/features/auth/ — Existing auth tests

## Tasks

<task type="auto">
  <name>Add empty input validation to signInWithEmail and signUpWithEmail</name>
  <files>lib/features/auth/presentation/view_models/auth_view_model.dart</files>
  <action>
    Add input validation BEFORE the `AuthStateAuthenticating` guard in both methods:

    In `signInWithEmail`:
    - Add: if email.trim().isEmpty → set AuthState.error('Email is required'), return
    - Add: if password.isEmpty → set AuthState.error('Password is required'), return
    - Keep existing `if (state is AuthStateAuthenticating) return;` AFTER validation

    In `signUpWithEmail`:
    - Same email/password checks as signIn
    - Add: if password.length < 6 → set AuthState.error('Password must be at least 6 characters'), return
    - Keep existing guard AFTER validation

    DO NOT change any other methods. Match existing code style exactly.
  </action>
  <verify>flutter analyze lib/features/auth/presentation/view_models/auth_view_model.dart</verify>
  <done>
    - signInWithEmail returns early with error state on empty email or password
    - signUpWithEmail returns early with error state on empty email, password, or password < 6 chars
    - No analyzer warnings
  </done>
</task>

<task type="auto">
  <name>Add OAuth timeout timer to signInWithGoogle</name>
  <files>lib/features/auth/presentation/view_models/auth_view_model.dart</files>
  <action>
    1. Add two fields to AuthViewModel class (after existing `_authSubscription` field):
       - `Timer? _oauthTimeoutTimer;`
       - `static const _oauthTimeoutDuration = Duration(minutes: 3);`

    2. Update `signInWithGoogle()`:
       - After setting `AuthState.authenticating()`, cancel any existing timer
       - Start new Timer with `_oauthTimeoutDuration`
       - Timer callback: if state is still AuthStateAuthenticating, set AuthState.error('Sign in timed out...')
       - In catch block: cancel timer before setting error state

    3. Update `build()` dispose — change line 44 from:
       `ref.onDispose(() => _authSubscription?.cancel());`
       to:
       `ref.onDispose(() { _authSubscription?.cancel(); _oauthTimeoutTimer?.cancel(); });`

    4. Update auth state change listener — add `_oauthTimeoutTimer?.cancel();` as
       first line inside the listen callback (before the if/else block)

    DO NOT touch signInWithApple — it uses same OAuth listener pattern,
    timer cancellation in the listener covers both.
    DO NOT add Timer import — `dart:async` is already imported.
  </action>
  <verify>flutter analyze lib/features/auth/presentation/view_models/auth_view_model.dart</verify>
  <done>
    - Timer field and constant added
    - signInWithGoogle starts 3-minute timeout timer
    - Timer cancelled on: successful auth, error, dispose, any auth state change
    - No analyzer warnings
  </done>
</task>

<task type="auto">
  <name>Write unit tests for validation and timeout</name>
  <files>test/features/auth/presentation/view_models/auth_view_model_test.dart</files>
  <action>
    Add test cases to existing auth_view_model_test.dart (or create if not exists):

    Input validation tests:
    - 'signInWithEmail with empty email sets error state'
    - 'signInWithEmail with empty password sets error state'
    - 'signUpWithEmail with empty email sets error state'
    - 'signUpWithEmail with short password sets error state'
    - Verify: state is AuthState.error with correct message
    - Verify: authRepo methods are NOT called (no network request)

    OAuth timeout tests:
    - 'signInWithGoogle sets error after timeout' — use `fakeAsync` to advance time
    - 'signInWithGoogle cancels timer on auth state change'

    Use `mocktail` for mocking (project standard). Mock `AuthRepository`.
  </action>
  <verify>flutter test test/features/auth/presentation/view_models/auth_view_model_test.dart</verify>
  <done>
    - All 6+ test cases pass
    - No mock leaks (verify no unexpected interactions)
  </done>
</task>

## Success Criteria
- [ ] `flutter analyze` — 0 issues on auth_view_model.dart
- [ ] All new tests pass
- [ ] Empty email/password → error state, no network call
- [ ] OAuth stuck state → auto-recovers after 3 minutes
