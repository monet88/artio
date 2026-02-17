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
