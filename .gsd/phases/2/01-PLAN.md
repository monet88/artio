---
phase: 2
plan: 1
wave: 1
depends_on: []
files_modified:
  - supabase/functions/generate-image/index.ts
autonomous: true
must_haves:
  truths:
    - "CORS response header uses specific origin, not wildcard"
    - "OPTIONS preflight returns correct CORS headers"
  artifacts:
    - "corsHeaders uses environment variable or specific origin"
---

# Plan 2.1: CORS Security Fix

<objective>
Fix overly permissive CORS configuration in the Edge Function.

Current: `Access-Control-Allow-Origin: *` (line 285)
Target: Restrict to app's actual origin

Purpose: Prevent unauthorized cross-origin requests to the image generation API.
Output: CORS headers locked to specific origin
</objective>

<context>
Load for context:
- supabase/functions/generate-image/index.ts (lines 1-20 for CORS headers, line 285 for usage)
- .gsd/ARCHITECTURE.md (Edge Function section)
</context>

<tasks>

<task type="auto">
  <name>Restrict CORS origin in Edge Function</name>
  <files>
    supabase/functions/generate-image/index.ts
  </files>
  <action>
    1. Find the CORS headers definition (near top of file):
       ```ts
       const corsHeaders = {
         'Access-Control-Allow-Origin': '*',
         // ...
       };
       ```

    2. Replace with environment-based origin:
       ```ts
       const allowedOrigin = Deno.env.get('CORS_ALLOWED_ORIGIN') ?? 'https://artio.app';
       const corsHeaders = {
         'Access-Control-Allow-Origin': allowedOrigin,
         'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
         'Access-Control-Allow-Methods': 'POST, OPTIONS',
       };
       ```

    3. Verify the OPTIONS preflight handler still works (should already exist):
       ```ts
       if (req.method === 'OPTIONS') {
         return new Response('ok', { headers: corsHeaders });
       }
       ```

    AVOID: Don't add multiple origins logic — the Edge Function is only called by one client (the Flutter app, which uses native HTTP, so CORS only matters for the admin web dashboard).
    AVOID: Don't change any other logic in the Edge Function.
  </action>
  <verify>
    grep -n "Access-Control-Allow-Origin" supabase/functions/generate-image/index.ts → should NOT show '*'
    grep -n "CORS_ALLOWED_ORIGIN" supabase/functions/generate-image/index.ts → should find env var
  </verify>
  <done>
    - CORS origin restricted to specific domain
    - Environment variable allows customization
    - Preflight still works
  </done>
</task>

</tasks>

<verification>
After all tasks, verify:
- [ ] No `'*'` in CORS headers
- [ ] CORS_ALLOWED_ORIGIN env var used
- [ ] OPTIONS handler intact
</verification>

<success_criteria>
- [ ] Cross-origin requests restricted to allowed origin
- [ ] Admin dashboard (web) still works with correct CORS
</success_criteria>
