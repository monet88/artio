# ROADMAP.md

> **Current Milestone**: None — ready for next milestone
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

## Current Milestone

No active milestone. Run `/new-milestone` to start.

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
