# ROADMAP.md

> **Current Milestone**: Code Health
> **Goal**: Fix all flutter analyze errors across main app + admin web

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

---

## Current Milestone: Code Health

### Must-Haves
- [ ] Admin web dependencies resolved (`flutter pub get`)
- [ ] Admin codegen up to date (`build_runner`)
- [ ] Fix `dart:io` in admin web (not available on web platform)
- [ ] Fix deprecated `Ref` warnings in main app
- [ ] `flutter analyze` clean (0 errors)

### Phase 1: Admin Web Fix
**Status**: ⬜ Not Started
**Objective**: Resolve dependencies, fix dart:io usage, run codegen

### Phase 2: Main App Warnings
**Status**: ⬜ Not Started
**Objective**: Fix deprecated Ref type annotations

### Phase 3: Verify
**Status**: ⬜ Not Started
**Objective**: flutter analyze clean, all tests pass

---

## Backlog

- [ ] Stripe integration for web payments
- [ ] Priority generation queue for subscribers
- [ ] Credit history / transaction log UI
- [ ] Subscription management settings page
- [ ] Referral / affiliate system
- [ ] Replace test AdMob IDs with production IDs (TODO in rewarded_ad_service.dart)
