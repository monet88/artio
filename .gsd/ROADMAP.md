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

### Phase 1: CORS & Edge Function DRY
Extract duplicated CORS logic into `_shared/cors.ts`. Refactor `generate-image` and `reward-ad` to use it.
- **Plans:** 1.1
- **Discovery:** Level 0 (internal cleanup)

### Phase 2: Widget Extraction
Break 11 oversized files (>250 lines) into focused, single-responsibility components.
- **Plans:** 2.1 (theme), 2.2 (screens), 2.3 (gallery & misc)
- **Discovery:** Level 0 (pure refactoring)

### Phase 3: Architecture Violations
Fix 7 presentation→data layer violations and reduce cross-feature coupling.
- **Plans:** 3.1 (domain interfaces), 3.2 (shared providers)
- **Discovery:** Level 0 (internal refactoring)

### Phase 4: Test Coverage
Close test gaps in credits, subscription, settings, and core modules.
- **Plans:** 4.1 (credits & subscription), 4.2 (core & settings)
- **Discovery:** Level 0 (internal)

---

## Backlog

- [ ] Stripe integration for web payments
- [ ] Priority generation queue for subscribers
- [ ] Credit history / transaction log UI
- [ ] Subscription management settings page
- [ ] Referral / affiliate system
