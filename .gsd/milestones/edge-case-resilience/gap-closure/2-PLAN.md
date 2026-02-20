---
phase: 1
plan: 2
wave: 2
gap_closure: true
---

# Plan 1.2: PREMIUM_MODELS Sync Validation

## Objective
Add automated validation to ensure `PREMIUM_MODELS` and `MODEL_CREDIT_COSTS` in Deno (`_shared/model_config.ts`) stay in sync with Dart (`lib/core/constants/ai_models.dart`). Currently only count-based checks exist (7 premium, 16 costs). Add model ID cross-validation.

## Context
- `lib/core/constants/ai_models.dart` — Dart source of truth (AiModel list with isPremium + creditCost)
- `supabase/functions/_shared/model_config.ts` — Deno source (PREMIUM_MODELS + MODEL_CREDIT_COSTS)
- `supabase/functions/_shared/model_config_test.ts` — existing count-based tests (8 tests)

## Tasks

<task type="auto">
  <name>Create sync validation script</name>
  <files>
    scripts/validate_model_sync.dart
  </files>
  <action>
    1. Create a Dart script at `scripts/validate_model_sync.dart`
    2. The script should:
       a. Import `ai_models.dart` and read `AiModel.all`
       b. Read `_shared/model_config.ts` as raw text
       c. Parse PREMIUM_MODELS array from the TS file (regex extract quoted strings between `PREMIUM_MODELS = [` and `] as const`)
       d. Parse MODEL_CREDIT_COSTS keys from the TS file (regex extract quoted strings from the object)
       e. Compare:
          - Dart premium model IDs (where isPremium == true) vs TS PREMIUM_MODELS
          - Dart model IDs vs TS MODEL_CREDIT_COSTS keys
          - Dart creditCost values vs TS credit cost values
       f. Exit 0 if all match, exit 1 with diff report if mismatch
    3. Keep it simple — pure Dart, no dependencies beyond dart:io and the project's ai_models.dart
  </action>
  <verify>
    - `dart run scripts/validate_model_sync.dart` → exit 0 with "All models in sync"
    - Intentionally break a model ID → script exits 1 with mismatch report
  </verify>
  <done>Sync validation script exists and passes. Drift between Dart and TS model configs is detectable automatically.</done>
</task>

<task type="auto">
  <name>Enhance Deno model tests with actual ID validation</name>
  <files>
    supabase/functions/_shared/model_config_test.ts
  </files>
  <action>
    1. Add test that validates specific PREMIUM_MODELS IDs match expected list (not just count)
    2. Add test that validates specific MODEL_CREDIT_COSTS keys match expected list
    3. This ensures if someone adds a model to one list but not the other, the test catches it
    4. Keep existing count-based tests as a sanity layer
  </action>
  <verify>
    - `deno task test` → all tests pass (15 + new ones)
  </verify>
  <done>Model config tests validate actual model IDs, not just counts. Drift is caught by tests.</done>
</task>

## Success Criteria
- [ ] `dart run scripts/validate_model_sync.dart` → exit 0
- [ ] `deno task test` → all pass with new ID-validation tests
- [ ] Intentionally breaking a model ID fails both validation script and Deno tests
