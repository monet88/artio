---
plan: 3
wave: 1
pr: "fix(edge): refund retry logic and premium model enforcement"
---

# Plan 3: Edge Function Fixes

## Objective
Add retry logic to credit refund on generation failure and enforce premium
subscription requirement server-side for premium models. Both changes are in
the same Edge Function file (`generate-image/index.ts`).

## Context
- @plans/260220-0845-edge-case-fixes/plan.md — Full plan with code snippets
- @supabase/functions/generate-image/index.ts — Target file (544 lines)

## Tasks

<task type="auto">
  <name>Add retry logic to refundCreditsOnFailure</name>
  <files>supabase/functions/generate-image/index.ts</files>
  <action>
    Replace `refundCreditsOnFailure` function (lines 126-148) with retry version:

    1. Add `maxRetries: number = 3` parameter
    2. Change return type from `Promise<void>` to `Promise<{ success: boolean; attempts: number }>`
    3. Loop `attempt` from 1 to maxRetries:
       - Try RPC call
       - If RPC error: log, exponential backoff (`Math.pow(2, attempt) * 1000`ms), continue
       - If exception: log, same backoff, continue
       - If success: log with attempt count, return `{ success: true, attempts: attempt }`
    4. After loop exhausted: log CRITICAL with userId, amount, jobId, lastError
    5. Return `{ success: false, attempts: maxRetries }`

    All 4 existing call sites (search for `refundCreditsOnFailure`) await without
    consuming the return value — no call-site changes needed.

    DO NOT change the RPC parameters or the function name.
    DO NOT change the existing try-catch structure at call sites.
  </action>
  <verify>deno check supabase/functions/generate-image/index.ts</verify>
  <done>
    - refundCreditsOnFailure retries up to 3 times with exponential backoff
    - CRITICAL log emitted when all retries fail
    - All 4 call sites compile without changes
    - No type errors
  </done>
</task>

<task type="auto">
  <name>Add premium model enforcement before credit deduction</name>
  <files>supabase/functions/generate-image/index.ts</files>
  <action>
    Add premium check BEFORE the credit deduction block. Insert after the
    unknown model check (after line 443: `{ status: 400, ... }`), before
    the `checkAndDeductCredits` call (line 446):

    1. Define `PREMIUM_MODELS` array constant at module level (after MODEL_CREDIT_COSTS):
       ```
       const PREMIUM_MODELS = [
         'google/imagen4-ultra',
         'google/pro-image-to-image',
         'flux-2/pro-text-to-image',
         'flux-2/pro-image-to-image',
         'gpt-image/1.5-text-to-image',
         'gpt-image/1.5-image-to-image',
       ] as const;
       ```

    2. In the request handler, after the model validation check, add:
       - Check if model is in PREMIUM_MODELS
       - If yes: query `profiles` table for `is_premium` where `id = userId`
       - If NOT premium: return 403 with JSON `{ error, model, premiumRequired: true }`
       - If premium: continue to credit deduction

    Key: This check happens BEFORE `checkAndDeductCredits` — no credits
    are deducted, so no refund needed on premium denial.

    DO NOT move or modify the existing credit deduction logic.
    DO NOT change the PREMIUM_MODELS list without consulting ai_models.dart.
  </action>
  <verify>deno check supabase/functions/generate-image/index.ts</verify>
  <done>
    - PREMIUM_MODELS constant defined at module level
    - Premium check occurs BEFORE credit deduction
    - Non-premium user gets 403 with premiumRequired flag
    - No credits deducted on premium denial
    - No type errors
  </done>
</task>

## Success Criteria
- [ ] `deno check` passes on index.ts
- [ ] Refund retries 3x with exponential backoff before giving up
- [ ] Premium models blocked for non-premium users with 403
- [ ] No credits deducted when premium check fails
- [ ] Existing generation flow unchanged for non-premium models
