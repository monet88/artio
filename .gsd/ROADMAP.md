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
- [x] `app_component_themes.dart` ≤250 lines (228 → extracted button themes)
- [x] `home_screen.dart` ≤250 lines (160 → extracted widgets)
- [x] `create_screen.dart` ≤250 lines (246 → extracted overlay widget)
- [x] `register_screen.dart` ≤250 lines (248 → trimmed spacing)
- [x] `flutter analyze` clean
- [x] All tests pass (606/606)

### Phase 1: Theme & Screen Extraction
**Status**: ✅ Complete
**Objective**: Extract sub-widgets from oversized files
- **Discovery:** Level 0 (pure refactoring)
- Extracted `AppButtonThemes` from `app_component_themes.dart` (302 → 228)
- Extracted `GenerationStartingOverlay` from `create_screen.dart` (270 → 246)
- Extracted `TemplateCountBadge` + `CategoryChips` from `home_screen.dart` (270 → 160)
- Trimmed blank lines in `register_screen.dart` (253 → 248)

---

## Backlog

- [ ] Stripe integration for web payments
- [ ] Priority generation queue for subscribers
- [ ] Credit history / transaction log UI
- [ ] Subscription management settings page
- [ ] Referral / affiliate system
- [ ] Replace test AdMob IDs with production IDs (TODO in rewarded_ad_service.dart)

