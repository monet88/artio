# ROADMAP.md

> **Current Milestone**: Freemium Monetization
> **Goal**: Remove login wall, implement credit-based economy with rewarded ads and subscriptions

---

## Completed Milestones

### Edge Case Fixes (Phase 1) ✅
- DateTime parsing, concurrent sign-in guards, profile TOCTOU race, 429 retry, timeout, TLS retry, router notify, file error handling
- 5 plans, 8 tasks, 453 tests passing

### Codebase Improvement (Phase 2) ⬜
- CORS fix, widget extraction, architecture violations, test coverage
- Status: PENDING (deferred — not blocking new milestone)

---

## Current Milestone: Freemium Monetization

### Must-Haves (from SPEC)
- [ ] Remove login wall — app opens directly to Home
- [ ] Credit system — all generation costs credits
- [ ] Rewarded ads — free users watch ads to earn credits
- [ ] Subscription tiers — Pro ($9.99) and Ultra ($19.99) via RevenueCat
- [ ] Premium gate — prompt login + subscribe when selecting premium model or out of credits
- [ ] Watermark on free tier images

### Nice-to-Haves
- [ ] Priority generation queue for subscribers
- [ ] Credit history / transaction log UI
- [ ] Subscription management settings page

---

## Phases

### Phase 1: Anonymous Auth & Remove Login Wall
**Status**: ⬜ Not Started
**Objective**: Enable anonymous Supabase auth, remove router login redirect, let users enter directly to Home screen
**Key Changes**:
- Add anonymous auth (Supabase anonymous sign-in)
- Modify `AuthViewModel.redirect()` — remove login wall for main routes
- Keep auth screens accessible but not mandatory
- Update `SplashScreen` flow → go to Home directly
- Refactor `AuthState` to support anonymous user state

### Phase 2: Credit System (Database + Backend)
**Status**: ⬜ Not Started
**Objective**: Build the credit ledger — DB tables, Edge Function credit checks, credit deduction logic
**Key Changes**:
- New Supabase migration: `user_credits` table (user_id, balance, updated_at)
- New Supabase migration: `credit_transactions` table (user_id, amount, type, created_at)
- Update `generate-image` Edge Function: check credits before generation, deduct on success
- Welcome bonus: insert 20 credits for new users (DB trigger or app logic)
- Daily ad tracking: `ad_views` table (user_id, date, count)

### Phase 3: Free Quota & Premium Gate UI
**Status**: ⬜ Not Started
**Objective**: Build the client-side credit system and premium gate modals
**Key Changes**:
- New feature: `credits/` (domain/data/presentation)
- Credit balance provider (watches `user_credits`)
- "Watch Ad or Subscribe" bottom sheet when credits insufficient
- Premium model gate: show subscription prompt when selecting `isPremium: true` model
- Credit cost display on generation button
- Deduct credits before calling Edge Function

### Phase 4: Google AdMob Rewarded Ads
**Status**: ⬜ Not Started
**Objective**: Integrate rewarded video ads for free credit earning
**Key Changes**:
- Configure AdMob for iOS + Android (ad unit IDs)
- Rewarded ad service (load, show, reward callback)
- Award 5 credits per completed ad view
- Enforce max 10 ads/day limit (local + server validation)
- "Watch Ad" button in credit-insufficient dialog and dedicated earn-credits section

### Phase 5: RevenueCat Subscription Integration
**Status**: ⬜ Not Started
**Objective**: Wire up RevenueCat for in-app purchases (Pro/Ultra subscriptions)
**Key Changes**:
- Configure RevenueCat (products, offerings, entitlements)
- Subscription service: purchase, restore, check entitlement
- On subscription: grant monthly credits (200 Pro / 500 Ultra)
- Hide ads for subscribers
- Paywall UI (subscription comparison screen)
- Handle subscription lifecycle (renewal, cancellation, grace period)

### Phase 6: Watermark, Polish & Testing
**Status**: ⬜ Not Started
**Objective**: Add watermark for free tier, polish flows, comprehensive testing
**Key Changes**:
- Watermark overlay on generated images for free users
- Remove watermark for subscribers
- End-to-end flow testing (anonymous → earn credits → generate → subscribe)
- Credit edge cases (concurrent generation, insufficient credits race)
- Update settings screen for subscription status display
- Update existing tests for new auth flow

---

## Dependencies

```
Phase 1 (Anonymous Auth) 
    ──► Phase 2 (Credit DB) 
        ──► Phase 3 (Credit UI + Premium Gate)
            ──► Phase 4 (AdMob)
            ──► Phase 5 (RevenueCat)
                ──► Phase 6 (Polish)
```

Phase 4 and Phase 5 can run in parallel after Phase 3.
