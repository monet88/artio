---
name: iap-revenuecat
description: >
  Complete In-App Purchase (IAP) setup guide using RevenueCat for Flutter/mobile apps.
  Covers Google Play Console, Google Cloud Console, RevenueCat dashboard, Supabase webhook,
  and Flutter SDK integration. Includes gotchas, 2024-2025 policy changes, and pre-check checklist.
  Updated 2026-03-16 with production-verified fixes: JWT ES256/HS256 mismatch, GPA token validation,
  verify-google-purchase fallback pattern, RC webhook Pub/Sub setup, webhook secret mismatch (Gotcha #17).
  RC auth raw token (no Bearer prefix), event.id null sandbox fallback (Gotcha #18).
  Date.now() idempotency fix (Gotcha #18 example corrected).
skills:
  - mobile-developer
  - backend-specialist
---

# IAP + RevenueCat Setup Skill

> **Last Updated:** 2026-03-16 (Production-verified v16 internal testing — RC webhook working, 4 events Sent, 820 credits. Gotcha #18 added: event.id null sandbox. Auth format corrected: raw token no Bearer prefix.)
> **Stack:** Flutter + RevenueCat + Google Play + Supabase Edge Functions

---

## 🗺️ Overview Architecture

```
Flutter App
  └── RevenueCat SDK (goog_xxx key)
        └── Google Play Billing
              └── Purchase success
                    ├── [Immediate] verify-google-purchase edge fn → update DB + grant credits
                    └── [Async]     RC server → RC Webhook → Supabase revenuecat-webhook fn
                                          ↑
                              Requires: Pub/Sub + RTDN configured correctly
```

> **Design principle:** `verify-google-purchase` = immediate fallback for UI feedback.
> `revenuecat-webhook` = authoritative source when RC pipeline is stable.

---

## ⚠️ CRITICAL GOTCHAS (Read FIRST)

### 1. API Access in Google Play Console REMOVED (2024+)
- **Old way:** Settings → API access → Link Google Cloud project
- **New way (2024+):** Go to **Users & Permissions → Invite new users** → paste service account email
- If you navigate to `/apiAccess` URL → redirects to home = permission issue or feature removed

### 2. Service Account Key Creation Disabled (Google Workspace)
- Google Workspace orgs + new projects auto-enforce `iam.disableServiceAccountKeyCreation`
- **Fix:** Use a personal `@gmail.com` account to create a NEW Google Cloud project
- Personal Gmail does not inherit org policies
- Then invite that service account email into Google Play Console

### 3. Package Name Must Match EXACTLY
- RevenueCat package name must match `applicationId` in `android/app/build.gradle.kts`
- The package name used during Google Play app creation is permanent — cannot change
- Common mistake: `com.company.app` vs `com.company.appname` — check carefully

### 4. Service Account Propagation Delay
- After inviting service account to Play Console → wait UP TO 24 HOURS
- RevenueCat will show "Credentials need attention" during this period → normal
- Do not delete and recreate — just wait

### 5. RevenueCat Key Types
- `goog_xxx` = Public (client-side) key for Flutter SDK
- Service Account JSON = Server credential for RevenueCat to verify purchases
- **Both are required** — different purpose

### 6. Webhook Auth Header Format + Secret Creation
- RevenueCat sends the Authorization header value **EXACTLY as you entered it in the dashboard** — NO automatic `Bearer ` prefix is added.
- Code must compare `authHeader` **directly** against `REVENUECAT_WEBHOOK_SECRET` (raw token, no prefix).
- ❌ WRONG: `const expectedAuth = \`Bearer \${REVENUECAT_WEBHOOK_SECRET}\`` — causes permanent 401 on ALL events.
- ✅ CORRECT: `const expectedAuth = REVENUECAT_WEBHOOK_SECRET;`
- Use timing-safe comparison to prevent timing attacks — see Gotcha #11 for the correct type-cast pattern (`crypto.subtle.timingSafeEqual` IS available in Supabase Edge Runtime).

**Where `REVENUECAT_WEBHOOK_SECRET` comes from:**
```
1. YOU generate a random secret (e.g., openssl rand -hex 32)
2. Enter it in RC Dashboard → Project Settings → Integrations → Webhooks → "Authorization header" field
   ⚠️ Enter ONLY the raw token — RC sends this value as-is as the Authorization header.
   Do NOT add "Bearer " in the dashboard field.
3. Set the SAME value in Supabase: supabase secrets set REVENUECAT_WEBHOOK_SECRET=<same-value>

⚠️ TWO PLACES must have IDENTICAL values. If set at different times → mismatch → ALL events 401.
See Gotcha #17 for how to diagnose and fix mismatch.
```

### 7. AAB Rebuild Required After .env Changes
- `.env` files are Flutter assets → bundled into APK/AAB
- Changing any key in `.env.*` requires full rebuild + new upload to Play Store

### 8. 🆕 JWT Algorithm Mismatch: ES256 vs HS256 (PRODUCTION BUG)
> **Root cause confirmed in production (2026-03-12)**

**Problem:** Supabase Edge Functions deployed with default `verify_jwt=true` will **reject** all Flutter app JWTs with `{"code":401,"message":"Invalid JWT"}`.

**Why:** GoTrue v2 (Supabase auth) issues JWTs signed with **ES256** (asymmetric). The Supabase API gateway's built-in JWT verification checks for **HS256** (symmetric with `JWT_SECRET`). Algorithm mismatch → every request rejected.

**Symptom:** Flutter app calls edge function → gets `FunctionException` silently swallowed → edge function never runs → no DB updates, no credits.

**Fix:** Deploy ALL edge functions with `--no-verify-jwt` flag and implement JWT auth manually inside:
```bash
# CORRECT deployment:
supabase functions deploy YOUR-FUNCTION --no-verify-jwt --project-ref YOUR_REF

# WRONG (default) — will reject Flutter app JWTs:
supabase functions deploy YOUR-FUNCTION  # implicitly --verify-jwt=true
```

**Manual JWT auth pattern (inside edge function):**
```typescript
const authHeader = req.headers.get("Authorization");
if (!authHeader) return new Response(JSON.stringify({ error: "Missing authorization" }), { status: 401 });

const userClient = createClient(SUPABASE_URL, Deno.env.get("SUPABASE_ANON_KEY")!, {
  auth: { persistSession: false },
  global: { headers: { Authorization: authHeader } },
});
const { data: { user }, error } = await userClient.auth.getUser();
if (error || !user) return new Response(JSON.stringify({ error: "Unauthorized" }), { status: 401 });
```

### 9. 🆕 StoreTransaction.transactionIdentifier = orderId, NOT purchaseToken
> **Confirmed in purchases_flutter 9.x (Android)**

- `result.storeTransaction.transactionIdentifier` = Google Play **orderId** (`GPA.xxxx-xxxx-xxxx-xxxxx`)
- This is NOT the `purchaseToken` required by Google Play Developer API
- Consequence: Cannot call `/androidpublisher/v3/.../purchases/subscriptions/{id}/tokens/{token}` from Supabase — you don't have the real token
- **Design decision:** Trust RC client-side validation. Use orderId as idempotency key only.
- orderId can be **empty** for subscriptions with free trials → skip `verify-google-purchase` if orderId is empty (RC webhook handles credit grant)

### 11. 🔄 UPDATED: `crypto.subtle.timingSafeEqual` IS Available in Deno (Type Cast Required)

**Previous warning was wrong.** `crypto.subtle.timingSafeEqual` IS available in Supabase Edge Runtime
(Deno-based) but the TypeScript type definitions don't include it. Use a type cast:

```typescript
const authValid = (
  crypto.subtle as unknown as {
    timingSafeEqual(a: BufferSource, b: BufferSource): boolean;
  }
).timingSafeEqual(encoder.encode(authHeader), encoder.encode(expected));
```

This works correctly in production. The manual XOR approach also works but is unnecessary.

---

### 12. 🆕 signUp Race Condition — `revenuecat_app_user_id` = NULL for New Users
> **Root cause confirmed in production (2026-03-14)**

**Problem:** Calling `_revenuecatLogIn()` (which UPDATEs `profiles.revenuecat_app_user_id`) BEFORE `_createUserProfile()` (which INSERTs the profile row) → UPDATE matches 0 rows → silent fail → `revenuecat_app_user_id` stays NULL → RC webhook lookup fails → webhook returns 500 → RC retries forever.

**Wrong order:**
```dart
await _revenuecatLogIn(response.user!.id);   // UPDATE runs — 0 rows exist yet
await _createUserProfile(response.user!.id, email);  // INSERT — rc_id not set
```

**Fix — INSERT first, then UPDATE:**
```dart
// 1. Create profile first
await _createUserProfile(response.user!.id, email);
// 2. Then link RC (UPDATE now finds the row)
await _revenuecatLogIn(response.user!.id);
```

**Belt-and-suspenders: also include `revenuecat_app_user_id` in the INSERT itself:**
```dart
await _supabase.from('profiles').insert({
  'id': userId,
  'email': email,
  'is_premium': false,
  'revenuecat_app_user_id': userId,  // ← set immediately, don't rely on UPDATE
  'created_at': DateTime.now().toIso8601String(),
});
```
Same fix applies to `fetchOrCreateProfile` for Google/Apple OAuth users.

---

### 13. 🆕 `p_tier: null` Writes NULL to DB — Pass `'free'` Explicitly
> **Confirmed in production (2026-03-14)**

**Problem:** `update_subscription_status` RPC does `SET subscription_tier = p_tier`. If you pass `p_tier: null`, the column is set to NULL — the column default `'free'` only applies on INSERT, not UPDATE.

**Wrong:**
```typescript
await supabase.rpc("update_subscription_status", {
  p_user_id: userId,
  p_is_premium: false,
  p_tier: null,       // ← writes NULL, not 'free'
  p_expires_at: null,
});
```

**Fix:**
```typescript
p_tier: "free",   // explicit string, not null
```
Always pass `"free"` for EXPIRATION and downgrade events.

---

### 14. 🆕 Module-Level Throws Cause BOOT_ERROR (503) on Every Request
> **Confirmed in production (2026-03-14)**

**Problem:** Throwing an error at module initialization level (outside `Deno.serve()`) causes the entire edge function to fail to start. Every subsequent request gets `503 Service Unavailable` with body `{"code":"BOOT_ERROR"}`.

**Wrong:**
```typescript
const RC_PROJECT_ID = Deno.env.get("REVENUECAT_PROJECT_ID");
if (!RC_PROJECT_ID) throw new Error("REVENUECAT_PROJECT_ID env var is required");
// ↑ This runs at import time → BOOT_ERROR on every request
```

**Fix — validate inside the handler:**
```typescript
Deno.serve(async (req) => {
  const RC_PROJECT_ID = Deno.env.get("REVENUECAT_PROJECT_ID");
  if (!RC_PROJECT_ID) {
    console.error("REVENUECAT_PROJECT_ID not set");
    return new Response(JSON.stringify({ error: "Server misconfigured" }), { status: 500 });
  }
  // ... rest of handler
});
```

**Required secret for sync-subscription:**
```bash
supabase secrets set REVENUECAT_PROJECT_ID=<your-rc-project-id> --project-ref YOUR_REF
# Find project ID in RC Dashboard URL: app.revenuecat.com/projects/<PROJECT_ID>/...
```

---

### 15. 🆕 Supabase Migrations Do NOT Auto-Deploy to Production

**Problem:** Running `supabase db push` locally or merging a PR does NOT automatically apply
migrations to the remote Supabase project. The migration exists in `supabase/migrations/` but
the production DB function signature stays old.

**Symptom:** Edge function calls RPC with new parameters → PostgREST returns
`"Could not find the function public.X with parameters..."` → function returns 500 → RC retries.

**Fix:** After any migration, explicitly apply to production:
```bash
SUPABASE_ACCESS_TOKEN=<token>
# Option A: via Management API (no Docker needed)
curl -s -X POST "https://api.supabase.com/v1/projects/<ref>/database/query" \
  -H "Authorization: Bearer $SUPABASE_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"query\": \"<migration SQL here>\"}"

# Option B: via CLI (requires Docker)
supabase db push --project-ref <ref>
```

**Always verify** after applying:
```bash
curl -s "https://<ref>.supabase.co/rest/v1/rpc/grant_subscription_credits" \
  -X POST -H "apikey: <service_role_key>" \
  -d '{"p_user_id":"...","p_amount":1,"p_description":"test","p_reference_id":"test","p_check_recent_grant":false}'
# Expected: FK error (not "function not found") = signature correct
```

---

### 16. 🆕 RC Webhook "Retrying" Loop — Check Migration Applied to Production

**Symptom:** RevenueCat dashboard shows webhook events stuck in "Retrying" status.
Supabase Edge Function logs show 500 responses.

**Root cause pattern:** Edge function code was updated to call RPC with new parameters
(e.g. `p_check_recent_grant`), but the migration that adds those parameters was never
applied to the production DB → RPC call fails → 500 → RC retries every few minutes.

**Debug checklist:**
1. RC Dashboard → Integrations → Webhooks → expand a failing event → check response body
2. If response is `"Could not find the function public.X with parameters..."` → migration not applied
3. Apply migration (see Gotcha #15)
4. Redeploy the edge function: `supabase functions deploy revenuecat-webhook --no-verify-jwt --project-ref <ref>`
5. RC Dashboard → click "Retry" on failing events → confirm they now succeed (no new "Retrying")

**Note:** RC Pub/Sub pipeline being connected (transactions visible in RC dashboard) does NOT
mean webhooks work — the pipeline can be connected but webhooks still fail if the edge function returns 5xx.

---

### 17. 🆕 RC Webhook All Events Return 401 — Secret Mismatch Between RC Dashboard and Supabase

> **Root cause confirmed in production (2026-03-15)**

**Symptom:** ALL RC webhook events show "Failure" in RC Dashboard (not "Retrying").
No credits granted. No subscription updates. Edge function responds 401 to every request.

**Why "Failure" not "Retrying":**
- RC retries only on **5xx** responses (server errors)
- RC marks **4xx** as permanent failure — no retry
- Secret mismatch → 401 (Unauthorized) → RC gives up immediately

**Root cause:** `REVENUECAT_WEBHOOK_SECRET` set in Supabase has a **different value** than
the Authorization token configured in RC Dashboard. They were set at different times with
different random values and nobody noticed the mismatch.

**This secret has TWO sources you must keep in sync:**
```
SOURCE 1: RC Dashboard → Project Settings → Integrations → Webhooks → Authorization header
           (value RC sends in every request)

SOURCE 2: Supabase → supabase secrets set REVENUECAT_WEBHOOK_SECRET=<value>
           (value edge function reads via Deno.env.get("REVENUECAT_WEBHOOK_SECRET"))

MUST BE IDENTICAL. Set them together in one session. Never set one without updating the other.
```

**How to generate the secret:**
```bash
# Generate a secure random secret (do this ONCE, copy to both places)
openssl rand -hex 32
# Example output: 67b6cd6c03af0394e543f7e8b88771b27e8dbce368e42d664d6f9863d964273e
```

**How to diagnose secret mismatch:**
```bash
# Test webhook with the raw secret value (NO Bearer prefix — RC sends raw token as-is)
curl -s -w "\nHTTP: %{http_code}" \
  "https://<ref>.supabase.co/functions/v1/revenuecat-webhook" \
  -H "Content-Type: application/json" \
  -H "Authorization: <supabase-secret-value>" \
  -d '{"event":{"type":"RENEWAL","id":"test-001","app_user_id":"<rc-app-user-id>","product_id":"<product-id>"}}' \
  -X POST

# Expected results:
# HTTP 500 "User not linked" → auth PASSED (secret correct, user just not in DB) ✅
# HTTP 200               → auth PASSED and event processed ✅
# HTTP 401               → auth FAILED → secret mismatch → fix it
```

**Fix:**
```bash
# Option A: Update Supabase to match RC Dashboard (look up RC value in dashboard)
curl -s -X POST "https://api.supabase.com/v1/projects/<ref>/secrets" \
  -H "Authorization: Bearer $SUPABASE_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '[{"name":"REVENUECAT_WEBHOOK_SECRET","value":"<rc-dashboard-value>"}]'

# Option B: Generate new secret, update BOTH places
NEW_SECRET=$(openssl rand -hex 32)
# 1. Update RC Dashboard webhook Authorization field → paste $NEW_SECRET
# 2. Update Supabase:
supabase secrets set REVENUECAT_WEBHOOK_SECRET=$NEW_SECRET --project-ref <ref>
```

**Verify fix with E2E test:**
```bash
# After fixing, trigger a test event and confirm credits granted
curl -s "https://<ref>.supabase.co/rest/v1/credit_transactions?reference_id=eq.test-001" \
  -H "apikey: $ANON_KEY" -H "Authorization: Bearer $SERVICE_KEY"
# Should return the transaction → webhook processed successfully
```

---

### 18. 🆕 RC Sandbox `event.id` Is Null → `p_reference_id` NULL → DB Exception → 500 Loop

> **Root cause confirmed in production (2026-03-15)**

**Symptom:** RC sandbox RENEWAL/INITIAL_PURCHASE events return 500 "Retrying" immediately.
Logs show: `grant_subscription_credits error: ERROR: p_reference_id cannot be null`.

**Why:** The `grant_subscription_credits` RPC has a guard: `IF p_reference_id IS NULL THEN RAISE EXCEPTION`.
RC sandbox events sometimes omit the `event.id` field (or send it as null). The webhook code uses
`event.id` as `p_reference_id` — when null → exception → 500 → RC retries forever.

**Production vs Sandbox:**
- Production RC events: always include `id` (UUID like `00BE64D3-...`)
- Sandbox RC events: may omit `id` field or include it inconsistently

**Fix:** Add fallback chain for `eventId` in the webhook handler:
```typescript
const eventId: string =
  event.id ??
  event.transaction_id ??                                    // GPA.xxx on Android
  `${appUserId}-${eventType}-${event.event_timestamp_ms ?? "no-timestamp"}`;
```

This ensures `p_reference_id` is NEVER null while staying idempotent across RC retries.
⚠️ Do NOT use `Date.now()` as last resort — it changes on every retry, producing a different
`reference_id` each time and breaking deduplication (same event retried → duplicate credit grant).

---

### 19. 🆕 Unexpected `grantResult` Shape Must Return 500 — Never Fall Through to 200

> **Root cause confirmed in production (2026-03-17)**

**Problem:** `grant_subscription_credits` RPC occasionally returns an unrecognized shape
(neither `{granted: true}` nor `{granted: false, reason: "..."}`) due to schema changes
or edge cases. If the code falls through to return 200, RevenueCat sees success and stops
retrying. The user gets no credits and no automatic recovery.
**This rule applies to every caller of `grant_subscription_credits`** — including `revenuecat-webhook`.

**Wrong — silent credit loss:**
```typescript
} else {
  console.warn("[verify-google-purchase] Unexpected grantResult:", grantResult);
  // falls through to 200 response — RC thinks it succeeded, stops retrying
}
return new Response(JSON.stringify({ verified: true }), { status: 200 });
```

**Fix — return 500 so RC retries and ops are alerted:**
```typescript
} else {
  console.error(
    "[verify-google-purchase] Unexpected grantResult shape:",
    JSON.stringify(grantResult),
  );
  return new Response(
    JSON.stringify({ error: "Internal error: unexpected grant result" }),
    { status: 500, headers: { ...corsHeaders(), "Content-Type": "application/json" } },
  );
}
```

**Why 500 (not 400 or 422):** RevenueCat retries on **5xx** responses (server error = transient).
4xx = permanent failure, no retry. Returning 500 here keeps the retry loop alive until ops can investigate.

**Debug:** Check Supabase Edge Function logs for `Unexpected grantResult shape:` entries.
If seen in production, inspect the RPC's return value — likely a DB migration added a new field
or changed the response structure.

---

### 10. 🆕 RC Webhook Requires Pub/Sub — Not Just Webhook URL
Setting webhook URL in RC Dashboard is NOT enough for Google Play events to reach your server.

**Full RTDN pipeline required:**
```
Google Play → Cloud Pub/Sub topic → RC subscribes → RC processes → RC fires your webhook
```

**Setup steps:**
1. Google Cloud Console → Enable Cloud Pub/Sub API
2. Create topic: `projects/{project-id}/topics/{topic-name}`
3. Grant service account Pub/Sub Admin at project level
4. RC Dashboard → Play Store → Real-time developer notifications → paste topic name
5. Google Play Console → Monetization setup → paste same topic name → Send test notification
6. Verify RC Dashboard shows "Connected to Google ✅"

**Common failure:** RC Dashboard shows topic configured but "No notifications received" → Pub/Sub subscription created by RC hasn't activated yet. Wait 15-30 min after initial setup.

---

## 📋 Step-by-Step Setup (2024-2026)

### PHASE 1: Google Play Console

#### 1.1 Create app
- Application ID (package name) — set once, cannot change
- Upload first AAB → must be **release-signed** (not debug)
- Create release keystore: `keytool -genkey -v -keystore app.jks -keyalg RSA -keysize 2048 -validity 10000`

#### 1.2 Create Subscription Products
- Monetize → Subscriptions → Create subscription
- ID format: `appname_tier_period` (e.g., `artio_pro_monthly`)
- Add base plan → set billing period → add pricing
- Status must be **Active** before RevenueCat can fetch

#### 1.3 Internal Testing Track
- Testing → Internal testing → Create release → Upload AAB
- Add tester emails
- Add test Gmail to **Settings → License testing** (critical for sandbox purchases!)

---

### PHASE 2: Google Cloud Console + Service Account

#### 2.1 Create Google Cloud Project
```
# Use personal @gmail.com account (avoids Workspace org policy restrictions)
1. console.cloud.google.com → New Project → name: "appname-revenuecat"
2. APIs & Services → Enable → "Google Play Android Developer API"
3. APIs & Services → Enable → "Cloud Pub/Sub API"  ← Required for RC RTDN
```

#### 2.2 Create Service Account
```
IAM & Admin → Service Accounts → Create service account
  Name: revenuecat-appname
  Role: Pub/Sub Admin  ← Required for RC to create Pub/Sub subscriptions
  → Create and continue → Done
```

#### 2.3 Download JSON Key
```
Click service account → Keys tab → Add Key → Create new key → JSON
→ Download file (keep safe, never commit to git!)
```

**If "Key creation disabled" error:**
```bash
# Via gcloud CLI:
gcloud iam service-accounts keys create ./service-account.json \
  --iam-account=SERVICE_ACCOUNT_EMAIL \
  --project=PROJECT_ID

# Or override org policy (if you own the project):
# IAM & Admin → Organization Policies → iam.disableServiceAccountKeyCreation
# → Override parent → Set enforcement: OFF → Save
```

---

### PHASE 3: Link Service Account to Play Console

**2024+ method (API access page removed):**
```
Google Play Console → Users and permissions → Invite new users
  Email: service-account-name@project-id.iam.gserviceaccount.com
  Permissions:
    ✅ View financial data, orders, and cancellation survey responses
    ✅ Manage orders and subscriptions
→ Invite user → Done
```

> Note: Takes up to 24h to propagate

---

### PHASE 4: RevenueCat Dashboard

#### 4.1 App Setup
```
app.revenuecat.com → New App → Android (Play Store)
  App name: [Your App Name]
  Google Play package name: com.your.app  ← MUST match build.gradle applicationId
  Service Account Credentials JSON: upload file from Phase 2.3
```

#### 4.2 Connect Real-Time Developer Notifications (RTDN)
```
RC Dashboard → App → Google Play → Real-time developer notifications
  Topic: projects/{project-id}/topics/{topic-name}
  → Save → Status should show "Connected to Google ✅"
```

Then in Google Play Console:
```
Monetize → Monetization setup → Real-time developer notifications
  Topic name: projects/{project-id}/topics/{topic-name}  ← same topic
  → Send test notification → verify RC Dashboard notification counter increases
```

#### 4.3 Products
```
Product catalog → Products → Import Products (button)
  If import fails (credentials not active yet):
    → New product manually:
    Display name: Artio Pro Monthly
    Product type: Subscription
    Subscription: artio_pro_monthly  ← Google Play subscription ID
    Base plan Id: artio-pro-monthly  ← Base plan ID from Google Play
    Backwards compatible: ✅
```

#### 4.4 Entitlements
```
Product catalog → Entitlements → + New
  pro:   attach artio_pro_monthly, artio_pro_yearly
  ultra: attach artio_ultra_monthly, artio_ultra_yearly
```

#### 4.5 Offerings — mark one as "Current"
```
Product catalog → Offerings → default → Packages tab
  Monthly:       $rc_monthly     → link Pro Monthly product
  Yearly:        $rc_annual      → link Pro Yearly product
  Ultra Monthly: (custom)        → link Ultra Monthly product

  ⚠️ Mark one offering as "Current" — Purchases.getOfferings().current returns null otherwise!
```

#### 4.6 API Keys
```
RevenueCat → Project settings → API Keys
  Android: goog_xxxxxxxxxxxx  → add to .env as REVENUECAT_GOOGLE_KEY
  iOS:     appl_xxxxxxxxxxxx  → add to .env as REVENUECAT_APPLE_KEY
```

---

### PHASE 5: Supabase Edge Functions

#### 5.1 verify-google-purchase (immediate fallback)
Called by app right after `Purchases.purchase()` succeeds. Grants credits immediately without waiting for RC webhook.

```typescript
// supabase/functions/verify-google-purchase/index.ts
// Deploy: supabase functions deploy verify-google-purchase --no-verify-jwt
import { corsHeaders, handleCorsIfPreflight } from "../_shared/cors.ts";

/** Map product ID → tier + credits */
function getTierInfo(productId: string): { tier: string; credits: number } | null {
  if (productId.startsWith("appname_ultra_")) return { tier: "ultra", credits: 500 };
  if (productId.startsWith("appname_pro_"))  return { tier: "pro",   credits: 200 };
  return null;
}

/**
 * 🔒 SECURITY: Accepts ONLY real Google Play order IDs (GPA.XXXX-XXXX-XXXX-XXXXX).
 * Do NOT add timestamp-based fallbacks — forgeable by any authenticated user.
 */
function isValidPurchaseToken(token: string): boolean {
  return /^GPA\.\d{4}-\d{4}-\d{4}-\d+$/.test(token);
}

Deno.serve(async (req) => {
  // Handle CORS preflight before anything else
  const preflight = handleCorsIfPreflight(req);
  if (preflight) return preflight;

  // ... auth check (see Gotcha #8) ...

  // Validate token format BEFORE any DB writes
  if (!isValidPurchaseToken(purchaseToken)) {
    console.warn(`[verify-google-purchase] Invalid token: "${purchaseToken}" user=${user.id}`);
    return new Response(JSON.stringify({ error: "Invalid purchaseToken format" }), {
      status: 400,
      headers: { ...corsHeaders(), "Content-Type": "application/json" },
    });
  }

  // NOTE: update_subscription_status intentionally omitted.
  // productId is client-supplied → setting tier here before RC webhook verification
  // allows tier escalation (user claims ultra credits with a pro token).
  // The RC webhook fires within seconds and sets the authoritative tier + expiry.

  // Grant credits — idempotent via reference_id.
  // p_check_recent_grant=true runs the 25-day guard inside the RPC under
  // pg_advisory_xact_lock — eliminates TOCTOU race with revenuecat-webhook.
  const referenceId = `gp-${purchaseToken}`;
  const { data: grantResult, error: creditErr } = await supabase.rpc("grant_subscription_credits", {
    p_user_id: user.id,
    p_amount: tierInfo.credits,
    p_description: `${tierInfo.tier} subscription — Google Play purchase`,
    p_reference_id: referenceId,
    p_check_recent_grant: true,
  });

  if (creditErr) {
    console.error("[verify-google-purchase] grant_subscription_credits error:", creditErr);
    return new Response(JSON.stringify({ error: "Failed to grant subscription credits" }), {
      status: 500,
      headers: { ...corsHeaders(), "Content-Type": "application/json" },
    });
  }

  // Handle grantResult shapes (see Gotcha #19 for unexpected shape handling)
  // ...

  return new Response(JSON.stringify({ verified: true, tier: tierInfo.tier }), {
    status: 200,
    headers: { ...corsHeaders(), "Content-Type": "application/json" },
  });
});
```

**Current state:** `update_subscription_status` has been removed. `grant_subscription_credits` now uses `p_check_recent_grant: true` for atomic double-grant prevention. When RC webhook is confirmed stable, `grant_subscription_credits` can also be removed — leaving this function as a no-op fast-path that just validates the token format.

#### 5.2 revenuecat-webhook (authoritative)
```typescript
// supabase/functions/revenuecat-webhook/index.ts
// Deploy: supabase functions deploy revenuecat-webhook --no-verify-jwt

// Verify RC webhook signature using constant-time comparison (Gotcha #6 + #11)
// RC sends Authorization header = raw token, NO "Bearer " prefix
const authHeader = req.headers.get("Authorization");
const expectedAuth = REVENUECAT_WEBHOOK_SECRET;  // raw token — no Bearer prefix (Gotcha #6)
// timingSafeEqual IS available in Deno via type cast (Gotcha #11)
const encoder = new TextEncoder();
const authValid = authHeader !== null && (
  crypto.subtle as unknown as { timingSafeEqual(a: BufferSource, b: BufferSource): boolean }
).timingSafeEqual(encoder.encode(authHeader), encoder.encode(expectedAuth));

// Handle event
const event = await req.json();
switch (event.type) {
  case "INITIAL_PURCHASE":
  case "RENEWAL":
    await supabase.rpc("update_subscription_status", { p_is_premium: true, ... });
    await supabase.rpc("grant_subscription_credits", {
      p_reference_id: event.id,  // RC event UUID (NOT gp- prefix — different from verify-google-purchase)
      ...
    });
    break;
  case "CANCELLATION":
  case "EXPIRATION":
    await supabase.rpc("update_subscription_status", { p_is_premium: false, ... });
    break;
}
```

**⚠️ Double-grant risk:** `verify-google-purchase` uses `gp-{orderId}` as reference_id. RC webhook uses `event.id` (UUID). These are different → `ON CONFLICT(reference_id)` will NOT dedup between them. A user who purchases gets credits from BOTH if both fire. Until RC webhook is verified stable, keep verify-google-purchase as sole credit granter.

#### 5.3 sync-subscription (status sync, no credits)
```typescript
// Called after purchase/restore to sync RC entitlements → Supabase
// IMPORTANT: Must NOT grant credits here (double-grant risk)
// Only calls update_subscription_status, never grant_subscription_credits

// Guard: if RC returns 0 entitlements → do NOT downgrade user
if (activeEntitlements.length === 0) {
  return { synced: false, reason: "no_active_entitlements" };
}
```

#### 5.4 Deploy all functions with --no-verify-jwt
```bash
# MUST use --no-verify-jwt for all functions called by Flutter app
supabase functions deploy verify-google-purchase --no-verify-jwt --project-ref YOUR_REF
supabase functions deploy sync-subscription      --no-verify-jwt --project-ref YOUR_REF
supabase functions deploy revenuecat-webhook     --no-verify-jwt --project-ref YOUR_REF
```

#### 5.5 Set required secrets
```bash
supabase secrets set REVENUECAT_WEBHOOK_SECRET=YOUR_SECRET --project-ref YOUR_REF
# SUPABASE_SERVICE_ROLE_KEY is auto-injected by Supabase, no need to set manually
```

---

### PHASE 6: Database Setup

#### 6.1 Required tables
```sql
-- Subscription status on user profile
ALTER TABLE profiles ADD COLUMN is_premium BOOLEAN DEFAULT FALSE;
ALTER TABLE profiles ADD COLUMN subscription_tier TEXT;  -- 'pro', 'ultra', etc.
ALTER TABLE profiles ADD COLUMN premium_expires_at TIMESTAMPTZ;

-- Credits balance
CREATE TABLE user_credits (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id),
  balance INTEGER NOT NULL DEFAULT 0 CHECK (balance >= 0)
);

-- Credit transaction log with idempotency
CREATE TABLE credit_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  amount INTEGER NOT NULL,
  description TEXT,
  reference_id TEXT,  -- idempotency key
  created_at TIMESTAMPTZ DEFAULT now()
);
CREATE UNIQUE INDEX credit_transactions_reference_id_idx
  ON credit_transactions(reference_id) WHERE reference_id IS NOT NULL;
```

#### 6.2 Required RPC functions
```sql
-- grant_subscription_credits: atomic, idempotent
CREATE OR REPLACE FUNCTION grant_subscription_credits(
  p_user_id UUID, p_amount INTEGER, p_description TEXT, p_reference_id TEXT
) RETURNS VOID AS $$
BEGIN
  PERFORM pg_advisory_xact_lock(hashtext(p_user_id::text));
  INSERT INTO credit_transactions(user_id, amount, description, reference_id)
  VALUES (p_user_id, p_amount, p_description, p_reference_id)
  ON CONFLICT (reference_id) WHERE reference_id IS NOT NULL DO NOTHING;

  IF FOUND THEN
    INSERT INTO user_credits(user_id, balance) VALUES (p_user_id, p_amount)
    ON CONFLICT (user_id) DO UPDATE SET balance = user_credits.balance + p_amount;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- update_subscription_status
CREATE OR REPLACE FUNCTION update_subscription_status(
  p_user_id UUID, p_is_premium BOOLEAN, p_tier TEXT, p_expires_at TIMESTAMPTZ
) RETURNS VOID AS $$
BEGIN
  UPDATE profiles SET
    is_premium = p_is_premium,
    subscription_tier = p_tier,
    premium_expires_at = p_expires_at,
    updated_at = now()
  WHERE id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;
```

---

### PHASE 7: Flutter SDK Integration

#### 7.1 pubspec.yaml
```yaml
dependencies:
  purchases_flutter: ^9.x.x
```

#### 7.2 Initialize (guard for non-web)
```dart
// main.dart — guard with !kIsWeb (RC doesn't support web)
if (!kIsWeb) {
  await Purchases.setLogLevel(LogLevel.debug);
  await Purchases.configure(
    PurchasesConfiguration(EnvConfig.revenuecatGoogleKey)
      ..appUserID = supabaseUser.id,  // Use auth user ID for cross-device sync
  );
}
```

#### 7.3 Purchase flow with verify-google-purchase fallback
```dart
Future<SubscriptionStatus> purchase(SubscriptionPackage package) async {
  final nativePkg = package.nativePackage as Package;
  final result = await Purchases.purchase(PurchaseParams.package(nativePkg));

  // Extract orderId — may be empty for free-trial subscriptions
  final orderId = result.storeTransaction.transactionIdentifier;
  final productId = package.identifier;
  // If orderId is empty (e.g. free trial), skip verify-google-purchase.
  // The revenuecat-webhook fires within seconds and grants credits authoritatively.
  if (orderId.isEmpty) return _mapCustomerInfo(result.customerInfo);
  final purchaseToken = orderId;

  // Call verify-google-purchase — non-blocking, don't await in critical path
  await _verifyWithServer(purchaseToken, productId);

  return _mapCustomerInfo(result.customerInfo);
}

/// Non-blocking: errors logged but never thrown (don't break purchase flow)
Future<void> _verifyWithServer(String purchaseToken, String productId) async {
  try {
    final response = await Supabase.instance.client.functions.invoke(
      'verify-google-purchase',
      body: {'purchaseToken': purchaseToken, 'productId': productId},
    );
    final body = response.data as Map<String, dynamic>?;
    if (body?['verified'] == true) {
      Log.i('[RC] verify OK: tier=${body?['tier']}, credits=${body?['credits']}');
    } else {
      Log.w('[RC] verify skipped: ${body?['reason']}');
    }
  } on Object catch (e) {
    Log.w('[RC] verify-google-purchase failed (non-blocking): $e');
  }
}
```

#### 7.4 Error codes to handle
```dart
on PlatformException catch (e) {
  // RC error codes:
  // 1  = purchase cancelled by user → don't show error
  // 28 = ITEM_ALREADY_OWNED (Google Play)
  //      → don't call restorePurchases() — may fail with allowSharingPlayStoreAccount=false
  //      → call Purchases.getCustomerInfo() directly instead
  if (e.code == '1') return; // cancelled
  if (e.code == '28') return getStatus(); // already owned → fetch current state
  throw AppException.payment(message: e.message ?? 'Purchase failed', code: e.code);
}
```

#### 7.5 Sync to Supabase after purchase
```dart
// After purchase completes, sync RC entitlements → Supabase profiles table
// This sets is_premium=true immediately for UI (in case webhook is slow)
Future<void> _syncToSupabase() async {
  try {
    final response = await supabase.functions.invoke('sync-subscription');
    final body = response.data as Map<String, dynamic>?;
    if (body?['synced'] == false) {
      Log.w('[Subscription] sync skipped: ${body?['reason']}');
    }
    // Refresh auth + credit balance so UI reflects new tier and credits immediately
    ref
      ..invalidate(authViewModelProvider)
      ..invalidate(creditBalanceNotifierProvider);
  } on Object catch (e) {
    Log.w('[Subscription] sync-subscription failed (non-blocking): $e');
  }
}
```

---

### PHASE 8: Webhook Setup

#### 8.1 RevenueCat Webhook Config

**⚠️ Generate secret FIRST, then set in BOTH places in same session:**
```bash
# Step 1: Generate secret
SECRET=$(openssl rand -hex 32)
echo "Your secret: $SECRET"

# Step 2: Set in Supabase IMMEDIATELY
supabase secrets set REVENUECAT_WEBHOOK_SECRET=$SECRET --project-ref YOUR_REF

# Step 3: Open RC Dashboard → Integrations → Webhooks → paste $SECRET in Authorization header
```

```
RevenueCat → Integrations → Webhooks → + New webhook
  Name: Supabase Webhook
  URL: https://YOUR_PROJECT.supabase.co/functions/v1/revenuecat-webhook
  Authorization header: <paste the same $SECRET value from above>
  Environment: Production and Sandbox  ← BOTH! Sandbox for testing
  Events: Initial purchase ✅, Renewal ✅, Product change ✅, Cancellation ✅, Expiration ✅
```

**⚠️ CRITICAL:** RC Dashboard and Supabase secrets MUST have identical values.
If set at different times/sessions → mismatch → all events return 401 "Failure" (see Gotcha #17).

#### 8.2 Verify webhook is receiving
```
RC Dashboard → Customers → [find a test user] → check Events tab
If no events → webhook pipeline not working → debug Pub/Sub first
```

---

## ✅ Pre-check Checklist (Full)

### Google Play Console
- [ ] App created with correct package name (permanent!)
- [ ] Release-signed AAB uploaded (NOT debug-signed)
- [ ] Subscription products created and **Active** status
- [ ] Base plan configured with pricing
- [ ] Internal testing track has tester emails
- [ ] License testing: tester Gmail added in Settings → License testing
- [ ] Service account invited via Users & Permissions with correct permissions
- [ ] Real-time developer notifications topic name set

### Google Cloud Console
- [ ] Project created (personal @gmail.com recommended)
- [ ] Google Play Android Developer API enabled
- [ ] Cloud Pub/Sub API enabled ← often missed!
- [ ] Service account created with Pub/Sub Admin role
- [ ] JSON key downloaded and stored safely (NOT in git)

### RevenueCat Dashboard
- [ ] App created with correct package name
- [ ] Service account JSON uploaded → credentials valid
- [ ] RTDN topic connected → status "Connected to Google ✅"
- [ ] Send test notification → RC notification counter increases ← verify this!
- [ ] Products match Google Play IDs exactly
- [ ] Entitlements configured
- [ ] Offerings configured → one marked as **Current** (or `getOfferings().current` returns null)
- [ ] Public API key (`goog_xxx`) added to app `.env`
- [ ] Webhook configured: correct URL + secret + **Sandbox AND Production**
- [ ] **Secret sync verified**: test webhook endpoint with raw token (NO Bearer prefix): `curl -H "Authorization: <raw-secret>" <webhook-url>` → 500 "User not linked" or 200 = auth OK ✅; 401 = secret mismatch → fix before going live (see Gotcha #17)

### Supabase Edge Functions
- [ ] All functions deployed with `--no-verify-jwt` ← critical!
- [ ] `REVENUECAT_WEBHOOK_SECRET` set in secrets **AND matches RC Dashboard Authorization header exactly** (see Gotcha #17)
- [ ] `REVENUECAT_PROJECT_ID` set in secrets (required by sync-subscription) ← easy to miss!
- [ ] `verify-google-purchase` has GPA format validation
- [ ] `sync-subscription` does NOT grant credits (only status sync)
- [ ] `revenuecat-webhook` uses `timingSafeEqual` via type cast for constant-time auth (Gotcha #11) — raw token, no Bearer prefix (Gotcha #6)
- [ ] `revenuecat-webhook` uses event.id as reference_id (not gp- prefix)
- [ ] EXPIRATION handler passes `p_tier: "free"` (NOT null) to update_subscription_status
- [ ] No top-level `throw` outside `Deno.serve()` handler (causes BOOT_ERROR)

### Database
- [ ] `profiles.is_premium`, `subscription_tier`, `premium_expires_at` columns exist
- [ ] `user_credits` table exists with balance check constraint
- [ ] `credit_transactions` has UNIQUE INDEX on reference_id
- [ ] `grant_subscription_credits` RPC uses advisory lock + ON CONFLICT
- [ ] `update_subscription_status` RPC exists and tested
- [ ] All migrations applied to production DB (not just in `supabase/migrations/` folder)
- [ ] RC webhook events in RC Dashboard → NOT stuck in "Retrying" status
- [ ] Restore Purchases accessible in Settings (not just Paywall) — required for Apple App Store

### Flutter App
- [ ] `purchases_flutter` initialized only on `!kIsWeb`
- [ ] `appUserID` set to Supabase user ID
- [ ] `REVENUECAT_GOOGLE_KEY` = real `goog_xxx` key
- [ ] Purchase flow calls `verify-google-purchase` after success
- [ ] Empty orderId handled → skip verify-google-purchase (RC webhook covers credit grant)
- [ ] RC error code 1 (cancelled) handled silently
- [ ] RC error code 28 (already owned) handled via `getCustomerInfo()`
- [ ] `_createUserProfile()` called BEFORE `_revenuecatLogIn()` during signUp ← race condition!
- [ ] `revenuecat_app_user_id` included in profile INSERT (not just relying on UPDATE)
- [ ] After purchase: invalidate BOTH `authViewModelProvider` AND `creditBalanceNotifierProvider`
- [ ] `.env` files NOT committed to git
- [ ] Version code bumped before each new Play Store upload
- [ ] AAB rebuilt after any `.env` change

---

## 🐛 Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `{"code":401,"message":"Invalid JWT"}` from edge fn | **ES256/HS256 mismatch** — deployed without `--no-verify-jwt` | Redeploy ALL functions with `--no-verify-jwt` |
| Credits not granted after purchase | verify-google-purchase getting 401 silently | Check function was deployed `--no-verify-jwt` |
| `is_premium` not updating | sync-subscription getting 401 silently | Same — redeploy with `--no-verify-jwt` |
| RC Dashboard: 0 Active Subscribers | RC server not receiving purchases | Check Pub/Sub → RTDN pipeline. Send test notification, verify counter increases |
| RC webhook never fires | Pub/Sub not configured correctly | Full RTDN setup: Cloud Pub/Sub API + topic + grant Pub/Sub Admin to service account |
| "Credentials need attention" on RevenueCat | Service account not yet active | Wait up to 24h after inviting |
| "Could not check" on products | Same as above | Wait 24h |
| `getOfferings().current` returns null | No offering marked as "Current" | RC Dashboard → Offerings → select default → mark as Current |
| `ITEM_ALREADY_OWNED` (error 28) | User already subscribed | Call `Purchases.getCustomerInfo()` directly (not `restorePurchases()`) |
| Double-grant when RC webhook activates | `gp-` and RC event.id are different reference_ids | Remove `grant_subscription_credits` from `verify-google-purchase` when webhook confirmed stable |
| All webhook events return 401 | Authorization header mismatch — RC sends raw token, NO `Bearer ` prefix | Set `expectedAuth = REVENUECAT_WEBHOOK_SECRET` (raw token, no prefix) — Gotcha #6 |
| All webhook events return 401, show "Failure" (not "Retrying") | `REVENUECAT_WEBHOOK_SECRET` in Supabase ≠ Authorization token in RC Dashboard | Diagnose + fix via Gotcha #17. RC only retries 5xx, not 4xx → "Failure" = permanent |
| RC webhook "User not linked" 500 on new signups | `revenuecat_app_user_id` = NULL because RC login ran before profile INSERT | Fix order: INSERT profile → then `_revenuecatLogIn()`. Include field in INSERT (Gotcha #12) |
| UI credits not updating after purchase | Only `authViewModelProvider` invalidated, `creditBalanceNotifierProvider` not refreshed | Invalidate both providers in `purchase()`, `restore()`, and `_syncToSupabase()` |
| All edge function calls return 503 BOOT_ERROR | Top-level `throw` at module init → function won't start | Move env var validation inside `Deno.serve()` handler (Gotcha #14). Set `REVENUECAT_PROJECT_ID` secret |
| subscription_tier written as NULL after EXPIRATION | `p_tier: null` passed to `update_subscription_status` → UPDATE sets column to NULL | Always pass `p_tier: "free"` for downgrade/expiry events (Gotcha #13) |
| "Service account key creation is disabled" | Org policy on Google Workspace | Use personal @gmail.com for GCloud project |
| AAB rejected "signed in debug mode" | Wrong keystore used | Configure release signing in `build.gradle.kts` |
| Purchase fails in testing | Test account not in License testing | Add Gmail to Settings → License testing in Play Console |
| Webhook not receiving RC events | "Production only" in RC → misses sandbox | Change to "Production and Sandbox" in RC webhook settings |
| Empty `transactionIdentifier` | Free trial subscription, orderId not assigned yet | Skip `verify-google-purchase` — do NOT generate rc- tokens (security: forgeable). RC webhook fires within seconds and grants credits. |

---

## 🔒 Security Checklist

- [ ] `purchaseToken` validated against GPA format regex before DB writes
- [ ] Only GPA.XXXX-XXXX-XXXX-XXXXX tokens accepted — no rc- fallbacks (prevents forged token attacks)
- [ ] Edge functions use `--no-verify-jwt` + manual `auth.getUser()` (not skipping auth entirely)
- [ ] Webhook verified with timing-safe comparison (prevents timing attacks)
- [ ] Service account JSON key NOT committed to git (add `*.json` + `service-account*.json` to `.gitignore`)
- [ ] Keystore files NOT committed to git (add `*.jks`, `*.keystore`, `keystore.properties` to `.gitignore`)
- [ ] `REVENUECAT_WEBHOOK_SECRET` only in Supabase secrets, not in code

---

## 📁 File Structure Reference

```
android/app/
  build.gradle.kts          ← applicationId, signingConfigs, keystoreProps
  *.jks                     ← Release keystore (DO NOT COMMIT)
  keystore.properties       ← Keystore credentials (DO NOT COMMIT)

lib/features/subscription/
  data/repositories/
    subscription_repository.dart  ← RC SDK calls, verify-google-purchase call
  domain/
    entities/subscription_status.dart
    repositories/i_subscription_repository.dart
  presentation/
    providers/subscription_provider.dart  ← purchase(), restore(), _syncToSupabase()

.env.development                 ← Dev secrets (git-ignored)
.env.production                  ← Prod secrets (git-ignored)

supabase/functions/
  verify-google-purchase/index.ts  ← Immediate fallback: update status + grant credits
  sync-subscription/index.ts       ← RC entitlement sync, NO credit grants
  revenuecat-webhook/index.ts      ← Authoritative: full lifecycle events

supabase/migrations/
  *_add_subscription_support.sql   ← profiles columns, user_credits, credit_transactions
  *_fix_credit_idempotency.sql     ← UNIQUE INDEX on reference_id, RPC functions
```

---

## 📈 Verification After Setup

Run these queries to confirm end-to-end after a real purchase:

```sql
-- 1. Check profiles updated correctly
SELECT id, is_premium, subscription_tier, premium_expires_at, updated_at
FROM profiles WHERE is_premium = true ORDER BY updated_at DESC LIMIT 10;

-- 2. Check credits granted with correct reference_id format
SELECT user_id, amount, reference_id, description, created_at
FROM credit_transactions
WHERE description LIKE '%subscription%'
ORDER BY created_at DESC LIMIT 10;
-- Expected: reference_id = 'gp-GPA.xxxx-xxxx-xxxx-xxxxx' (from verify-google-purchase)
-- Or: reference_id = UUID (from RC webhook — if webhook is working)

-- 3. Check user_credits balance
SELECT user_id, balance FROM user_credits
WHERE user_id IN (SELECT id FROM profiles WHERE is_premium = true)
ORDER BY balance DESC;
```

**Healthy state indicators:**
- `is_premium = true`, `subscription_tier` set ✅
- `credit_transactions` has `gp-GPA.xxx` entry with correct amount ✅
- `user_credits.balance` = welcome_bonus + subscription_credits - usage ✅
- RC Dashboard → Customers → user appears with active subscription ✅ *(only after RC webhook works)*
