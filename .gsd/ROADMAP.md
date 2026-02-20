# ROADMAP.md

> **Current Milestone**: Edge Case Fixes (Phase 2)
> **Goal**: Fix 7 edge cases from code review — auth, credits, edge function
> **Last Completed**: Data Integrity & Performance (2026-02-19)

---

## Completed Milestones

### Edge Case Fixes (Phase 1) ✅
- DateTime parsing, concurrent sign-in guards, profile TOCTOU race, 429 retry, timeout, TLS retry, router notify, file error handling
- 5 plans, 8 tasks, 453 tests passing

### Freemium Monetization ✅
- Remove login wall, credit system, rewarded ads, RevenueCat subscriptions, premium gate, watermark
- 7 phases, 530 tests passing
- All must-haves delivered, PR #13 merged

### Codebase Improvement ✅
- CORS DRY, widget extraction, architecture violations, test coverage, analyzer warnings
- 5 phases, 9 plans, 606 tests passing
- All must-haves delivered, 0 deferrals

### Widget Cleanup ✅
- Theme & screen extraction: app_component_themes, home_screen, create_screen, register_screen
- 1 phase, flutter analyze clean, 606/606 tests passing

### Code Health ✅
- Admin web dependencies, dart:io fix, deprecated Ref types, flutter analyze clean
- 3 phases, PR #19

### Data Integrity & Performance ✅
- Model registry sync, template data caching, gallery data caching
- 3 phases, all verified

---

## Current Milestone: Edge Case Fixes (Phase 2)

**Goal**: Fix 7 edge cases identified during parallel code review to harden auth, credit system, and edge function reliability.

### Must-Haves
- [ ] Auth input validation — empty email/password blocked before network call
- [ ] OAuth timeout — stuck authenticating state auto-recovers after 3 min
- [ ] Credit pre-check — generation blocked when balance < minimum cost
- [ ] Provider disposal — credit providers invalidated on logout
- [ ] Credit stream recovery — empty rows return default, errors don't kill stream
- [ ] Refund retry — 3x exponential backoff on refund failure
- [ ] Premium enforcement — server-side 403 for non-premium users on premium models

### Nice-to-Haves
- [ ] Session expiry check (deferred — Supabase auto-refresh sufficient)

### Phases

#### Phase 1: Auth Fixes
**Status**: ✅ Complete
**Objective**: Input validation for signIn/signUp + OAuth 3-min timeout
**Plan**: `.gsd/phases/1/PLAN.md`
**Issues**: 2.2, 2.3

#### Phase 2: Credit Fixes
**Status**: ✅ Complete
**Objective**: CreditCheckPolicy, provider disposal on logout, stream error recovery
**Plan**: `.gsd/phases/2/PLAN.md`
**Issues**: 1.1, 1.3, 2.4

#### Phase 3: Edge Function Fixes
**Status**: ✅ Complete
**Objective**: Refund retry with exponential backoff, premium model enforcement
**Plan**: `.gsd/phases/3/PLAN.md`
**Issues**: 1.2, 2.1

---

## Backlog

### Features
- [ ] Stripe integration for web payments
- [ ] Priority generation queue for subscribers
- [ ] Credit history / transaction log UI
- [ ] Subscription management settings page
- [ ] Referral / affiliate system

### Technical Debt (from Edge Case Fixes audit)
- [ ] Edge Function integration tests (refund retry, premium enforcement)
- [ ] PREMIUM_MODELS sync between `ai_models.dart` and `index.ts` — shared source of truth
- [ ] Deno type-check CI step for Edge Functions
- [ ] Sentry alert rule for `[CRITICAL] Credit refund failed`
- [ ] Replace test AdMob IDs with production IDs (TODO in rewarded_ad_service.dart)
