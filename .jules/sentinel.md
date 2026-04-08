## 2024-04-04 - Missing REVOKE FROM PUBLIC on SECURITY DEFINER functions
**Vulnerability:** PostgreSQL automatically grants `EXECUTE` privileges to `PUBLIC` for all newly created functions. After hardening the credits and subscription RPCs, the signup trigger helper `public.handle_new_user()` was still left callable with elevated privileges because it never received the same explicit revoke/grant pair.
**Learning:** SECURITY DEFINER hardening has to cover internal trigger helpers too, not just RPC functions that are obviously exposed through application code.
**Prevention:** Add `REVOKE EXECUTE ON FUNCTION <name> FROM PUBLIC;` immediately after defining any `SECURITY DEFINER` function, then explicitly re-grant the exact role that still needs execution, such as `service_role`.

## 2024-04-03 - Revoke PUBLIC access on SECURITY DEFINER functions
**Vulnerability:** PostgreSQL automatically grants `EXECUTE` access to `PUBLIC` on newly created functions. For `SECURITY DEFINER` functions (which run as the creator, typically the `postgres` superuser in Supabase), this allows any user—even unauthenticated (`anon`) users—to invoke these functions. Several critical functions like `deduct_credits`, `refund_credits`, and `update_subscription_status` were vulnerable to this.
**Learning:** `REVOKE EXECUTE ON FUNCTION <name> FROM PUBLIC` is not sufficient on its own. Because `service_role` inherits from `PUBLIC`, revoking `PUBLIC` access also drops `service_role` access.
**Prevention:** Whenever creating `SECURITY DEFINER` functions in Supabase migrations, always pair them with:
1. `REVOKE EXECUTE ON FUNCTION <name> FROM PUBLIC;`
2. `GRANT EXECUTE ON FUNCTION <name> TO service_role;`

## 2024-04-02 - [Fix PUBLIC execute permission on update_subscription_status]
**Vulnerability:** The `update_subscription_status` PostgreSQL function was declared as `SECURITY DEFINER` without explicitly revoking `EXECUTE` privileges from the `PUBLIC` role. Because PostgreSQL grants execution rights to `PUBLIC` by default on new functions, any user (including anonymous) could potentially call this function to escalate their privileges (e.g. set their status to premium).
**Learning:** Even if a function is intended for internal use via RPC by edge functions running as `service_role`, explicitly revoking `PUBLIC` execution access is critical.
**Prevention:** Always explicitly revoke `EXECUTE` from `PUBLIC` and `authenticated` roles for all newly created `SECURITY DEFINER` functions, and explicitly grant it only to the necessary roles (e.g., `service_role`).

## 2024-04-08 - Information Disclosure (CWE-209) in Edge Functions
**Vulnerability:** Top-level catch blocks in edge functions like `reward-ad`, `delete-account`, and `generate-image` were passing `error.message` directly back to the client in HTTP 500 responses.
**Learning:** Returning unhandled exception messages directly in API responses can leak internal implementation details, such as SQL queries, dependency issues, or environment configurations, aiding attackers in further exploitation.
**Prevention:** Always log detailed errors internally (e.g., using `console.error`) and return generic error messages like "Internal server error" in 5xx responses.
