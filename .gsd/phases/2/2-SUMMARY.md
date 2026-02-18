# Plan 2.2 Summary: Edge Function Credit Enforcement

## Status: ✅ COMPLETE

## What Was Done

### Task 1: Add MODEL_CREDIT_COSTS map
- Added server-side authoritative `MODEL_CREDIT_COSTS` map with all 16 model costs
- Matches `ai_models.dart` client-side values — server is source of truth

### Task 2: Credit check & deduction before generation
- Added `checkAndDeductCredits()` function — calls `deduct_credits` RPC
- Returns `{ success: false }` on insufficient credits
- Responds with HTTP 402 + `{ error, required, model }` JSON
- Wired into main handler BEFORE generation begins

### Task 3: Refund on failure
- Added `refundCreditsOnFailure()` function — calls `refund_credits` RPC
- Best-effort: catches errors, logs but doesn't block error response
- Wired into all 3 failure paths: KIE create, KIE poll, Gemini generate

### Task 4: Unknown model rejection
- Added early return with HTTP 400 if model not found in `MODEL_CREDIT_COSTS`

### Task 5: Security hardening
- Fixed `function_search_path_mutable` warnings on all SECURITY DEFINER functions
- Set `search_path = public` on: `deduct_credits`, `refund_credits`, `handle_new_user`, `update_user_credits_updated_at`, `update_templates_updated_at`

## Verification Evidence
- Edge Function deployed successfully (slug: `generate-image`, status: ACTIVE)
- Security advisors: only 2 pre-existing warnings remain (intentional RLS, auth config)
- Flutter tests: 475/475 passing — no regressions

## Commit
- `2bf330c` — feat(phase-2): add credit enforcement to generate-image Edge Function
