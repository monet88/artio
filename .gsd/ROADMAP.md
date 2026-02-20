# ROADMAP.md

> **Current Milestone**: Edge Case Hardening
> **Last Completed**: Security — Reward Ad SSV (2026-02-20)

---

## Completed Milestones

### Security — Reward Ad SSV ✅
- Nonce-based ad reward validation, `pending_ad_rewards` table, 2-action Edge Function, Flutter 2-step flow
- 1 phase, 3 plans, 640 tests passing, deployed to production

### Model Sync & Edge Function Tests ✅
- Fixed PREMIUM_MODELS drift (3 mismatches), synced credit costs, shared module + 8 Deno tests
- 2 phases, 5 tasks, 9 commits, 646 tests (638 Flutter + 8 Deno)

### Edge Case Fixes (Phase 2) ✅
- Auth validation, OAuth timeout, CreditCheckPolicy, provider disposal, stream recovery, refund retry, premium enforcement
- 3 phases, 8 tasks, 22 commits, 638 tests passing

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

## Current Milestone: Edge Case Hardening

**Goal:** Fix remaining unhandled and partial edge cases from [review report](plans/reports/review-260220-1533-edge-cases-verification.md)

### Must-Haves
- [ ] Rate limiting for `generate-image` Edge Function (per-user throttle)
- [ ] `imageCount` server-side bounds validation (1–4)
- [ ] Orphaned storage file cleanup on partial upload failure
- [ ] Realtime subscription reconnection logic in `GenerationJobManager`

### Nice-to-Haves
- [ ] Client-side `imageCount` bounds assertion in `GenerationOptionsModel`
- [ ] Negative balance UI clamp in credit display
- [ ] Email TLD validation in auth form

### Phase 1: Backend Hardening
**Status**: ✅ Complete
**Objective**: Add rate limiting, server-side input validation, and storage cleanup to `generate-image` Edge Function
- Rate limiting: per-user sliding window (e.g., max N requests per minute)
- Validate `imageCount` param is integer in [1, 4] range
- Add cleanup logic for orphaned storage files when `mirrorUrlsToStorage` fails mid-sequence

### Phase 2: Client Resilience
**Status**: ⬜ Not Started
**Objective**: Add reconnection logic, client-side validations, and UI safety guards
- `GenerationJobManager`: auto-reconnect on realtime subscription disconnect
- `GenerationOptionsModel`: add `imageCount` bounds assertion (1–4)
- `CreditBalance` display: clamp negative values to 0
- Auth email validator: add TLD check

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
