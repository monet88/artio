# Milestone: Security — Reward Ad SSV

## Completed: 2026-02-20

## Summary
Implemented server-side nonce-based verification for rewarded ad credits, closing the critical vulnerability where clients could spoof ad completion and claim credits without watching ads.

## Deliverables
- ✅ `pending_ad_rewards` table with 5-min TTL nonce system
- ✅ `request_ad_nonce` RPC — generates one-time nonce, checks daily limit
- ✅ `claim_ad_reward` RPC — atomic nonce consumption + credit award
- ✅ Edge Function split into `?action=request-nonce` and `?action=claim`
- ✅ DRY auth helper in Edge Function
- ✅ Flutter client uses 2-step flow: nonce → SSV → show ad → claim
- ✅ `ServerSideVerificationOptions` set on RewardedAd (future AdMob SSV ready)
- ✅ All tests updated and passing (640/640)
- ✅ Migration + Edge Function deployed to Supabase production

## Phase Completed
1. Phase `reward-ad-ssv` — Research + 3 Plans + Execution + Verification (2026-02-20)

## Metrics
- Total commits: 3 (research, implementation, verification)
- Files changed: 8 (1 migration, 1 Edge Function, 4 Dart source, 2 test files)
- Tests: 640/640 passing
- Duration: 1 day

## Architecture Decision
**Option B — Hybrid Nonce-Based Verification** chosen over:
- Option A (AdMob SSV Callback): Requires public callback URL + ECDSA verification — complex for current scope
- Option C (Client-Only Rate Limiting): Insufficient security

Rationale: Nonce flow prevents direct API abuse and replay attacks while fitting the existing Supabase architecture. ServerSideVerificationOptions are set now, enabling easy transition to AdMob's official SSV callback (Option A) later.

## Security Properties
- **Anti-replay:** Each nonce is single-use (atomic UPDATE with `claimed_at IS NULL`)
- **Time-bound:** 5-minute TTL prevents stale nonce exploitation
- **Server-controlled:** Nonce generated server-side, not client-side
- **Double-spend protection:** PostgreSQL atomic UPDATE prevents concurrent claims
- **Rate-limited:** Daily ad limit (10/day) enforced at both nonce request and claim

## Lessons Learned
1. `google_mobile_ads@6.0.0` uses `setServerSideOptions()` (async method), NOT a setter — API research first saves debugging time
2. `expect(fn, throwsA(...))` needs `await expectLater(fn(), throwsA(...))` for async functions in Flutter tests — otherwise verify() runs before async completes
3. Supabase `db push` applies all pending migrations in order — safe for production deployment
