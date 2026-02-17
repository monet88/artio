---
phase: 1
plan: 1
wave: 1
---

# Plan 1.1: Remove Login Wall — Router Redirect

## Objective
Modify `AuthViewModel.redirect()` so unauthenticated users can access the main shell routes (Home, Create, Settings) without being forced to `/login`. The Splash screen should redirect all users (logged in or not) to `/home`.

## Context
- `lib/features/auth/presentation/view_models/auth_view_model.dart` — `redirect()` method (lines 165-194)
- `lib/features/auth/presentation/state/auth_state.dart` — AuthState sealed class
- `lib/routing/app_router.dart` — GoRouter setup with refreshListenable
- `lib/routing/routes/app_routes.dart` — Route definitions (SplashRoute, LoginRoute, etc.)
- `.gsd/DECISIONS.md` — ADR-003: No anonymous auth, login required for generation

## Tasks

<task type="auto">
  <name>Modify AuthViewModel.redirect() to remove login wall</name>
  <files>lib/features/auth/presentation/view_models/auth_view_model.dart</files>
  <action>
    Replace the `redirect()` method (lines 165-194) with new logic:

    **Current behavior to REMOVE:**
    ```dart
    // This line forces login for ALL non-auth, non-splash routes — REMOVE IT
    if (!isLoggedIn && !isAuthRoute && currentPath != const SplashRoute().location) {
      return const LoginRoute().location;
    }
    ```

    **New redirect logic:**
    1. If `isAuthenticating` (initial or authenticating state) → return `null` (no redirect, let splash show)
    2. If on splash route → always redirect to `/home` (regardless of auth state)
    3. If logged in AND on auth route (login/register/forgot-password) → redirect to `/home`
    4. Otherwise → return `null` (allow navigation, no forced redirect)

    **What NOT to do:**
    - Do NOT change the `currentUser` getter
    - Do NOT add new AuthState variants
    - Do NOT modify `_checkAuthentication()`, `_handleSignedIn()`, or any sign-in methods
    - Do NOT remove the Listenable implementation or `_notifyRouter()`

    **Final redirect() code should be approximately:**
    ```dart
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
    ```
  </action>
  <verify>
    # Build check — no compile errors
    cd /Users/gold/workspace/artio && dart analyze lib/features/auth/presentation/view_models/auth_view_model.dart
  </verify>
  <done>
    - `redirect()` no longer returns `/login` for unauthenticated users on main routes
    - Splash route always redirects to `/home`
    - Logged-in users on auth routes still redirect to `/home`
    - File compiles without errors
  </done>
</task>

<task type="auto">
  <name>Add isLoggedIn convenience getter to AuthViewModel</name>
  <files>lib/features/auth/presentation/view_models/auth_view_model.dart</files>
  <action>
    Add a public getter `isLoggedIn` near the existing `currentUser` getter (around line 163).
    This will be used by Plan 1.2 for the auth gate and UI conditional logic.

    ```dart
    bool get isLoggedIn => state is AuthStateAuthenticated;
    ```

    **What NOT to do:**
    - Do NOT modify any existing methods
    - Do NOT rename `currentUser`
  </action>
  <verify>
    cd /Users/gold/workspace/artio && dart analyze lib/features/auth/presentation/view_models/auth_view_model.dart
  </verify>
  <done>
    - `isLoggedIn` getter exists on AuthViewModel
    - Returns true only when state is AuthStateAuthenticated
    - File compiles without errors
  </done>
</task>

<task type="auto">
  <name>Update existing redirect tests</name>
  <files>test/features/auth/presentation/view_models/auth_view_model_test.dart</files>
  <action>
    Check if there are any tests that assert the old redirect behavior (unauthenticated → /login).
    If found, update them to match new behavior:
    - Unauthenticated user on `/home` → should return `null` (no redirect)
    - Unauthenticated user on `/create` → should return `null`
    - Unauthenticated user on `/settings` → should return `null`
    - Splash route → should return `/home` regardless of auth state
    - Logged-in user on `/login` → should return `/home`

    Add new test cases for the updated redirect logic if not already covered.

    **What NOT to do:**
    - Do NOT modify tests for other methods (signIn, signUp, signOut, etc.)
    - Do NOT break existing passing tests for non-redirect behavior
  </action>
  <verify>
    cd /Users/gold/workspace/artio && dart test test/features/auth/presentation/view_models/auth_view_model_test.dart
  </verify>
  <done>
    - All redirect tests pass with new behavior
    - Test covers: unauthenticated on main routes returns null
    - Test covers: splash always redirects to /home
    - Test covers: logged-in on auth routes redirects to /home
    - No existing tests broken
  </done>
</task>

## Success Criteria
- [ ] Unauthenticated users can reach `/home`, `/create`, `/settings` without redirect
- [ ] Splash screen always redirects to `/home` (no login redirect for unauthenticated)
- [ ] Logged-in users on auth routes still redirect to `/home`
- [ ] `isLoggedIn` getter available on AuthViewModel
- [ ] `dart analyze` passes
- [ ] All auth_view_model tests pass
