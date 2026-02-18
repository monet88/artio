---
phase: 1
plan: 2
wave: 2
---

# Plan 1.2: Auth Gate at Generate + UI Adjustments

## Objective
Add an auth gate that intercepts the "Generate" action for unauthenticated users (showing login/register prompt). Adjust Gallery and Settings UI to handle the unauthenticated state gracefully.

## Context
- `lib/features/create/presentation/create_screen.dart` — `_handleGenerate()` (lines 73-106)
- `lib/features/settings/presentation/settings_screen.dart` — Settings UI
- `lib/features/settings/presentation/widgets/user_profile_card.dart` — User profile section
- `lib/features/settings/presentation/widgets/settings_sections.dart` — Settings sections
- `lib/shared/widgets/main_shell.dart` — Bottom navigation bar with Gallery tab
- `lib/features/gallery/presentation/pages/gallery_page.dart` — Gallery page
- `lib/features/auth/presentation/view_models/auth_view_model.dart` — `isLoggedIn` getter (from Plan 1.1)

## Tasks

<task type="auto">
  <name>Improve auth gate in CreateScreen._handleGenerate()</name>
  <files>lib/features/create/presentation/create_screen.dart</files>
  <action>
    The `_handleGenerate()` method (lines 73-106) already has an auth check that shows a SnackBar
    when `userId == null`. Improve this to show a more prominent bottom sheet dialog instead
    of a dismissible SnackBar.

    Replace the SnackBar block (lines 82-93) with a bottom sheet that:
    1. Shows a title: "Sign in to create"
    2. Shows a brief message: "Create an account or sign in to start generating AI art"
    3. Has two buttons:
       - "Sign In" → navigates to `/login`
       - "Create Account" → navigates to `/register`
    4. Has a "Cancel" / close option

    Use `showModalBottomSheet` with the app's existing design system (AppSpacing, AppColors, etc.).

    **What NOT to do:**
    - Do NOT change the generation logic for authenticated users
    - Do NOT add credit checks (Phase 2)
    - Do NOT modify `_handleGenerate()` beyond the userId null check block
    - Do NOT create a separate widget file for this — keep it inline since it's small
  </action>
  <verify>
    cd /Users/gold/workspace/artio && dart analyze lib/features/create/presentation/create_screen.dart
  </verify>
  <done>
    - Tapping Generate when not logged in shows a bottom sheet (not SnackBar)
    - Bottom sheet has Sign In and Create Account buttons
    - Buttons navigate to /login and /register respectively
    - Authenticated user flow is unchanged
    - File compiles without errors
  </done>
</task>

<task type="auto">
  <name>Adjust Settings screen for unauthenticated users</name>
  <files>
    lib/features/settings/presentation/settings_screen.dart
    lib/features/settings/presentation/widgets/user_profile_card.dart
    lib/features/settings/presentation/widgets/settings_sections.dart
  </files>
  <action>
    Currently the Settings screen assumes the user is authenticated (shows email, reset password, logout).
    Modify it to handle unauthenticated state:

    **In settings_screen.dart:**
    1. Read auth state and check `isLoggedIn` using `ref.watch(authViewModelProvider)`
    2. If not logged in:
       - Pass `null` for email to the profile card
       - Hide "Reset Password" and "Logout" options
       - Show a "Sign In" button instead

    **In user_profile_card.dart:**
    1. Accept nullable `email` parameter (`String?`)
    2. When email is null → show "Guest" as display name and a "Sign In" button
    3. When email is present → show current behavior

    **In settings_sections.dart:**
    1. Accept a `bool isLoggedIn` parameter
    2. When not logged in → hide account-related sections (Reset Password, Logout)
    3. Keep theme toggle and app info visible for all users

    **What NOT to do:**
    - Do NOT remove any existing functionality for logged-in users
    - Do NOT add subscription-related UI (Phase 5)
    - Do NOT break the existing theme toggle or version display
  </action>
  <verify>
    cd /Users/gold/workspace/artio && dart analyze lib/features/settings/presentation/
  </verify>
  <done>
    - Settings screen works for both authenticated and unauthenticated users
    - Unauthenticated: shows "Guest" profile, "Sign In" button, theme toggle, app info
    - Authenticated: shows email, reset password, logout (same as before)
    - All files compile without errors
  </done>
</task>

<task type="auto">
  <name>Handle Gallery tab for unauthenticated users</name>
  <files>
    lib/features/gallery/presentation/pages/gallery_page.dart
    lib/shared/widgets/main_shell.dart
  </files>
  <action>
    Decide between two approaches (prefer Option A for simplicity):

    **Option A (Preferred): Show empty state with login prompt in GalleryPage**
    - In `gallery_page.dart`, check auth state at the top of `build()`
    - If not logged in → show a centered empty state with:
      - An icon (e.g., `Icons.photo_library_outlined`)
      - "Sign in to see your gallery"
      - "Your generated images will appear here"
      - A "Sign In" button → navigates to `/login`
    - If logged in → show existing gallery content (no changes)

    **Option B (Alternative): Hide Gallery tab entirely**
    - NOT recommended — changing NavigationBar destinations dynamically causes
      index shifting issues and is more complex

    **What NOT to do:**
    - Do NOT remove the Gallery tab from the NavigationBar
    - Do NOT change how photos are loaded for authenticated users
    - Do NOT add any credit-related UI
  </action>
  <verify>
    cd /Users/gold/workspace/artio && dart analyze lib/features/gallery/presentation/pages/gallery_page.dart
  </verify>
  <done>
    - Gallery page shows login prompt for unauthenticated users
    - Gallery page shows normal content for authenticated users
    - Gallery tab remains visible in navigation bar
    - File compiles without errors
  </done>
</task>

## Success Criteria
- [ ] Tapping Generate when not logged in shows auth gate bottom sheet (not SnackBar)
- [ ] Auth gate has Sign In and Create Account buttons
- [ ] Settings page works for unauthenticated users (Guest profile, Sign In button)
- [ ] Settings theme toggle works without login
- [ ] Gallery shows login prompt for unauthenticated users
- [ ] All `dart analyze` passes for modified files
- [ ] No regressions in authenticated user flows
