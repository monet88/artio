---
phase: 2
plan: 1
wave: 1
---

# Plan 2.1: Auth & Template Resilience

## Objective
Detect and handle OAuth cancellation securely. Update password reset UX to not reveal email existence. Implement resilient parsing for Freezed template models.

## Context
- `lib/features/auth/presentation/screens/login_screen.dart`
- `lib/features/auth/presentation/screens/forgot_password_screen.dart`
- `lib/features/template_engine/data/repositories/template_repository_impl.dart` (or where templates are parsed)

## Tasks

<task type="auto">
  <name>Handle OAuth Cancellation</name>
  <files>
    lib/features/auth/data/repositories/auth_repository_impl.dart
    lib/features/auth/presentation/providers/auth_view_model.dart
  </files>
  <action>
    - Intercept `PlatformException` or specific Supabase cancellation errors during OAuth login.
    - Treat cancellation as a benign return (no error toast/snack) rather than an unhandled fault.
  </action>
  <verify>flutter analyze</verify>
  <done>OAuth cancellation returns smoothly without displaying an error to the user.</done>
</task>

<task type="auto">
  <name>Safe Password Reset Feedback</name>
  <files>
    lib/features/auth/presentation/providers/auth_view_model.dart
    lib/features/auth/presentation/screens/forgot_password_screen.dart
  </files>
  <action>
    - Change the forgot password success/error handling.
    - Regardless of whether the email exists in Supabase, return a generic success message: e.g., "If that email exists, a reset link has been sent."
    - Do not expose "User not found" errors to the UI.
  </action>
  <verify>flutter test test/features/auth/presentation/providers/auth_view_model_test.dart</verify>
  <done>Password reset attempts always show a safe, generic success message.</done>
</task>

<task type="auto">
  <name>Resilient Template Parsing</name>
  <files>lib/features/template_engine/data/repositories/template_repository_impl.dart</files>
  <action>
    - When parsing lists of templates (JSON), use a loop with try-catch for individual items rather than mapping the entire list blindly.
    - If one template fails to parse (e.g. missing required field), log the error and skip it, allowing the rest of the valid templates to render.
  </action>
  <verify>flutter analyze</verify>
  <done>A corrupted template JSON item does not break the entire template list display.</done>
</task>

## Success Criteria
- [ ] Canceling Google/Apple sign-in does not throw an ugly error UI.
- [ ] Password reset protects user enumeration.
- [ ] Bad template data is filtered out without crashing the template list.
