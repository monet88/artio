---
phase: 2
plan: 1
wave: 1
---

# Plan 2.1: Edge Function Integration Tests — Credit & Premium Logic

## Objective
Add Deno integration tests for Edge Function business logic: credit refund retry, premium model enforcement, and concurrent request deduplication. These are the 3 critical paths identified in audit that lack automated tests.

## Context
- supabase/functions/generate-image/index.ts — Main Edge Function (649 lines)
- supabase/functions/_shared/model_config.ts — PREMIUM_MODELS, MODEL_CREDIT_COSTS
- supabase/functions/_shared/model_config_test.ts — Existing Deno tests (8 tests, pattern reference)
- Key functions to test: `refundCreditsOnFailure`, `checkAndDeductCredits`, premium enforcement block (line 534-548), dedup check (line 518-524)

## Tasks

<task type="auto">
  <name>Extract testable logic into shared module</name>
  <files>supabase/functions/_shared/credit_logic.ts</files>
  <action>
    Extract the pure logic functions from `index.ts` into a testable shared module:

    1. Extract `checkAndDeductCredits` — wraps `supabase.rpc("deduct_credits")`, returns `{ success, error? }`
    2. Extract `refundCreditsOnFailure` — retry loop with exponential backoff, logs `[CRITICAL]` on exhaustion

    These functions take a Supabase client as parameter, making them injectable/mockable.

    Move them to `_shared/credit_logic.ts` and re-export from there. Update `index.ts` to import from `_shared/credit_logic.ts`.

    **Do NOT** change any behavior — pure mechanical extraction.
  </action>
  <verify>deno check supabase/functions/generate-image/index.ts</verify>
  <done>Functions extracted, index.ts imports from _shared/credit_logic.ts, type-check passes.</done>
</task>

<task type="auto">
  <name>Write integration tests for credit & premium logic</name>
  <files>supabase/functions/_shared/credit_logic_test.ts</files>
  <action>
    Create Deno tests for extracted functions:

    1. **refundCreditsOnFailure succeeds on first attempt** — Mock supabase.rpc to succeed. Assert `{ success: true, attempts: 1 }`.
    2. **refundCreditsOnFailure retries and succeeds on 2nd attempt** — Mock rpc to fail once then succeed. Assert `{ success: true, attempts: 2 }`.
    3. **refundCreditsOnFailure exhausts retries** — Mock rpc to always fail. Assert `{ success: false, attempts: 3 }`. Verify `[CRITICAL]` log.
    4. **checkAndDeductCredits returns insufficient** — Mock rpc to return `false`. Assert `{ success: false, error: "Insufficient credits" }`.
    5. **checkAndDeductCredits handles RPC error** — Mock rpc to return error. Assert `{ success: false }`.

    Use a mock Supabase client object with mock `rpc` method.

    Follow same test pattern as `model_config_test.ts` (use `jsr:@std/assert`).
  </action>
  <verify>deno test supabase/functions/_shared/credit_logic_test.ts</verify>
  <done>All 5 test cases pass.</done>
</task>

## Success Criteria
- [ ] `credit_logic.ts` contains extracted functions
- [ ] `index.ts` imports from shared module (no behavior change)
- [ ] 5+ new Deno tests pass for credit/refund logic
- [ ] Existing 8 Deno tests still pass
