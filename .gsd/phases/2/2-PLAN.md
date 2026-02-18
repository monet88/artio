---
phase: 2
plan: 2
wave: 2
depends_on: ["2.1"]
files_modified:
  - supabase/functions/generate-image/index.ts
autonomous: true
user_setup: []

must_haves:
  truths:
    - "Edge Function checks user credit balance before starting generation"
    - "Edge Function returns HTTP 402 with clear error when credits are insufficient"
    - "Edge Function deducts credits (via deduct_credits function) BEFORE calling AI provider"
    - "Edge Function refunds credits (via refund_credits function) if generation fails"
    - "Credit deduction amount matches model's creditCost from the request"
    - "Existing generation flow (auth, job ownership, KIE/Gemini routing) is unchanged"
  artifacts:
    - "supabase/functions/generate-image/index.ts contains credit check logic"
---

# Plan 2.2: Edge Function Credit Enforcement

<objective>
Add credit checking and deduction to the generate-image Edge Function. Users must have sufficient credits before generation starts, credits are deducted upfront, and refunded if generation fails.

Purpose: This is the server-side enforcement — the single source of truth for credit deduction. Client-side checks are advisory; this prevents abuse.
Output: Updated index.ts with credit enforcement integrated into the generation flow.
</objective>

<context>
Load for context:
- .gsd/SPEC.md — Credit economy rules
- supabase/functions/generate-image/index.ts — Current Edge Function (auth + job ownership + KIE/Gemini routing)
- supabase/migrations/20260218000000_create_credit_system.sql — Credit tables and helper functions (deduct_credits, refund_credits)
- lib/core/constants/ai_models.dart — Client-side model configs with creditCost values (for reference)
</context>

<tasks>

<task type="auto">
  <name>Add credit check and deduction logic to Edge Function</name>
  <files>supabase/functions/generate-image/index.ts</files>
  <action>
    Note: `creditCost` is NOT required in the client request — the server ignores client-sent values and uses its own MODEL_CREDIT_COSTS map.

    Add a server-side model→cost lookup map as a safety net:
    ```typescript
    const MODEL_CREDIT_COSTS: Record<string, number> = {
      "google/imagen4": 6,
      "google/imagen4-fast": 4,
      "google/imagen4-ultra": 12,
      "google/nano-banana-edit": 10,
      "nano-banana-pro": 10,
      // ... all models from ai_models.dart
    };
    ```
    Use the server-side map as the authoritative source. If client sends creditCost, ignore it — use the server map. If model not found in map, reject with 400.

    Add two new async functions that call the Postgres helper functions via the service-role Supabase client:

    **`checkAndDeductCredits(supabase, userId, amount, jobId)`**
    - Calls: `supabase.rpc('deduct_credits', { p_user_id: userId, p_amount: amount, p_description: 'Image generation', p_reference_id: jobId })`
    - Returns `{ success: true }` or `{ success: false, error: 'Insufficient credits' }`

    **`refundCreditsOnFailure(supabase, userId, amount, jobId)`**
    - Calls: `supabase.rpc('refund_credits', { p_user_id: userId, p_amount: amount, p_description: 'Generation failed — refund', p_reference_id: jobId })`
    - Logs the refund but does not throw on error (best-effort refund)

    AVOID: Implementing credit logic with raw SQL in the Edge Function — use the Postgres RPC functions for atomicity.
    AVOID: Trusting the client-sent creditCost — always use the server-side MODEL_CREDIT_COSTS map.
    AVOID: Changing the GenerationRequest to require creditCost — keep it optional since the server ignores it.
  </action>
  <verify>
    Read the Edge Function file and verify:
    - MODEL_CREDIT_COSTS map exists with all model IDs
    - checkAndDeductCredits function calls supabase.rpc('deduct_credits')
    - refundCreditsOnFailure function calls supabase.rpc('refund_credits')
  </verify>
  <done>
    - Server-side model cost map defined with all 13 models
    - checkAndDeductCredits and refundCreditsOnFailure functions implemented
    - Functions use Supabase RPC calls to Postgres helper functions
  </done>
</task>

<task type="auto">
  <name>Wire credit enforcement into main request handler</name>
  <files>supabase/functions/generate-image/index.ts</files>
  <action>
    Modify the main `Deno.serve` handler to integrate credit checking. Insert the credit logic AFTER job ownership verification and BEFORE the provider dispatch:

    1. **Resolve credit cost** from MODEL_CREDIT_COSTS using the `model` parameter
       - If model not in map → return 400 "Unknown model"

    2. **Deduct credits** by calling `checkAndDeductCredits(supabase, userId, creditCost, jobId)`
       - If deduction fails → return 402 JSON: `{ error: "Insufficient credits", required: creditCost, model: model }`
       - Do NOT update job status to 'failed' for credit issues — the job stays 'pending'

    3. **On generation failure** (any provider error), call `refundCreditsOnFailure(supabase, userId, creditCost, jobId)` BEFORE returning the error response
       - This applies to: KIE task creation failure, KIE poll failure, Gemini API failure, storage upload failure

    4. **On success**, credits are already deducted — no additional action needed

    The updated flow in the handler becomes:
    ```
    Auth → Validate job → Resolve cost → Deduct credits → Update job to processing → Generate → (refund if failed) → Complete
    ```

    AVOID: Deducting credits after generation — SPEC requires upfront deduction.
    AVOID: Setting job status to 'failed' when credits are insufficient — the user might earn/buy credits and retry.
    AVOID: Throwing exceptions in the refund path — refund failures should be logged but not block the error response.
    AVOID: Changing the successful response format — existing client code depends on `{ success, jobId, storagePaths }`.
  </action>
  <verify>
    Deploy the Edge Function via Supabase MCP `deploy_edge_function` tool.
    Read back the deployed function to verify credit logic is present.

    Verify the flow by checking:
    ```
    grep -n "deduct_credits\|refund_credits\|402\|Insufficient credits\|MODEL_CREDIT_COSTS" supabase/functions/generate-image/index.ts
    ```
    Expect matches for all 5 patterns.
  </verify>
  <done>
    - Credit cost resolved from server-side map before generation
    - Credits deducted before provider dispatch
    - 402 response returned for insufficient credits with required amount
    - Credits refunded on any generation failure
    - Existing success/error response formats unchanged
    - Job stays 'pending' (not 'failed') on credit insufficiency
  </done>
</task>

</tasks>

<verification>
After all tasks, verify:
- [ ] Edge Function contains MODEL_CREDIT_COSTS map with all models
- [ ] Credits are checked and deducted BEFORE generation starts
- [ ] Insufficient credits returns HTTP 402
- [ ] Generation failures trigger credit refund
- [ ] Existing auth, job ownership, and provider routing logic is unchanged
- [ ] Response format for successful generation is unchanged
</verification>

<success_criteria>
- [ ] All verification checks pass
- [ ] Edge Function deploys successfully
- [ ] Credit enforcement uses server-side cost map (not client-sent values)
- [ ] Refund logic handles failures gracefully (logs, doesn't throw)
</success_criteria>
