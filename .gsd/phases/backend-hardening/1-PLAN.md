---
phase: 1
plan: 1
wave: 1
---

# Plan 1.1: Rate Limiting & Input Validation

## Objective
Add per-user rate limiting and server-side `imageCount` bounds validation to the `generate-image` Edge Function. These are the two highest-priority fixes from the edge case review — rate limiting prevents API abuse, and imageCount validation prevents invalid requests.

## Context
- `.gsd/SPEC.md` — Credit economy, generation flow
- `.gsd/ARCHITECTURE.md` — Edge Function architecture, DB schema
- `plans/reports/review-260220-1533-edge-cases-verification.md` — Edge case #2 (rate limiting) and #4 (imageCount validation)
- `supabase/functions/generate-image/index.ts` — Target file (566 lines)
- `supabase/migrations/20260218000000_create_credit_system.sql` — Existing migration pattern
- `supabase/functions/_shared/model_config.ts` — Shared constants

## Tasks

<task type="auto">
  <name>Add rate limiting via Supabase RPC</name>
  <files>
    - supabase/migrations/20260220170000_create_rate_limit.sql (NEW)
    - supabase/functions/generate-image/index.ts
  </files>
  <action>
    1. Create SQL migration `20260220170000_create_rate_limit.sql`:
       - Create table `generation_rate_limits` with columns:
         - `user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE`
         - `window_start TIMESTAMPTZ NOT NULL DEFAULT now()`
         - `request_count INT NOT NULL DEFAULT 1`
         - PRIMARY KEY `(user_id)`
       - Enable RLS, no policies for `authenticated` (service_role only)
       - Create function `check_rate_limit(p_user_id UUID, p_max_requests INT DEFAULT 5, p_window_seconds INT DEFAULT 60)`:
         - UPSERT into `generation_rate_limits`
         - If existing row's `window_start` is older than `p_window_seconds`, reset counter to 1
         - If within window and `request_count < p_max_requests`, increment and return `{allowed: true, remaining: N}`
         - If at limit, return `{allowed: false, retry_after: seconds_until_window_expires}`
         - Use SECURITY DEFINER, revoke from authenticated

    2. In `generate-image/index.ts`, add rate limit check AFTER auth and BEFORE job ownership check (around L402-L420):
       - Call `check_rate_limit` RPC with userId
       - If `allowed === false`, return 429 with `{error: "Rate limit exceeded", retry_after: N}`
       - Use constants: `MAX_REQUESTS = 5`, `WINDOW_SECONDS = 60` (5 requests per minute)

    What to AVOID:
    - Do NOT use in-memory rate limiting (Edge Functions are stateless, won't persist)
    - Do NOT add Redis or external dependencies
    - Do NOT change the credit deduction flow — rate limit is a separate concern checked before credits
  </action>
  <verify>
    1. `supabase db diff` shows the new migration
    2. Deploy locally: `supabase functions serve generate-image`
    3. Manual curl test: 6th request within 60s returns 429
  </verify>
  <done>
    - `generation_rate_limits` table exists with RLS enabled
    - `check_rate_limit` RPC function exists and is SECURITY DEFINER
    - `generate-image` returns 429 when rate limit exceeded
    - 429 response includes `retry_after` field
  </done>
</task>

<task type="auto">
  <name>Add imageCount server-side bounds validation</name>
  <files>
    - supabase/functions/generate-image/index.ts
  </files>
  <action>
    1. After parsing `imageCount` from request body (L410), add validation:
       ```typescript
       // Validate imageCount bounds (1-4)
       if (!Number.isInteger(imageCount) || imageCount < 1 || imageCount > 4) {
         return new Response(
           JSON.stringify({ error: "imageCount must be an integer between 1 and 4" }),
           { status: 400, headers: { ...headers, "Content-Type": "application/json" } }
         );
       }
       ```
    2. Place this check right after the `!jobId || !prompt` validation (L415-420), before job ownership check
    3. Also validate `model` exists in either KIE_MODELS or GEMINI_MODELS array (currently only checked via `getModelCreditCost` which returns undefined for unknown models — this is already handled at L444, so no change needed)

    What to AVOID:
    - Do NOT change the client-side code — that's Phase 2
    - Do NOT modify the `GenerationRequest` interface — `imageCount` stays optional with default 1
  </action>
  <verify>
    1. `deno check supabase/functions/generate-image/index.ts` passes
    2. Manual curl: request with `imageCount: 0` returns 400
    3. Manual curl: request with `imageCount: 5` returns 400
    4. Manual curl: request with `imageCount: 2` proceeds normally
  </verify>
  <done>
    - `imageCount` validated as integer in [1, 4] range before any processing
    - Invalid values return 400 with descriptive error message
    - Default value of 1 still works when `imageCount` is omitted
  </done>
</task>

## Success Criteria
- [ ] Rate limit RPC `check_rate_limit` created and deployed
- [ ] `generate-image` returns 429 when user exceeds 5 requests/minute
- [ ] `imageCount` validated server-side: only integers 1-4 accepted
- [ ] Invalid `imageCount` returns 400 with clear error
- [ ] Existing Deno tests still pass: `deno test supabase/functions/_shared/`
- [ ] No changes to client-side code
