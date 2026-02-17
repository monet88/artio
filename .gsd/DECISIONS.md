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
