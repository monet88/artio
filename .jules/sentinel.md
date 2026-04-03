## 2024-04-03 - Revoke PUBLIC access on SECURITY DEFINER functions
**Vulnerability:** PostgreSQL automatically grants `EXECUTE` access to `PUBLIC` on newly created functions. For `SECURITY DEFINER` functions (which run as the creator, typically the `postgres` superuser in Supabase), this allows any user—even unauthenticated (`anon`) users—to invoke these functions. Several critical functions like `deduct_credits`, `refund_credits`, and `update_subscription_status` were vulnerable to this.
**Learning:** `REVOKE EXECUTE ON FUNCTION <name> FROM PUBLIC` is not sufficient on its own. Because `service_role` inherits from `PUBLIC`, revoking `PUBLIC` access also drops `service_role` access.
**Prevention:** Whenever creating `SECURITY DEFINER` functions in Supabase migrations, always pair them with:
1. `REVOKE EXECUTE ON FUNCTION <name> FROM PUBLIC;`
2. `GRANT EXECUTE ON FUNCTION <name> TO service_role;`
