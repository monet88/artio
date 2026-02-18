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
- [x] Remove login wall — app opens directly to Home
- [x] Credit system — all generation costs credits
- [x] Rewarded ads — free users watch ads to earn credits
- [x] Subscription tiers — Pro ($9.99) and Ultra ($19.99) via RevenueCat
- [x] Premium gate — prompt login + subscribe when selecting premium model or out of credits
- [x] Watermark on free tier images

### Nice-to-Haves
- [ ] Priority generation queue for subscribers
- [ ] Credit history / transaction log UI
- [ ] Subscription management settings page

---

## Phases

### Phase 1: Remove Login Wall & Auth Gate
**Status**: ✅ Complete
**Objective**: Remove router login redirect, let unauthenticated users browse freely, add auth gate at generation action
**Key Changes**:
- Modify `AuthViewModel.redirect()` — allow Home, template detail, Settings without login
- Update `SplashScreen` flow → go to Home directly (skip login)
- Auth gate: when tapping "Generate" → check login → if not logged in → show login/register
- Gallery tab: hidden or "Login to view" for unauthenticated users
- Settings: theme toggle works, show "Login" button when not authenticated
- No Supabase Anonymous Auth (ADR-003)
- Generation still works normally after login (credit system in Phase 2)

### Phase 2: Credit System (Database + Backend)
**Status**: ✅ Complete
**Objective**: Build the credit ledger — DB tables, Edge Function credit checks, credit deduction logic
**Key Changes**:
- New Supabase migration: `user_credits` table (user_id, balance, updated_at)
- New Supabase migration: `credit_transactions` table (user_id, amount, type, created_at)
- Update `generate-image` Edge Function: check credits before generation, deduct on success
- Welcome bonus: insert 20 credits for new users (DB trigger or app logic)
- Daily ad tracking: `ad_views` table (user_id, date, count)

### Phase 3: Free Quota & Premium Gate UI
**Status**: ✅ Complete
**Objective**: Build the client-side credit system and premium gate modals
**Key Changes**:
- New feature: `credits/` (domain/data/presentation)
- Credit balance provider (watches `user_credits`)
- "Watch Ad or Subscribe" bottom sheet when credits insufficient
- Premium model gate: show subscription prompt when selecting `isPremium: true` model
- Credit cost display on generation button
- Deduct credits before calling Edge Function

### Phase 4: Google AdMob Rewarded Ads
**Status**: ✅ Complete
**Objective**: Integrate rewarded video ads for free credit earning
**Key Changes**:
- Configure AdMob for iOS + Android (ad unit IDs)
- Rewarded ad service (load, show, reward callback)
- Award 5 credits per completed ad view
- Enforce max 10 ads/day limit (local + server validation)
- "Watch Ad" button in credit-insufficient dialog and dedicated earn-credits section

### Phase 5: RevenueCat Subscription Integration
**Status**: ✅ Complete
**Objective**: Wire up RevenueCat for in-app purchases (Pro/Ultra subscriptions)

### Phase 6: Watermark, Polish & Testing
**Status**: ✅ Complete (verified)
**Objective**: Add watermark for free tier, polish flows, comprehensive testing
**Key Changes**:
- Watermark overlay on generated images for free users
- Remove watermark for subscribers
- End-to-end flow testing (anonymous → earn credits → generate → subscribe)
- Credit edge cases (concurrent generation, insufficient credits race)
- Update settings screen for subscription status display
- Update existing tests for new auth flow

### Phase 7: PR #13 Review Fixes
**Status**: ✅ Complete
**Objective**: Fix all critical, important, and minor issues from the PR #13 code review
**Depends on**: Phase 6

**Tasks**:

**P1 — Critical**:
- [x] Populate `revenuecat_app_user_id` in profiles during auth flow (`auth_repository.dart`)
- [x] Fix RLS trigger: replace `current_setting('role')` with `current_setting('request.jwt.claim.role', true)` (`20260219000001_restrict_profiles_update_rls.sql`)
- [x] Use `profile.id` from DB lookup instead of raw `appUserId` in webhook RPC calls; early-return when no profile found (`revenuecat-webhook/index.ts`)

**P2 — Important**:
- [x] Early-return with 200 when webhook profile lookup fails (instead of proceeding silently)
- [x] Abstract `Package` SDK type out of domain interface (`i_subscription_repository.dart`)
- [x] Capture `_isFreeUser` once at start of `_download()`/`_share()` methods (`image_viewer_page.dart`)

**P3 — Minor**:
- [x] Narrow `_handlePurchase` catch from `on Object` to `on Exception` (`paywall_screen.dart`)
- [x] Simplify redundant error handling in `_handleRestore` (`paywall_screen.dart`)
- [x] Use constant-time comparison for webhook auth header (`revenuecat-webhook/index.ts`)

**Verification**:
- `dart analyze` clean
- All existing tests still pass
- New test: subscription repository data layer
- Manual: verify RLS trigger allows service_role updates

---

## Dependencies

```
Phase 1 (Anonymous Auth) 
    ──► Phase 2 (Credit DB) 
        ──► Phase 3 (Credit UI + Premium Gate)
            ──► Phase 4 (AdMob)
            ──► Phase 5 (RevenueCat)
                ──► Phase 6 (Polish)
                    ──► Phase 7 (PR Review Fixes)
```

Phase 4 and Phase 5 can run in parallel after Phase 3.
