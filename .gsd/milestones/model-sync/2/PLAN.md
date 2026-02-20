---
phase: 2
plan: 1
wave: 1
---

# Plan 2: Edge Function Unit Tests

## Objective
Install Deno, extract testable logic from `index.ts` into a shared module, and write unit tests for `refundCreditsOnFailure` retry logic and premium model check logic.

## Context
- `supabase/functions/generate-image/index.ts` — Main Edge Function (L138-182: refund, L480-493: premium check)
- `supabase/functions/generate-image/deno.json` — Deno config (currently empty imports)
- `.gsd/DECISIONS.md` — Decision: unit tests with Deno test

## Approach
Extract PURE logic into `supabase/functions/_shared/model_config.ts`:
- `isPremiumModel(modelId)` — checks against PREMIUM_MODELS list
- `getModelCreditCost(modelId)` — returns cost or undefined
- `PREMIUM_MODELS` and `MODEL_CREDIT_COSTS` constants

These are pure functions with no Supabase dependency — easily testable.

`refundCreditsOnFailure` stays in `index.ts` because it depends on Supabase RPC. Testing retry logic requires mocking — defer to integration tests.

## Tasks

<task type="auto">
  <name>Install Deno</name>
  <files>N/A — system tool</files>
  <action>
    1. Install Deno via PowerShell: `irm https://deno.land/install.ps1 | iex`
    2. Verify: `deno --version`
  </action>
  <verify>deno --version — should print deno version</verify>
  <done>Deno CLI available in PATH</done>
</task>

<task type="auto">
  <name>Extract model config to shared module</name>
  <files>
    supabase/functions/_shared/model_config.ts (CREATE)
    supabase/functions/generate-image/index.ts (MODIFY — import from shared)
  </files>
  <action>
    1. Create `supabase/functions/_shared/model_config.ts` with:
       - `MODEL_CREDIT_COSTS` record (move from index.ts)
       - `PREMIUM_MODELS` array (move from index.ts)
       - `isPremiumModel(modelId: string): boolean`
       - `getModelCreditCost(modelId: string): number | undefined`
       - Keep ⚠️ SYNC comments
    2. Update `index.ts` to import from shared:
       `import { MODEL_CREDIT_COSTS, PREMIUM_MODELS, isPremiumModel, getModelCreditCost } from '../_shared/model_config.ts';`
    3. Replace inline `MODEL_CREDIT_COSTS[model]` with `getModelCreditCost(model)`
    4. Replace `(PREMIUM_MODELS as readonly string[]).includes(model)` with `isPremiumModel(model)`
    5. Delete the old inline constants from index.ts
  </action>
  <verify>
    deno check supabase/functions/generate-image/index.ts — no type errors
  </verify>
  <done>Constants and helpers extracted to shared module. index.ts imports from shared. No type errors.</done>
</task>

<task type="auto">
  <name>Write Deno tests for model config</name>
  <files>supabase/functions/_shared/model_config_test.ts (CREATE)</files>
  <action>
    1. Create test file using `Deno.test()` and `assertEquals` from std:
       - `isPremiumModel returns true for premium models` — test all 7 premium IDs
       - `isPremiumModel returns false for free models` — test 2-3 free model IDs
       - `getModelCreditCost returns correct cost` — test 3-4 known models
       - `getModelCreditCost returns undefined for unknown model`
       - `PREMIUM_MODELS and MODEL_CREDIT_COSTS have consistent keys` — all premium models have costs
       - `MODEL_CREDIT_COSTS has 16 entries` — matches Dart ai_models.dart count
    2. Run: `deno test supabase/functions/_shared/model_config_test.ts`
  </action>
  <verify>deno test supabase/functions/_shared/ — all tests pass</verify>
  <done>6+ tests pass covering premium check, cost lookup, and consistency.</done>
</task>

## Success Criteria
- [ ] Deno installed and available
- [ ] `model_config.ts` shared module with exported constants + helpers
- [ ] `index.ts` imports from shared module (no inline constants)
- [ ] `deno check` passes on index.ts
- [ ] 6+ Deno tests pass for model config logic
