# ROADMAP.md

> **Current Milestone**: Codebase Improvement
> **Goal**: Fix CORS, extract widgets, resolve architecture violations, increase test coverage

---

## Completed Milestones

### Edge Case Fixes (Phase 1) ✅
- DateTime parsing, concurrent sign-in guards, profile TOCTOU race, 429 retry, timeout, TLS retry, router notify, file error handling
- 5 plans, 8 tasks, 453 tests passing

### Freemium Monetization ✅
- Remove login wall, credit system, rewarded ads, RevenueCat subscriptions, premium gate, watermark
- 7 phases, 530 tests passing
- All must-haves delivered, PR #13 merged

---

## Current Milestone: Codebase Improvement

### Phase 1: CORS & Edge Function DRY ✅
Extract duplicated CORS logic into `_shared/cors.ts`. Refactor `generate-image` and `reward-ad` to use it.
- **Plans:** 1.1 ✅
- **Discovery:** Level 0 (internal cleanup)

### Phase 2: Widget Extraction ✅
Break 11 oversized files (>250 lines) into focused, single-responsibility components.
- **Plans:** 2.1 ✅ 2.2 ✅ (2.3 deferred to backlog)
- **Discovery:** Level 0 (pure refactoring)

### Phase 3: Architecture Violations ✅
Fix 7 presentation→data layer violations and reduce cross-feature coupling.
- **Plans:** 3.1 ✅ 3.2 ✅
- **Discovery:** Level 0 (internal refactoring)


### Phase 4: Test Coverage ✅
Close test gaps in credits, subscription, settings, and core modules.
- **Plans:** 4.1 ✅ 4.2 ✅
- **Discovery:** Level 0 (internal)

### Phase 5: Fix All Analyzer Warnings ✅
Resolve all 4 warnings (severity 2) and 9 info-level hints (severity 3) from `flutter analyze`.
- **Plans:** 5.1 ✅
- **Discovery:** Level 0 (cleanup)

**Warnings (4):**
- `asset_does_not_exist` — `.env` in `admin/pubspec.yaml`
- `invalid_annotation_target` × 2 — `@JsonKey` in `credit_balance.dart` (Freezed pattern)
- `unused_field` — `_borderRadiusSm` in `app_theme.dart`

**Info hints (9):**
- `sort_pub_dependencies` × 2 — `pubspec.yaml`
- `deprecated_member_use` — `parent` in `pump_app.dart`
- `cascade_invocations` × 3 — test + source files
- `one_member_abstracts` — `GenerationPolicy` single-method abstract
- `eol_at_end_of_file` — `i_subscription_repository.dart`

---

## Backlog

- [ ] Stripe integration for web payments
- [ ] Priority generation queue for subscribers
- [ ] Credit history / transaction log UI
- [ ] Subscription management settings page
- [ ] Referral / affiliate system
- [ ] Widget extraction: 8 files >250 lines (deferred from Phase 2.3)
- [ ] Replace test AdMob IDs with production IDs (TODO in rewarded_ad_service.dart)
