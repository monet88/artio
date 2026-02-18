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

### Objectives
- [ ] CORS fix (Supabase Edge Functions)
- [ ] Widget extraction (break down large widgets)
- [ ] Architecture violations (fix layer boundary leaks)
- [ ] Test coverage improvement (target 80%+)

### Phases

_To be planned with `/plan`_

---

## Backlog

- [ ] Stripe integration for web payments
- [ ] Priority generation queue for subscribers
- [ ] Credit history / transaction log UI
- [ ] Subscription management settings page
- [ ] Referral / affiliate system
