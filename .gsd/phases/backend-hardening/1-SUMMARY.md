# Plan 1.1 Summary: Rate Limiting & Input Validation

**Status:** ✅ Complete
**Date:** 2026-02-20

## What Was Done

### Task 1: Rate Limiting via Supabase RPC
- Created migration `20260220170000_create_rate_limit.sql`:
  - `generation_rate_limits` table (user_id, window_start, request_count)
  - `check_rate_limit` RPC — sliding window, 5 req/60s, SECURITY DEFINER
  - RLS enabled, revoked from authenticated/anon
- Added rate limit check to `generate-image/index.ts` after auth, before job ownership
- Returns 429 with `retry_after` when limit exceeded
- Fail-open design: allows request if RPC errors (non-blocking)

### Task 2: imageCount Server-Side Validation
- Added bounds check: `Number.isInteger(imageCount) && imageCount >= 1 && imageCount <= 4`
- Returns 400 with descriptive error for invalid values
- Check placed after body parsing, before job ownership

## Commits
- `a41e642` — `feat(phase-1): add rate limiting and imageCount validation to generate-image`

## Verification
- 640/640 Flutter tests passing ✅
- No client-side changes ✅
