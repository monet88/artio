# ROADMAP.md

> **Current Milestone**: Test Coverage & Production Readiness
> **Last Completed**: UI & Concurrency Polish (2026-02-20)

---

## Completed Milestones

### UI & Concurrency Polish ✅
- Concurrent request deduplication, atomic credits, OAuth cancel, template resilience, gallery UX, image size validation
- 4 phases, 17 commits, 478 tests passing, 0 analyzer issues

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

## Completed Milestones
- **Test Coverage & Production Readiness** — 2026-02-20 (tag: `test-coverage-prod-readiness`)
- **UI & Concurrency Polish** — 2026-02-20 (tag: `ui-concurrency-polish`)
- **Model Sync & Edge Function Tests** (tag: `model-sync`)
- **Data Integrity & Performance** (tag: `data-integrity-performance`)
- **Widget Cleanup** (tag: `widget-cleanup`)

---

## Current Milestone: Tech Debt Cleanup ✅

**Goal:** Dọn dead code, sync shared models, fix type errors — tất cả 🟡 gaps từ milestone audit.

### Phase 1: Gap Closure ✅
**Status**: ✅ Complete
**Deliverables:**
- Removed dead `imagePickerProvider` + test (0 external imports)
- Fixed `timingSafeEqual` type error, added `revenuecat-webhook` to `deno task check`
- Strengthened model sync tests: exact ID + cost validation (not count-only)

---

## Backlog

### Features
- [ ] Stripe integration for web payments
- [ ] Priority generation queue for subscribers
- [ ] Credit history / transaction log UI
- [ ] Subscription management settings page
- [ ] Referral / affiliate system

### Technical Debt
- [ ] 🟢 Sentry alert rule for `[CRITICAL] Credit refund failed` (docs in `.gsd/phases/phase-4/SENTRY-ALERTS.md`)
- [ ] 🟢 Replace AdMob placeholder IDs (`ca-app-pub-XXXXX`) with real production IDs from AdMob dashboard
- [ ] 🟢 `credit_logic.ts` uses `any` type — fix when Supabase SDK exposes better types

