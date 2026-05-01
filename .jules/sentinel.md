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
## 2024-10-24 - Edge Function Information Leakage
**Vulnerability:** Edge Functions (`delete-account`, `generate-image`, `reward-ad`) were catching all exceptions and returning `error.message` in 500 error responses, potentially leaking stack traces or internal environment details to clients.
**Learning:** Returning raw Error messages in HTTP 500 responses is an information disclosure risk (CWE-209). While developers need this for debugging, clients should only receive a generic message.
**Prevention:** In top-level catch blocks of API handlers or Edge Functions, always log the detailed error internally (e.g., `console.error`) and return a generic error message (e.g., `"Internal server error"`) to the client.

## 2024-05-18 - Prevent Timing Attacks in Secret Validation
**Vulnerability:** A manual XOR loop in TypeScript was used to validate the `REVENUECAT_WEBHOOK_SECRET` in `revenuecat-webhook`. While logically correct, JIT compilers (like V8 used by Deno) can optimize such loops unpredictably, potentially breaking constant-time execution and allowing timing attacks.
**Learning:** Native cryptographic methods implemented in C++/Rust are necessary to guarantee timing safety in JS/TS environments. The Edge Runtime provides `timingSafeEqual` as a non-standard addition on `crypto.subtle`.
**Prevention:** Always use `(crypto.subtle as any).timingSafeEqual(a, b)` for secret validation in Supabase Edge Functions instead of manually implementing bitwise XOR loops. Ensure a prior length check (`a.length === b.length`) is made, as native `timingSafeEqual` typically requires equal-length buffers.

## 2024-10-25 - Explicit HTTP Method Validation in Edge Functions
**Vulnerability:** The `generate-image` Edge Function was missing explicit validation of the HTTP method (e.g., checking for `POST`). This could lead to unexpected behavior if a client sent a `GET` request, potentially triggering unhandled exceptions during JSON parsing and leaking internal errors.
**Learning:** All Supabase Edge Functions should explicitly validate the incoming HTTP request method early in their execution flow.
**Prevention:** Always include `if (req.method !== 'POST') { return new Response(JSON.stringify({ error: 'Method not allowed' }), { status: 405, headers: ... }); }` immediately after CORS handling in POST-only endpoints.
## 2024-05-15 - Missing HTTP Method Validation in Edge Function
**Vulnerability:** The `reward-ad` Edge Function did not validate the HTTP method (`req.method`) for its main actions (`request-nonce` and `claim`), allowing non-POST requests to execute potentially state-modifying logic.
**Learning:** Default unhandled methods in Supabase Edge Functions do not automatically reject unless explicitly checked, meaning endpoints intended for POST could be accessed via GET or other methods, increasing the risk of CSRF or unintended execution.
**Prevention:** Always explicitly validate the expected HTTP method (e.g., `if (req.method !== "POST")`) at the start of the handler and return a `405 Method Not Allowed` response if the condition is not met.

## 2024-10-25 - Prevent SSRF False Positives in URL Validation
**Vulnerability:** Mitigating Server-Side Request Forgery (SSRF) by validating `URL.hostname` using simple string prefixes (e.g., `host.startsWith("10.")`) can inadvertently block valid public domains (e.g., `10.example.com` or `127.my-domain.com`).
**Learning:** Hostname validation requires distinguishing between IP literals and fully qualified domain names (FQDNs) to avoid false positives.
**Prevention:** Always verify that the hostname is actually an IP-like structure (e.g., via regex `/^(\d{1,3}\.){3}\d{1,3}$/.test(host)` for IPv4 or checking for `:` for IPv6) before applying IP prefix blocklists.
