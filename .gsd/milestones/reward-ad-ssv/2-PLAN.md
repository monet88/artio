---
phase: reward-ad-ssv
plan: 2
wave: 1
---

# Plan 2: Edge Function — Split reward-ad into 2 endpoints

## Objective
Refactor the `reward-ad` Edge Function from a single endpoint to two: `/reward-ad?action=request-nonce` and `/reward-ad?action=claim`. This makes the server enforce the 2-step nonce flow.

## Context
- .gsd/phases/reward-ad-ssv/RESEARCH.md (Option B flow)
- supabase/functions/reward-ad/index.ts (current single-endpoint implementation)
- .gsd/phases/reward-ad-ssv/1-PLAN.md (DB RPCs this depends on)

## Tasks

<task type="auto">
  <name>Refactor reward-ad Edge Function</name>
  <files>supabase/functions/reward-ad/index.ts</files>
  <action>
    Refactor the Edge Function handler to support two actions via query parameter `?action=`:

    **Action: `request-nonce` (POST)**
    1. Authenticate user via JWT (existing logic)
    2. Call `request_ad_nonce` RPC with user.id
    3. Return `{ success: true, nonce: "<uuid>" }` or `{ success: false, error: "daily_limit_reached" }`

    **Action: `claim` (POST)**
    1. Authenticate user via JWT (existing logic)
    2. Parse `nonce` from request body: `{ nonce: "<uuid>" }`
    3. Validate: nonce must be a non-empty string
    4. Call `claim_ad_reward` RPC with user.id + nonce
    5. Return result from RPC (same shape as current response)

    **Action: missing/invalid**
    - Return 400 with `{ error: "Invalid action. Use ?action=request-nonce or ?action=claim" }`

    **Implementation notes:**
    - Extract the shared JWT auth logic into a helper function at top of file to avoid duplication
    - Keep the same CORS handling
    - Keep the same error handling pattern (try/catch with JSON error responses)
    - DO NOT add a default fallback that calls the old `reward_ad_credits` — force all clients through the new flow
    - Log actions: `[reward-ad] request-nonce for ${user.id}` and `[reward-ad] claim for ${user.id}`
  </action>
  <verify>
    Run: `deno check supabase/functions/reward-ad/index.ts` (or `supabase functions serve reward-ad` to test locally)
  </verify>
  <done>
    - Edge Function accepts `?action=request-nonce` and `?action=claim`
    - request-nonce returns a nonce UUID
    - claim validates nonce and awards credits
    - Invalid/missing action returns 400 error
    - Auth logic is DRY (extracted to helper)
  </done>
</task>

## Success Criteria
- [ ] `reward-ad?action=request-nonce` returns nonce for authenticated user
- [ ] `reward-ad?action=claim` with valid nonce awards credits
- [ ] `reward-ad?action=claim` with invalid/expired/used nonce returns error
- [ ] Missing action parameter returns 400
- [ ] No TypeScript errors
