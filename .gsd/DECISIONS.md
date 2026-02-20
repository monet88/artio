# Architecture Decision Records

## ADR-001: Hybrid Freemium Monetization Model
**Date**: 2026-02-17
**Status**: Accepted

**Context**: App currently requires email login before accessing any feature. Need to increase user acquisition and engagement.

**Decision**: Remove login wall. Implement hybrid model:
- All generation costs credits
- Free users earn credits via rewarded ads (AdMob)
- Subscribers (Pro/Ultra) get monthly credits + premium models + no ads
- No credit pack purchases — subscription only

**Rationale**:
- Login wall causes high bounce rate
- Rewarded ads proven effective in mobile apps for engagement
- Subscription-only (no credit packs) keeps model simple and predictable revenue

**Consequences**:
- Need anonymous Supabase auth for unauthenticated users
- Edge Function must support anonymous/authenticated users
- Need credit ledger system in database
- AdMob integration required

---

## ADR-002: RevenueCat for Payment (Mobile Only)
**Date**: 2026-02-17
**Status**: Accepted

**Context**: Need subscription payment processing for iOS and Android.

**Decision**: Use RevenueCat for mobile subscriptions. Defer Stripe (web) to future milestone.

**Rationale**:
- 90%+ revenue from mobile in-app purchases
- RevenueCat SDK already in pubspec (`purchases_flutter: ^9.0.0`)
- Single SDK handles both App Store and Google Play
- Stripe adds server-side complexity (webhooks, verification)

**Consequences**:
- Web users cannot subscribe (for now)
- Future milestone needed for web payments

---

## ADR-003: No Anonymous Auth — Login Required for Generation
**Date**: 2026-02-17
**Status**: Accepted

**Context**: Discussed whether to use Supabase Anonymous Auth to let users generate without login.

**Decision**: No anonymous auth. Users browse freely without login, but must create an account (email/social) before generating images.

**Rationale**:
- Simplifies architecture — no anonymous-to-authenticated migration needed
- Edge Function already requires JWT — no changes needed
- RLS policies remain unchanged
- Credit tracking tied to real accounts from the start
- Reduces Supabase anonymous user cleanup overhead

**Consequences**:
- Phase 1 scope reduced significantly (no `signInAnonymously()`, no `AuthState.anonymous`)
- Auth gate needed at Generate button (intercept before Edge Function call)
- Gallery tab hidden or shows "Login to view" for unauthenticated users
- Settings shows "Login" button for unauthenticated users

---

## Phase 1 Decisions

**Date:** 2026-02-17

### Scope
- Remove login wall from router — allow Home, template detail, Settings without auth
- Auth gate at Generate action — prompt login/register when tapping Generate
- Gallery: hidden or "Login to view" for unauthenticated users
- Settings: theme toggle works without login, show "Login" button

### Approach
- Chose: Simple router redirect removal + auth gate at action point
- Reason: No Supabase Anonymous Auth needed — drastically simpler, Edge Function unchanged

### Constraints
- Generation still requires JWT (Edge Function) — users MUST login before generating
- Phase 1 does NOT include credit system — generation works as-is after login (credits in Phase 2)
- Welcome bonus (20 credits) deferred to Phase 2 (credit system)

---

## Edge Case Fixes Decisions

**Date:** 2026-02-20

### Scope & Execution Strategy
- **Chose:** 3 PRs grouped by file area (Auth → Credits → Edge Function)
- **Reason:** Each PR is small, focused, easy to review. All 3 are independent — no cross-PR deps.

### Issue 1.1: Credit Pre-Check — Hardcode vs Dynamic
- **Chose:** Hardcode `minimumCost = 4` (cheapest model)
- **Reason:** Client-side check is optimistic only. Server enforces exact per-model cost via `MODEL_CREDIT_COSTS` map. Avoids breaking `IGenerationPolicy.canGenerate()` signature.

### Issue 2.1: Premium Check Placement
- **Chose:** Check BEFORE credit deduction
- **Reason:** Premium check is validation — belongs with other pre-generation checks. Avoids creating unnecessary deduct+refund transaction pairs in DB.

### Issue 1.4: Session Expiry — Deferred
- **Chose:** Defer entirely
- **Reason:** Supabase SDK handles auto-refresh natively. Manual `ensureValidSession()` is redundant. Revisit only if users report session-related errors in Sentry.

### Issue 2.3: OAuth Timeout Duration
- **Chose:** 3 minutes (reduced from 5)
- **Reason:** Typical OAuth flow completes in 30s-2min. 3 minutes gives enough buffer for slow networks while providing reasonable UX.

### FreeBetaPolicy Cleanup
- **Chose:** Delete `free_beta_policy.dart`
- **Reason:** Dead code after `CreditCheckPolicy` replaces it. No future use case identified.

