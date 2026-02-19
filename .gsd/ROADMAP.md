# ROADMAP.md

> **Current Milestone**: Widget Cleanup
> **Goal**: Bring all remaining hand-written files under 250 lines

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

---

## Current Milestone: Widget Cleanup

### Must-Haves
- [ ] `app_component_themes.dart` ≤250 lines
- [ ] `home_screen.dart` ≤250 lines
- [ ] `create_screen.dart` ≤250 lines
- [ ] `register_screen.dart` ≤250 lines
- [ ] `flutter analyze` clean
- [ ] All tests pass

### Phase 1: Theme & Screen Extraction
**Status**: ⬜ Not Started
**Objective**: Extract sub-widgets from 4 oversized files (302, 270, 270, 252 lines)
- **Discovery:** Level 0 (pure refactoring, identical pattern to Plan 2.3)

---

## Backlog

- [ ] Stripe integration for web payments
- [ ] Priority generation queue for subscribers
- [ ] Credit history / transaction log UI
- [ ] Subscription management settings page
- [ ] Referral / affiliate system
- [ ] Replace test AdMob IDs with production IDs (TODO in rewarded_ad_service.dart)

