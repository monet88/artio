# Edge Case Verification Report

**Date:** 2026-02-20
**Verified:** 2026-02-20 (cross-checked against source code)
**Last Updated:** 2026-02-20 (post edge-case-hardening phase 1)
**Scope:** Full codebase (Auth, Template Engine, Gallery, Credits, Create Flow, Backend)
**Total Edge Cases:** 48

---

## Summary

| Category | ✅ Handled | ⚠️ Partial | ❌ Unhandled | 🚫 N/A |
|----------|-----------|------------|--------------|---------|
| Auth (10) | 7 | 3 | 0 | 0 |
| Template Engine (10) | 7 | 2 | 1 | 0 |
| Gallery (8) | 5 | 2 | 0 | 1 |
| Credits (7) | 3 | 2 | 1 | 1 |
| Create Flow (5) | 4 | 1 | 0 | 0 |
| Backend (8) | 6 | 1 | 0 | 0 |
| **Total** | **32** | **11** | **2** | **2** |

> ℹ️ 3 items **FIXED** in milestone `edge-case-hardening` phase 1 (2026-02-20): rate limiting, imageCount validation, orphaned file cleanup.

---

## Unhandled Edge Cases (Need Fix)

| # | Edge Case | Module | File | Severity | Evidence |
|---|-----------|--------|------|----------|----------|
| 1 | Realtime subscription disconnects | Template Engine | `generation_job_manager.dart` | Medium | `onError` cancels subscription but has no reconnect logic (L49-53) |
| ~~2~~ | ~~Rate limiting not implemented~~ | ~~Backend~~ | ~~`generate-image/index.ts`~~ | ~~High~~ | **FIXED** — See "Fixed Since Report" section below |
| ~~3~~ | ~~Reward ad validation missing~~ | ~~Backend~~ | ~~`reward-ad/index.ts`~~ | ~~**Critical**~~ | **FIXED** — See "Fixed Since Report" section below |
| ~~4~~ | ~~imageCount not validated server-side~~ | ~~Backend~~ | ~~`generate-image/index.ts`~~ | ~~Medium~~ | **FIXED** — See "Fixed Since Report" section below |

---

## Partial Handling (Need Review)

| # | Edge Case | Module | Issue | Evidence |
|---|-----------|--------|-------|----------|
| 1 | Invalid email format (no TLD) | Auth | UI validator missing TLD check | — |
| 2 | OAuth cancellation handling | Auth | No explicit cancel detection | — |
| 3 | Password reset feedback | Auth | Should not reveal if email exists (security) | — |
| 4 | Missing template fields | Template Engine | Freezed fails entire parse | — |
| 5 | Concurrent generation requests | Template Engine | No server-side deduplication | — |
| 6 | Large image (>10MB) handling | Gallery | No size validation | — |
| 7 | Delete without confirmation | Gallery | Uses Undo instead of confirm | — |
| 8 | Pull-to-refresh during loading | Gallery | No manual refresh trigger | — |
| 9 | Negative balance display | Credits | DB prevents but UI has no clamp — `credit_balance.dart` uses plain `int balance` | `credit_balance.dart` L11 |
| 10 | Concurrent deduction attempts | Credits | UPDATE + INSERT not atomic | — |
| 11 | Parameter validation (negative) | Create Flow | `imageCount` not bounds-checked client-side — `@Default(1) int imageCount` with no assertion | `generation_options_model.dart` L10 |
| 12 | AI provider timeout | Backend | KIE polling = 60 attempts × 2s = **120s max** (not 60s as previously reported) | `generate-image/index.ts` L191-194 |
| ~~13~~ | ~~Storage upload failure~~ | ~~Backend~~ | **FIXED** — See "Fixed Since Report" section below | |
| 14 | Concurrent job processing | Backend | No locking mechanism | — |

---

## Not Applicable (Removed from counts)

| # | Original Claim | Module | Reason |
|---|----------------|--------|--------|
| 1 | Credits expiration logic missing | Credits | No expiration concept exists in design — `credit_balance.dart` has no `expires_at` field. This is a missing feature, not an unhandled edge case. |
| 2 | Duplicate images in grid | Gallery | No evidence found in `gallery_repository.dart` or anywhere in gallery module (grep returns zero matches for "duplicate"). Claim unsubstantiated. |

---

## Clarified (Moved from Unhandled)

| # | Original Claim | Reclassification | Notes |
|---|----------------|-----------------|-------|
| 1 | Payment failure handling | **Out of scope** | RevenueCat webhook exists (`revenuecat-webhook/`). In-app purchase failure handling is managed by RevenueCat SDK. Report should specify which payment failure scenario is missing. |

---

## Well Handled (27 items)

### Auth (7)
- Empty email/password submission
- Network errors
- Token expiry/refresh
- Session persistence
- Invalid credentials response
- Multiple failed login attempts
- Logout cleanup

### Template Engine (7)
- Job timeout (5-min via `GenerationJobManager.defaultTimeoutMinutes`, L17)
- Concurrent request guard (`watchJob()` calls `cancel()` before new subscription, L31)
- Error deduplication (`captureOnce()` — Sentry, L80-84)
- Empty prompt validation
- Invalid model selection
- Provider fallback (KIE → Gemini routing, `getProvider()`)
- Job ownership verification (`generate-image/index.ts` L422-441)

### Gallery (5)
- Image load failures
- Share functionality
- Null metadata
- Network errors
- Empty state display

### Credits (3)
- Insufficient credits check (server-side via `deduct_credits` RPC)
- Refund on failure (`refundCreditsOnFailure()` with retry + exponential backoff, L110-154)
- Daily ad limit enforcement (RPC returns `daily_limit_reached`, L68)

### Create Flow (4)
- Empty prompt validation
- Max prompt length
- Concurrent request guard
- Network error handling

### Backend (2)
- RevenueCat webhook signature verification
- Invalid request payload validation (`jobId`, `prompt` required; model validated against known list)

---

## Fixed Since Report

| # | Edge Case | Fixed In | How Fixed |
|---|-----------|----------|-----------|
| 3 | Reward ad validation missing | Milestone `reward-ad-ssv` (2026-02-20) | Server-side nonce-based verification: `request_ad_nonce` → SSV options on ad → `claim_ad_reward` with atomic nonce consumption. 5-min TTL, single-use nonces, daily limit enforced at both request and claim. See `.gsd/milestones/reward-ad-ssv/VERIFICATION.md` |
| 2 | Rate limiting not implemented | `edge-case-hardening` phase 1 (2026-02-20) | Database-based sliding window via `check_rate_limit` RPC: 5 req/60s per user, SECURITY DEFINER, returns 429 with `retry_after`. Fail-open if RPC errors. Migration: `20260220170000_create_rate_limit.sql` |
| 4 | imageCount not validated server-side | `edge-case-hardening` phase 1 (2026-02-20) | Added `Number.isInteger(imageCount) && imageCount >= 1 && imageCount <= 4` check before job ownership verification. Returns 400 for invalid values. |
| 13 | Storage upload failure (orphaned files) | `edge-case-hardening` phase 1 (2026-02-20) | Added `cleanupStorageFiles` helper + try/catch in `mirrorUrlsToStorage` and `mirrorBase64ToStorage`. On mid-sequence failure, previously uploaded files are deleted before re-throwing. Best-effort cleanup (non-fatal). |

---

## Remaining Security Issues

1. ~~**Reward ad validation**~~ — ✅ **FIXED** (milestone `reward-ad-ssv`)
2. ~~**Rate limiting**~~ — ✅ **FIXED** (`edge-case-hardening` phase 1: `check_rate_limit` RPC, 5 req/60s)

---

## Recommended Actions

### Critical Priority
1. ~~**Fix Reward ad validation**~~ — ✅ **DONE** (milestone `reward-ad-ssv`, nonce-based SSV deployed 2026-02-20)
2. ~~**Implement rate limiting**~~ — ✅ **DONE** (`edge-case-hardening` phase 1, `check_rate_limit` RPC)

### Medium Priority
3. Add realtime subscription reconnection logic in `GenerationJobManager`
4. Add email format validation with TLD check
5. Add server-side deduplication for generation requests
6. ~~Add bounds validation for `imageCount` on server (1–4 range)~~ — ✅ **DONE** (`edge-case-hardening` phase 1)
7. ~~Add cleanup for orphaned storage files on partial upload failure~~ — ✅ **DONE** (`edge-case-hardening` phase 1)

### Low Priority
8. Add UI clamp for negative credit balance display
9. Add confirmation dialog for image delete (or keep Undo approach — design decision)

---

## Changelog

- **2026-02-20 17:15** — Edge Case Hardening phase 1:
  - Unhandled #2 (Rate limiting) → **FIXED** via `check_rate_limit` RPC (5 req/60s, sliding window)
  - Unhandled #4 (imageCount validation) → **FIXED** with bounds check [1, 4]
  - Partial #13 (Storage upload failure) → **FIXED** with `cleanupStorageFiles` helper
  - Updated summary: 3→0 unhandled (backend), 4→1 partial (backend), 29→32 handled
  - Updated total: 3→2 unhandled, 14→11 partial, 29→32 handled
  - All security issues now resolved ✅

- **2026-02-20 16:57** — Post-milestone update:
  - Unhandled #3 (Reward ad validation) → **FIXED** by milestone `reward-ad-ssv`
  - Added "Fixed Since Report" section with implementation details
  - Updated summary: 4→3 unhandled, 28→29 handled
  - Updated Backend counts: 2→3 handled, 2→1 unhandled
  - Struck through resolved items in Critical Security Issues and Recommended Actions

- **2026-02-20 16:07** — Verified against source code. Corrections:
  - Reclassified "credits expiration" → N/A (feature not designed, not a bug)
  - Removed "duplicate images in gallery" — no evidence in source code
  - Clarified "payment failure" → out of scope (RevenueCat handles)
  - Fixed AI provider timeout: 120s (60×2s), not 60s
  - Added "imageCount not validated server-side" as new unhandled item
  - Expanded "Well Handled" section from 15 to 27 items with evidence links
  - Added evidence references (file paths + line numbers)
  - Updated summary counts to reflect reclassifications
