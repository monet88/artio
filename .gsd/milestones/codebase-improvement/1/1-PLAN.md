---
phase: 1
plan: 1
wave: 1
---

# Plan 1.1: CORS & Edge Function DRY

## Objective
Extract duplicated CORS logic from `generate-image/index.ts` and `reward-ad/index.ts` into a shared
module `_shared/cors.ts`. Both functions inline identical CORS header construction and OPTIONS handling.
This plan centralises that into one importable helper, reducing duplication and making future
CORS changes a single-file edit.

> `revenuecat-webhook` intentionally has **no** CORS (server-to-server) — do NOT add CORS there.

## Context
- supabase/functions/generate-image/index.ts (lines 353-363 — CORS block)
- supabase/functions/reward-ad/index.ts (lines 14-24 — CORS block)
- .gsd/ARCHITECTURE.md

## Tasks

<task type="auto">
  <name>Create shared CORS module</name>
  <files>supabase/functions/_shared/cors.ts</files>
  <action>
    Create `supabase/functions/_shared/cors.ts` exporting:
    1. `corsHeaders()` — returns the standard headers object using `CORS_ALLOWED_ORIGIN` env var
       with fallback to `https://artio.app`
    2. `handleCorsIfPreflight(req: Request): Response | null` — returns a `200 "ok"` Response
       with CORS headers if `req.method === "OPTIONS"`, otherwise returns `null`

    - What to avoid: Do NOT include any business logic. Do NOT add headers that aren't already in
      the existing functions (keep `Allow-Headers: authorization, x-client-info, apikey, content-type`
      and `Allow-Methods: POST, OPTIONS`).
  </action>
  <verify>cat supabase/functions/_shared/cors.ts</verify>
  <done>File exists and exports both `corsHeaders` and `handleCorsIfPreflight`</done>
</task>

<task type="auto">
  <name>Refactor edge functions to use shared CORS</name>
  <files>
    supabase/functions/generate-image/index.ts
    supabase/functions/reward-ad/index.ts
  </files>
  <action>
    In both functions:
    1. Add `import { corsHeaders, handleCorsIfPreflight } from "../_shared/cors.ts";`
    2. Remove the inline `allowedOrigin` / `corsHeaders` constant and OPTIONS guard
    3. At the top of `Deno.serve` handler, add:
       ```ts
       const preflight = handleCorsIfPreflight(req);
       if (preflight) return preflight;
       ```
    4. Replace inline `corsHeaders` constant references with `corsHeaders()` function call
    5. Keep all existing response status codes and body unchanged

    - What to avoid: Do NOT change any business logic, error handling, or status codes.
      Do NOT touch `revenuecat-webhook/index.ts`.
  </action>
  <verify>grep -c "handleCorsIfPreflight" supabase/functions/generate-image/index.ts supabase/functions/reward-ad/index.ts</verify>
  <done>Both functions import from _shared/cors.ts; no inline CORS constants remain</done>
</task>

## Success Criteria
- [ ] `supabase/functions/_shared/cors.ts` exists and exports 2 functions
- [ ] `generate-image/index.ts` has zero inline CORS definitions
- [ ] `reward-ad/index.ts` has zero inline CORS definitions
- [ ] `revenuecat-webhook/index.ts` is unchanged
- [ ] All existing Flutter tests pass (`flutter test`)
