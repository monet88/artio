# ROADMAP.md

> **Current Milestone**: Model Sync & Edge Function Tests
> **Goal**: Fix model config drift between Dart and TS, add unit tests for Edge Function logic
> **Last Completed**: Edge Case Fixes Phase 2 (2026-02-20)

---

## Completed Milestones

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

## Current Milestone: Model Sync & Edge Function Tests

**Goal**: Fix model config drift between Dart and TS, add unit tests for Edge Function logic.

### Must-Haves
- [ ] PREMIUM_MODELS synced — Dart `ai_models.dart` ↔ TS `index.ts` match 100%
- [ ] MODEL_CREDIT_COSTS synced — credit costs match between both sources
- [ ] Cross-reference comments in both files to prevent future drift
- [ ] Edge Function unit tests — `refundCreditsOnFailure` + premium check logic

### Nice-to-Haves
- [ ] Deno type-check CI step
- [ ] Sentry alert rule for CRITICAL refund

### Phases

#### Phase 1: Model Config Sync
**Status**: ✅ Complete
**Objective**: Fix 3 PREMIUM_MODELS mismatches, sync credit costs, add cross-reference comments

#### Phase 2: Edge Function Unit Tests
**Status**: ✅ Complete
**Objective**: Extract logic functions from index.ts, write Deno tests for refund retry + premium check

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
