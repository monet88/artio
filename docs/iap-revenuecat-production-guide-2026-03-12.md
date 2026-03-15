# IAP RevenueCat Production Guide — Artio (Updated 2026-03-13)

> **Trạng thái:** Production-verified ✅ — 3 real purchases confirmed end-to-end
> **Stack:** Flutter 3.x + purchases_flutter 9.x + RevenueCat + Supabase Edge Functions
> **Dự án:** Artio (`com.artio.artio`, Supabase: `kytbmplsazsiwndppoji`)

---

## 1. Architecture Hiện Tại (Đã Hoạt Động)

```
Flutter App (purchases_flutter 9.x)
  │
  ├── Purchases.purchase() → RC SDK validates on-device
  │       │
  │       ├── [Immediate, non-blocking] verify-google-purchase edge fn
  │       │       → 25-day rate limit check (prevents double-grant + credit farming)
  │       │       → grant_subscription_credits (reference_id: gp-GPA.xxx)
  │       │       → NO tier update (RC webhook is authoritative for tier)
  │       │
  │       └── [Immediate, non-blocking] sync-subscription edge fn
  │               → RC V2 API active_entitlements
  │               → update_subscription_status (tier + expiry, NO credits)
  │               → 5-min grace window prevents race-condition downgrade
  │
  └── [Async — RC Pub/Sub pipeline] revenuecat-webhook edge fn
          INITIAL_PURCHASE → 25-day rate limit check → grant_subscription_credits
          RENEWAL          → grant_subscription_credits (idempotent via event.id)
          EXPIRATION       → update_subscription_status(is_premium=false, tier='free')
          PRODUCT_CHANGE   → update_subscription_status (new tier)
```

**Design principles:**
- `verify-google-purchase` = fast-path credit grant, runs even before RC webhook fires
- `sync-subscription` = syncs tier/expiry from RC, never grants credits
- `revenuecat-webhook` = authoritative source for tier + renewal credits
- Both `verify-google-purchase` AND `revenuecat-webhook` guard against double-grant via 25-day rate limit

---

## 2. Security Model

### Threat: Credit Farming via Fabricated Tokens

**Attack:** Authenticated user calls `verify-google-purchase` with fake tokens matching the GPA regex to collect unlimited credits.

**Mitigations (layered):**

| Layer | Mechanism | Where |
|-------|-----------|-------|
| 1 | GPA format validation — only `GPA.\d{4}-\d{4}-\d{4}-\d+` accepted | `isValidPurchaseToken()` |
| 2 | 25-day rate limit — runs inside `grant_subscription_credits` RPC when called with `p_check_recent_grant=true` (atomic under advisory lock) | Both `verify-google-purchase` + `revenuecat-webhook` INITIAL_PURCHASE |
| 3 | Rate limit fail-closed — DB error → HTTP 500, not silent bypass | Both edge functions |

**CRITICAL:** Query uses `type='subscription'` — this is what `grant_subscription_credits` RPC inserts. Do NOT use `type='subscription_credit'` (wrong, would make guard a no-op).

### Threat: Tier Escalation

**Attack:** User with a valid Pro GPA token claims Ultra tier by sending `productId: artio_ultra_*`.

**Mitigation:** `verify-google-purchase` intentionally omits `update_subscription_status`. Only RC webhook (server-to-server) sets authoritative tier. Client-supplied `productId` only determines credit amount for the fast-path grant.

### Threat: Double Credit Grant

**Risk:** `verify-google-purchase` and `revenuecat-webhook` can both fire for the same purchase using different `reference_id` formats (`gp-GPA.xxx` vs RC `event.id`) — `ON CONFLICT` dedup won't catch this.

**Mitigation:** 25-day rate limit in BOTH functions. Whichever fires first sets the grant; the second sees a recent grant and skips.

**TOCTOU race (Fixed — migration `20260315120000`):** Previously, two concurrent requests with unique tokens could both pass the SELECT check before either INSERT landed. Fixed by moving the advisory lock and 25-day guard inside `grant_subscription_credits` RPC (`p_check_recent_grant=true`), making the guard + insert atomic under a per-user lock.

---

## 3. Edge Functions — Behavior Reference

### `verify-google-purchase`

**Deployed with:** `--no-verify-jwt` (function handles JWT internally via `userClient.auth.getUser()`)

**Flow:**
1. Validate JWT → get `user.id`
2. Parse `purchaseToken` + `productId` from body
3. Validate GPA format — reject non-`GPA.xxx` tokens
4. Lookup `productId` prefix → tier + credits
5. Call `grant_subscription_credits` RPC with `p_check_recent_grant=true` — the 25-day guard runs inside the RPC under an advisory lock (atomic, no TOCTOU race)
6. Return `{ verified: true, tier, credits, credits_already_granted }`

**Does NOT:** Update subscription tier or `is_premium` — RC webhook owns this.

### `sync-subscription`

**Deployed with:** `--no-verify-jwt`

**Flow:**
1. Validate JWT → get `user.id`
2. Fetch `revenuecat_app_user_id` + `is_premium` + `updated_at` from `profiles`
3. Call RC V2 API: `GET /v2/projects/{RC_PROJECT_ID}/customers/{rcUserId}/active_entitlements`
4. If RC returns active entitlements → `update_subscription_status(is_premium=true, tier, expires_at)`
5. If RC returns empty:
   - If `is_premium=true` AND `updated_at < 5 min ago` → skip (race condition: RC hasn't processed purchase yet)
   - Otherwise → `update_subscription_status(is_premium=false, tier='free')`

**Does NOT:** Grant credits.

### `revenuecat-webhook`

**Auth:** `Authorization: Bearer {REVENUECAT_WEBHOOK_SECRET}` (timing-safe comparison)

**INITIAL_PURCHASE:**
1. `update_subscription_status(is_premium=true, tier, expires_at)`
2. `grant_subscription_credits` with `p_check_recent_grant=true` → the 25-day guard runs inside the RPC under an advisory lock (atomic, prevents double-grant with `verify-google-purchase`). `reference_id = event.id` (RC event UUID)
3. If RPC returns `{ granted: false }` → skip (log + break, return 200)

**RENEWAL:**
1. `update_subscription_status(is_premium=true, tier, expires_at)`
2. `grant_subscription_credits` → `reference_id = event.id` (idempotent — RC retries same event.id)

**EXPIRATION:**
1. `update_subscription_status(is_premium=false, tier='free', expires_at=null)`
2. Return 500 on RPC failure → RC retries

**PRODUCT_CHANGE:**
1. `update_subscription_status(is_premium=true, new_tier, expires_at)`
2. Return 500 on RPC failure → RC retries

---

## 4. Flutter Code — Key Points

### `subscription_repository.dart`

```dart
// After successful Purchases.purchase():
final rawToken = result.storeTransaction.transactionIdentifier; // GPA.xxx or empty
final productId = package.identifier;

if (rawToken.isNotEmpty) {
  // Non-blocking — user already charged, don't delay success UI
  unawaited(_verifyWithGooglePlay(rawToken, productId));
} else {
  // Empty orderId shouldn't happen (no free trials configured)
  Log.w('[RC] orderId empty — skipping verify, RC webhook will handle');
}
```

**`transactionIdentifier` on Android** = orderId (`GPA.xxx`), NOT purchaseToken. These are different:
- orderId = human-readable order reference (what we have)
- purchaseToken = long token needed for Google Play Developer API (what we don't have)

### `subscription_provider.dart`

```dart
// Non-blocking sync — show success immediately after purchase
final result = await repo.purchase(package);
unawaited(_syncToSupabase()); // runs in background
return result;
```

### Error Handling

```dart
// Cancellation — silent, no snackbar
final isCancelled = err is PaymentException && err.code == 'user_cancelled';
if (isCancelled) return;

// All other errors → AppExceptionMapper
SnackBar(content: Text(AppExceptionMapper.toUserMessage(err)));
```

**`app_exception_mapper.dart` check order** (important — wrong order caused bugs):
1. `cancelled` / `canceled` → "Payment was cancelled."
2. `declined` → "Payment was declined."
3. `insufficient credits` / `credit balance` / `not enough credits` → "Not enough credits."
4. Default → "Payment could not be processed."

---

## 5. Database Schema — Key Facts

```sql
-- credit_transactions.type values (CHECK constraint)
'welcome_bonus' | 'ad_reward' | 'generation' | 'refund' |
'subscription' | 'purchase' | 'daily_reset' | 'admin_grant' | 'manual'

-- grant_subscription_credits RPC inserts type='subscription' (NOT 'subscription_credit')
-- Rate-limit queries MUST use .eq("type", "subscription")

-- profiles.subscription_tier default = 'free' (NOT null)
-- Downgrade: p_tier='free', NOT p_tier=null
```

---

## 6. Deployment

```bash
export SUPABASE_ACCESS_TOKEN=<token from Supabase Dashboard → Account → Access Tokens>

# ALL functions require --no-verify-jwt (ES256 vs HS256 mismatch otherwise)
supabase functions deploy verify-google-purchase --no-verify-jwt --project-ref kytbmplsazsiwndppoji
supabase functions deploy sync-subscription      --no-verify-jwt --project-ref kytbmplsazsiwndppoji
supabase functions deploy revenuecat-webhook     --no-verify-jwt --project-ref kytbmplsazsiwndppoji
```

**Why `--no-verify-jwt`:** Supabase gateway verifies JWT with HS256 (symmetric) but GoTrue v2 issues ES256 (asymmetric). Mismatch → 401 for all requests. Functions handle JWT internally via `userClient.auth.getUser()` — if token invalid, function returns 401 itself.

**Security of `--no-verify-jwt`:** Safe — each function validates user via `auth.getUser()`. `revenuecat-webhook` uses bearer secret instead.

---

## 7. `.env.production` — What NOT to Include

**NEVER in `.env.production`** (bundled in APK — extractable by anyone):
```
SUPABASE_SERVICE_ROLE_KEY  → bypasses all RLS, server-side only
GEMINI_API_KEY             → read by edge functions via Supabase secrets
KIE_API_KEY                → read by edge functions via Supabase secrets
GITHUB_TOKEN               → CI/CD only
```

Set server-side keys via:
```bash
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=<key> \
                     GEMINI_API_KEY=<key> \
                     KIE_API_KEY=<key> \
                     --project-ref kytbmplsazsiwndppoji
```

**Safe to bundle** (client-facing by design):
```
SUPABASE_URL, SUPABASE_ANON_KEY, REVENUECAT_*_KEY, ADMOB_*, SENTRY_DSN
```

---

## 8. Troubleshooting

### User purchased but credits = 0

1. Check Supabase → `credit_transactions` — is there a row with `reference_id LIKE 'gp-%'`?
2. If yes → credits granted, check `user_credits.balance`
3. If no → `verify-google-purchase` logs? Was token valid GPA format?
4. Was `SUPABASE_ACCESS_TOKEN` correct when deploying? (wrong token = old function version still running)

### User purchased but `is_premium = false`

1. `sync-subscription` ran but RC returned empty → check 5-min grace window
2. RC webhook fired EXPIRATION before INITIAL_PURCHASE? Check RC event order in logs
3. `sync-subscription` returned 5xx? Check edge function logs

### RC webhook = 0 events

Full pipeline needed:
```
Google Play → Cloud Pub/Sub topic → RC subscribes → RC fires webhook → Supabase
```

Debug checklist:
1. RC Dashboard → App → Google Play → RTDN → "Connected to Google ✅"?
2. RC Dashboard → send test notification → counter increases?
3. Google Cloud Console → Pub/Sub → Subscriptions → has `revenuecat-*` subscription?
4. Supabase → Edge Functions → `revenuecat-webhook` → Logs → any requests?

---

## 9. Verify DB Health

```sql
SELECT
  p.is_premium,
  p.subscription_tier,
  p.premium_expires_at,
  uc.balance,
  ct.reference_id,
  ct.created_at as grant_time
FROM profiles p
JOIN user_credits uc ON uc.user_id = p.id
LEFT JOIN LATERAL (
  SELECT reference_id, created_at
  FROM credit_transactions
  WHERE user_id = p.id AND type = 'subscription'
  ORDER BY created_at DESC LIMIT 1
) ct ON true
WHERE p.is_premium = true
ORDER BY p.updated_at DESC
LIMIT 10;

-- Healthy state:
-- is_premium = true
-- subscription_tier = 'ultra' OR 'pro'
-- reference_id = 'gp-GPA.xxxx-xxxx-xxxx-xxxxx' (from verify fn)
--             OR RC event UUID (from webhook)
```

---

## 10. Known Issues / Backlog

| Priority | Issue | Status |
|----------|-------|--------|
| ~~P2~~ | ~~TOCTOU race in 25-day rate limit — two concurrent requests can both pass SELECT before INSERT~~ | Fixed in migration `20260315120000` — guard now runs inside `grant_subscription_credits` RPC under advisory lock |
| MEDIUM | Confirm RC Pub/Sub webhook receiving events in production | Unverified — 0 events in history |
| MEDIUM | iOS StoreKit flow not implemented | Not started |
| LOW | When RC webhook confirmed stable → consider removing credit grant from `verify-google-purchase` | Deferred |
