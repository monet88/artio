# Milestone: Edge Case Fixes (Phase 2)

## Completed: 2026-02-20

## Goal
Fix 7 edge cases identified during parallel code review to harden auth, credit system, and edge function reliability.

## Deliverables
- ✅ Auth input validation — empty email/password blocked before network call
- ✅ OAuth timeout — stuck authenticating state auto-recovers after 3 min
- ✅ Credit pre-check — generation blocked when balance < minimum cost (4 credits)
- ✅ Provider disposal — credit providers invalidated on logout
- ✅ Credit stream recovery — empty rows return default, errors don't kill stream
- ✅ Refund retry — 3x exponential backoff (2s, 4s, 8s) on refund failure
- ✅ Premium enforcement — server-side 403 for non-premium users on premium models

## Nice-to-Haves
- ⏭️ Session expiry check — deferred (Supabase auto-refresh sufficient)

## Phases Completed
| Phase | Name | Tasks | Tests | Verdict |
|-------|------|-------|-------|---------|
| 1 | Auth Fixes | 2 | +11 new | PASS (4/4) |
| 2 | Credit Fixes | 4 | +5 new | PASS (6/6) |
| 3 | Edge Function Fixes | 2 | N/A (TS) | PASS (6/6) |

## Metrics
| Metric | Value |
|--------|-------|
| Total commits | 22 |
| Files changed | 31 |
| Lines added | 2,218 |
| Lines removed | 191 |
| Net lines | +2,027 |
| Tests (full suite) | 638 passing |
| Analyzer errors | 0 |
| Gap closures | 0 |
| Duration | ~1 day |

## Key Changes

### Auth (Flutter/Dart)
- `auth_view_model.dart` — Input validation + OAuth 3-min timeout timer
- 11 new tests covering validation edge cases and timeout behavior

### Credits (Flutter/Dart)
- `CreditCheckPolicy` replaced stub `FreeBetaPolicy`
- `creditBalanceNotifierProvider` invalidated on logout
- `watchBalance()` stream resilience — empty rows → default, errors → Sentry
- 5 new policy tests

### Edge Function (TypeScript/Deno)
- `refundCreditsOnFailure()` — 3x retry with exponential backoff + CRITICAL log
- `PREMIUM_MODELS` enforcement — 403 before credit deduction

## Technical Debt Identified
- Edge Function integration tests needed
- PREMIUM_MODELS hardcoded in both Dart and TS
- No deno type-check CI
- Sentry alert rule for CRITICAL refund failures

## Audit
- Health: **GOOD**
- Full audit report: `.gsd/AUDIT.md`
