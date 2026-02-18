---
phase: 7
plan: 1
wave: 1
---

# Plan 7.1: Critical Backend & Infrastructure Fixes

## Objective
Fix the 3 P1 issues that would cause silent production failures:
1. `revenuecat_app_user_id` is never written → webhook profile lookups always fail
2. RLS trigger uses wrong role detection → subscription columns unprotected
3. Webhook passes raw `appUserId` string as UUID → fragile + silent failures when no profile

## Context
- `.gsd/ROADMAP.md` — Phase 7 task list
- `lib/features/auth/data/repositories/auth_repository.dart` — RevenueCat login/logout
- `supabase/migrations/20260219000001_restrict_profiles_update_rls.sql` — RLS trigger
- `supabase/functions/revenuecat-webhook/index.ts` — webhook handler

## Tasks

<task type="auto">
  <name>Populate revenuecat_app_user_id in profiles during auth</name>
  <files>lib/features/auth/data/repositories/auth_repository.dart</files>
  <action>
    In `_revenuecatLogIn(String userId)`, after the successful `Purchases.logIn(userId)` call,
    update the profiles table to store the RevenueCat identity:

    ```dart
    await _supabase
        .from('profiles')
        .update({'revenuecat_app_user_id': userId})
        .eq('id', userId);
    ```

    This must be inside the existing try/catch block so errors remain non-blocking.
    The SupabaseClient is already available via `_supabase`.

    - Do NOT add a new import — SupabaseClient is already imported
    - Do NOT change the method signature or catch behavior
    - Keep the non-blocking semantics (errors logged, never thrown)
  </action>
  <verify>grep -n "revenuecat_app_user_id" lib/features/auth/data/repositories/auth_repository.dart</verify>
  <done>The profiles table is updated with `revenuecat_app_user_id = userId` on every RevenueCat login</done>
</task>

<task type="auto">
  <name>Fix RLS trigger to use Supabase JWT role claim</name>
  <files>supabase/migrations/20260219000001_restrict_profiles_update_rls.sql</files>
  <action>
    Replace line 13:
    ```sql
    IF current_setting('role') != 'service_role' THEN
    ```
    With:
    ```sql
    IF current_setting('request.jwt.claim.role', true) IS DISTINCT FROM 'service_role' THEN
    ```

    Why:
    - `current_setting('role')` returns the PostgreSQL session role (e.g., `authenticator`, `postgres`),
      NOT Supabase's API role. This means the trigger never matches `service_role` for API calls.
    - `current_setting('request.jwt.claim.role', true)` returns the role from the Supabase JWT.
    - `true` parameter = `missing_ok`, returns NULL instead of error during direct DB/migration connections.
    - `IS DISTINCT FROM` safely handles NULL (direct DB connections) — treats NULL as "not service_role"
      so protection still applies.

    - Do NOT change anything else in this file
    - Do NOT modify the trigger definition or column list
  </action>
  <verify>grep "request.jwt.claim.role" supabase/migrations/20260219000001_restrict_profiles_update_rls.sql</verify>
  <done>RLS trigger uses `request.jwt.claim.role` with `missing_ok=true` and `IS DISTINCT FROM`</done>
</task>

<task type="auto">
  <name>Fix webhook to use profile.id and early-return on missing profile</name>
  <files>supabase/functions/revenuecat-webhook/index.ts</files>
  <action>
    Two changes in the webhook handler:

    1. **Early-return when no profile found** (lines 74-78):
    Replace the warn-and-continue block with an early return:
    ```typescript
    if (!profile) {
        console.error(
            `[revenuecat-webhook] CRITICAL: app_user_id ${appUserId} not linked to any profile. Skipping.`
        );
        return new Response(JSON.stringify({ ok: true, skipped: true }), {
            status: 200,
            headers: { "Content-Type": "application/json" },
        });
    }
    ```
    Return 200 to prevent RevenueCat retries (we can't process events for unknown users).

    2. **Use `profile.id` instead of `appUserId` in all RPC calls**:
    After the profile check, add:
    ```typescript
    const userId = profile.id;
    ```
    Then replace ALL occurrences of `p_user_id: appUserId` with `p_user_id: userId`
    in the switch cases (INITIAL_PURCHASE, RENEWAL, EXPIRATION, PRODUCT_CHANGE).

    - Do NOT change the event type handling logic
    - Do NOT change the logging format (keep appUserId in logs for debugging)
    - Do NOT remove the existing auth header check
  </action>
  <verify>grep -n "p_user_id:" supabase/functions/revenuecat-webhook/index.ts | grep -v appUserId</verify>
  <done>All RPC calls use `profile.id` (UUID); missing profile returns 200 with `skipped: true`</done>
</task>

## Success Criteria
- [ ] `revenuecat_app_user_id` is written to profiles on RevenueCat login
- [ ] RLS trigger uses `request.jwt.claim.role` with safe NULL handling
- [ ] Webhook early-returns when profile not found (200 + skipped flag)
- [ ] All webhook RPC calls pass `profile.id` not raw `appUserId`
- [ ] `dart analyze` clean (0 errors)
- [ ] All existing tests pass
