---
phase: reward-ad-ssv
level: 2
researched_at: 2026-02-20
---

# Reward Ad Server-Side Verification — Research

## Current Vulnerability

**File:** `reward-ad/index.ts` + `ad_reward_provider.dart`

**Flow (insecure):**
```
Client: showAd() → earned=true → POST /reward-ad (JWT only) → server awards 5 credits
```

**Attack vector:** A modified client or HTTP replay can call `/reward-ad` directly without watching any ad. The server only checks JWT authentication — it never validates that an ad was actually watched.

---

## Questions Investigated

1. How does Google AdMob Server-Side Verification (SSV) work?
2. Can SSV be implemented on Supabase Edge Functions (Deno)?
3. What alternatives exist if SSV is too complex?
4. What's the best approach for Artio's architecture?

---

## Findings

### Option A: Google AdMob SSV (Callback-Based)

**How it works:**
1. Configure a **Callback URL** in AdMob dashboard (points to your server)
2. Set `ServerSideVerificationOptions` on the `RewardedAd` in Flutter (pass `userId` + `customData`)
3. When user completes ad, **Google's servers** send a GET request to your Callback URL with signed parameters
4. Your server verifies the ECDSA signature using Google's public keys from `https://gstatic.com/admob/reward/verifier-keys.json`
5. Only then award credits

**Callback URL format:**
```
https://your-server.com/verify-reward?
  ad_unit=ca-app-pub-XXX/YYY
  &reward_amount=5
  &reward_item=credits
  &transaction_id=abc123
  &user_id=<supabase_user_id>
  &custom_data=<nonce_or_job_id>
  &signature=MEUC...
  &key_id=123
```

**Verification process (Deno/TypeScript):**
```typescript
// 1. Fetch Google's public keys
const keys = await fetch("https://gstatic.com/admob/reward/verifier-keys.json").then(r => r.json());

// 2. Find key matching key_id
const key = keys.keys.find(k => k.keyId === keyId);

// 3. Extract content to verify (all params except signature & key_id)
const content = url.search.split("&")
  .filter(p => !p.startsWith("signature=") && !p.startsWith("key_id="))
  .join("&");

// 4. Verify ECDSA signature using Web Crypto API
const isValid = await crypto.subtle.verify(
  { name: "ECDSA", hash: "SHA-256" },
  publicKey,
  signatureBytes,
  contentBytes
);
```

**Flutter client changes:**
```dart
// After loading the ad:
_rewardedAd!.serverSideVerificationOptions = ServerSideVerificationOptions(
  userId: currentUserId,
  customData: nonce, // unique per-request nonce
);
```

**Pros:**
- Gold standard — Google-verified ad completion
- Impossible to spoof (signature verified with Google's keys)
- `transaction_id` prevents replay attacks

**Cons:**
- Requires publicly accessible callback URL (Supabase Edge Functions are public ✅)
- Callback is async — arrives ~seconds after ad completes
- Client must wait for server confirmation before showing reward UI
- Requires crypto key management (fetch + cache Google's keys)
- Separate endpoint from current `/reward-ad` flow

**Complexity: Medium-High**

---

### Option B: Hybrid — Client + Server Nonce Validation (RECOMMENDED)

**How it works:**
1. Client requests a **one-time nonce** from server before showing ad
2. Server stores nonce with timestamp in DB (`pending_ad_rewards` table)
3. Client passes nonce to `ServerSideVerificationOptions.customData`
4. After ad completion, client sends nonce + reward claim to server
5. Server validates: nonce exists, not expired (5-min TTL), not already used
6. Server awards credits and marks nonce as consumed

**Flow:**
```
Client → POST /reward-ad/request-nonce → Server creates nonce (UUID + 5min TTL)
Client → showAd(ServerSideVerificationOptions(customData: nonce))
Client → POST /reward-ad/claim { nonce } → Server validates & awards credits
```

**New DB table:**
```sql
CREATE TABLE pending_ad_rewards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  nonce UUID NOT NULL UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  claimed_at TIMESTAMPTZ,
  expired BOOLEAN NOT NULL DEFAULT false
);

CREATE INDEX idx_pending_ad_rewards_nonce ON pending_ad_rewards(nonce);
CREATE INDEX idx_pending_ad_rewards_user_cleanup ON pending_ad_rewards(created_at) WHERE claimed_at IS NULL;
```

**Server validation RPC:**
```sql
CREATE FUNCTION claim_ad_reward(p_user_id UUID, p_nonce UUID)
RETURNS JSON AS $$
DECLARE
  v_reward RECORD;
BEGIN
  -- Atomically claim the nonce (prevents double-spend)
  UPDATE pending_ad_rewards
  SET claimed_at = now()
  WHERE user_id = p_user_id
    AND nonce = p_nonce
    AND claimed_at IS NULL
    AND created_at > now() - INTERVAL '5 minutes'
  RETURNING * INTO v_reward;

  IF v_reward IS NULL THEN
    RETURN json_build_object('success', false, 'error', 'invalid_or_expired_nonce');
  END IF;

  -- Proceed with existing reward_ad_credits logic (daily limit, award, log)
  ...
END;
$$
```

**Pros:**
- Prevents direct API abuse (need valid nonce)
- Prevents replay attacks (nonce consumed on claim)
- Time-bound (5-min TTL)
- Works with existing Edge Function architecture
- No external callback URL needed (client-initiated flow)
- Can optionally ADD AdMob SSV callback later as double-verification

**Cons:**
- Doesn't cryptographically prove ad was watched (nonce proves intent, not completion)
- Sophisticated attacker could still: request nonce → claim without watching
- But: combined with daily limit (10/day), rate limiting, and account banning — risk is acceptable

**Complexity: Medium**

---

### Option C: Client-Only with Enhanced Rate Limiting

**How it works:**
- Keep current flow but add aggressive server-side protections:
  - Rate limit: max 1 reward claim per 30 seconds per user
  - Daily limit already exists (10/day)
  - Add anomaly detection: flag users claiming 10/day every day
  - Add device fingerprinting via custom_data

**Pros:**
- Simplest implementation
- No schema changes
- Fast to ship

**Cons:**
- Still fundamentally vulnerable to automation
- No proof of ad view
- Only mitigates, doesn't prevent abuse

**Complexity: Low**

---

## Decision Matrix

| Criteria | Option A (SSV) | Option B (Nonce) | Option C (Rate Limit) |
|----------|---------------|-----------------|----------------------|
| Security | ★★★★★ | ★★★★☆ | ★★☆☆☆ |
| Implementation effort | High | Medium | Low |
| Architecture fit | Medium | High | High |
| Maintenance burden | Medium | Low | Low |
| User experience impact | Medium (async delay) | Low (extra round-trip) | None |
| Future-proof | Yes | Yes (can add SSV later) | No |

---

## Recommendation: Option B (Hybrid Nonce) → upgrade to A later

**Rationale:**
1. **Option B** provides strong protection (nonce + TTL + daily limit) with moderate effort
2. Fits perfectly into existing Supabase Edge Function architecture
3. Can be enhanced with **Option A** (AdMob SSV callback) later as a second verification layer
4. The `ServerSideVerificationOptions` can be set NOW even without the callback endpoint — when the SSV endpoint is added later, it will just work

**Implementation plan:**
1. Create `pending_ad_rewards` table + migration
2. Create `request_ad_nonce` RPC function
3. Create `claim_ad_reward` RPC function (replaces `reward_ad_credits` for ad flow)
4. Split `reward-ad/index.ts` into 2 endpoints: `/request-nonce` + `/claim`
5. Update `RewardedAdService` to set `ServerSideVerificationOptions`
6. Update `AdRewardNotifier` to use 2-step flow
7. Add cleanup job for expired nonces (optional — pending_ad_rewards will be small)

---

## Patterns to Follow

- **Atomic nonce consumption** — single UPDATE with WHERE ensures no double-spend
- **Time-bounded tokens** — 5-min TTL prevents stockpiling
- **Separation of concerns** — nonce generation ≠ reward granting
- **Backward compatible** — keep `reward_ad_credits` RPC for admin/manual use

## Anti-Patterns to Avoid

- **Client-side trust** — never trust `earned = true` from the client
- **Predictable nonces** — use `gen_random_uuid()`, never sequential IDs
- **Long-lived tokens** — keep TTL short (5 min max)
- **Blocking on SSV callback** — don't make user wait for Google's async callback in v1

## Dependencies Identified

| Package | Version | Purpose |
|---------|---------|---------|
| `google_mobile_ads` | ^6.0.0 (already installed) | `ServerSideVerificationOptions` |
| No new packages needed | — | Nonce approach uses existing Supabase infra |

## Risks

| Risk | Mitigation |
|------|-----------|
| Nonce doesn't prove ad was watched | Combined with daily limit (10), rate limiting, and low reward value (5 credits) — fraud economics don't justify effort |
| Nonce table grows unbounded | Add periodic cleanup (DELETE WHERE created_at < now() - 1 day) or use pg_cron |
| Race condition on nonce claim | Atomic UPDATE with WHERE clause — DB handles concurrency |
| Migration needed in production | Migration is additive (new table), no breaking changes |

---

## Files to Modify

| File | Change |
|------|--------|
| `supabase/migrations/new_pending_ad_rewards.sql` | New table + RPC functions |
| `supabase/functions/reward-ad/index.ts` | Split into nonce-request + claim endpoints |
| `lib/core/services/rewarded_ad_service.dart` | Add `ServerSideVerificationOptions` |
| `lib/features/credits/presentation/providers/ad_reward_provider.dart` | 2-step flow |
| `lib/features/credits/data/repositories/credit_repository.dart` | New `requestAdNonce()` + update `rewardAdCredits()` |
| `lib/features/credits/domain/repositories/i_credit_repository.dart` | Add interface method |

---

## Ready for Planning

- [x] Questions answered
- [x] Approach selected (Option B: Hybrid Nonce)
- [x] Dependencies identified (none new)
- [x] Migration strategy clear
- [x] Files to modify identified
- [x] Risks assessed
