# TODOS

## Auth / Settings

**Title:** Add `settings_screen_test.dart` — dialog flow coverage
**Priority:** P2
**Context:** `_deleteAccount` confirmation dialog flow (show, cancel, confirm, loading,
snackbar on error) is untested. CLAUDE.md requires coverage for presentation layer.
Deferred from PR #85 to unblock store compliance.
**Scope:**
- Mount `SettingsScreen` with overridden `authViewModelProvider`
- Test: tap tile → dialog shown
- Test: Cancel → `deleteAccount()` NOT called
- Test: Confirm → loading set → `deleteAccount()` called → `unauthenticated`
- Test: Confirm + error → snackbar shows `AppExceptionMapper` message

---

**Title:** Add real `AuthRepository.deleteAccount()` unit tests
**Priority:** P2
**Context:** `auth_repository_test.dart` only tests the `IAuthRepository` mock contract.
The concrete `AuthRepository.deleteAccount()` implementation (FunctionException handling,
nested signOut try/catch, RevenueCat logout) has zero unit coverage.
**Scope:**
- Mock `SupabaseClient.functions.invoke()` to throw `FunctionException`
- Verify wraps to `AppException.auth` with correct message
- Verify signOut failure is non-blocking (Log.w, no throw)

---

**Title:** Extract `_showConfirmDialog` + dialog widget in `settings_screen.dart`
**Priority:** P3
**Context:** `_signOut` and `_deleteAccount` share identical dialog/loading/error pattern.
Extract shared helper to reduce duplication (~25 lines). Also: inline AlertDialog builders
violate CLAUDE.md "no private `_buildWidget`" rule.
**Scope:** Refactor both methods to use a shared `_showConfirmDialog` helper.

## Completed
