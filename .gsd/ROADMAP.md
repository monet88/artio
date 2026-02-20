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

### Edge Case Hardening ✅
- Rate limiting, server/client `imageCount` validation, realtime reconnections, email TLD validation, UI guards
- 2 phases, 4 plans, 10 commits, 651 tests passing

---

## Current Milestone: UI & Concurrency Polish

**Goal:** Handle remaining "Partial Handling" edge cases from the 2026-02-20 verification report related to UI UX components and concurrent behaviors.

### Must-Haves
- [ ] Concurrent request processing & credit deductions (deduplication & locks)
- [ ] Better error UX for Gallery (size validation, confirm deletes, pull-to-refresh)
- [ ] Refined Auth flows (OAuth cancel logic, safe password reset feedback)
- [ ] Resilient parsing (Missing template fields don't fail entire list)
- [ ] Adjust and verify 120s timeout expectation for AI provider polling

### Phase 1: Concurrency & Backend Limits
**Status**: ✅ Complete
**Objective**: Fix concurrent generation requests (deduplication), concurrent credit deductions (atomic UPDATE/INSERT), and Edge Function locking for job processing. Also refine KIE timeout logic.

### Phase 2: Auth & Template Resilience
**Status**: ⬜ Not Started
**Objective**: Detect and handle OAuth cancellation securely. Update password reset UX to not reveal email existence. Implement resilient parsing for Freezed template models (skip defective items rather than failing whole list).

### Phase 3: Gallery UX & Guards
**Status**: ⬜ Not Started
**Objective**: Add size validation for image uploads (>10MB). Implement manual pull-to-refresh for Gallery. Replace Delete undo with a explicit confirmation dialog.

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
