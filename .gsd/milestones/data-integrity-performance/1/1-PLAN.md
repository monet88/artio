---
phase: 1
plan: 1
wave: 1
---

# Plan 1.1: Sync Model Registry — App ↔ Edge Function

## Objective
Ensure 100% sync between `ai_models.dart` (Flutter app) and `generate-image/index.ts` (Supabase Edge Function). Every model that exists in one must exist in the other, with matching IDs and credit costs. `getProvider()` must explicitly route all models.

## Context
- `.gsd/SPEC.md`
- `.gsd/ARCHITECTURE.md`
- `lib/core/constants/ai_models.dart` — App model registry (13 models)
- `supabase/functions/generate-image/index.ts` — Edge Function (KIE_MODELS, GEMINI_MODELS, MODEL_CREDIT_COSTS)

## Current State (Mismatches Found)

### Models in Edge Function but NOT in App:
1. `nano-banana-pro` — in KIE_MODELS + CREDIT_COSTS, no AiModelConfig
2. `gemini-3-pro-image-preview` — in GEMINI_MODELS + CREDIT_COSTS, no AiModelConfig (15 credits)
3. `gemini-2.5-flash-image` — in GEMINI_MODELS + CREDIT_COSTS, no AiModelConfig (8 credits)

### Models in App but NOT explicitly routed in Edge Function:
4. `google/pro-image-to-image` — in CREDIT_COSTS but not in KIE_MODELS (falls back to "kie" implicitly)
5. `flux-2/*` (4 models) — same
6. `gpt-image/*` (2 models) — same
7. `seedream/*` (2 models) — same

## Tasks

<task type="auto">
  <name>Add missing models to app AiModels</name>
  <files>lib/core/constants/ai_models.dart</files>
  <action>
    Add 3 missing AiModelConfig entries:

    1. `nano-banana-pro` — displayName: "Nano Banana Pro", isPremium: false, creditCost: 10, type: "text-to-image", supportedAspectRatios: standardAspectRatios
    2. `gemini-3-pro-image-preview` — displayName: "Gemini 3 Pro Image", isPremium: true, creditCost: 15, type: "text-to-image", supportedAspectRatios: standardAspectRatios, isNew: true
    3. `gemini-2.5-flash-image` — displayName: "Gemini 2.5 Flash Image", isPremium: false, creditCost: 8, type: "text-to-image", supportedAspectRatios: standardAspectRatios, isNew: true

    Place Gemini models in a new "// Gemini Native Models" section after Seedream.
    Place `nano-banana-pro` next to existing `nano-banana-edit` in the Google/Imagen section.

    DO NOT change any existing model entries — only add new ones.
  </action>
  <verify>
    dart analyze lib/core/constants/ai_models.dart
    Verify: 16 total AiModelConfig entries (was 13)
  </verify>
  <done>
    - ai_models.dart has 16 AiModelConfig entries
    - All 3 new models compile without errors
    - Credit costs match MODEL_CREDIT_COSTS in index.ts
  </done>
</task>

<task type="auto">
  <name>Fix Edge Function getProvider() to explicitly route all models</name>
  <files>supabase/functions/generate-image/index.ts</files>
  <action>
    Update KIE_MODELS array to include ALL KIE-routed models explicitly:
    - Keep existing: "google/imagen4", "google/imagen4-fast", "google/imagen4-ultra", "nano-banana-pro", "google/nano-banana-edit"
    - Add: "google/pro-image-to-image", "flux-2/flex-text-to-image", "flux-2/flex-image-to-image", "flux-2/pro-text-to-image", "flux-2/pro-image-to-image", "gpt-image/1.5-text-to-image", "gpt-image/1.5-image-to-image", "seedream/4.5-text-to-image", "seedream/4.5-edit"

    This makes getProvider() routing explicit instead of relying on fallback.

    DO NOT change MODEL_CREDIT_COSTS — it's already correct.
    DO NOT change GEMINI_MODELS — it's already correct.
    DO NOT change any function logic — only the KIE_MODELS array.
  </action>
  <verify>
    Manually verify: every key in MODEL_CREDIT_COSTS appears in KIE_MODELS or GEMINI_MODELS.
    KIE_MODELS (14) + GEMINI_MODELS (2) covers all 15 MODEL_CREDIT_COSTS keys (nano-banana-pro overlaps).
  </verify>
  <done>
    - KIE_MODELS contains all non-Gemini models
    - getProvider() never hits the fallback "kie" return for a valid model
    - No functional change to generation flow
  </done>
</task>

<task type="checkpoint:human-verify">
  <name>Verify model sync completeness</name>
  <files>lib/core/constants/ai_models.dart, supabase/functions/generate-image/index.ts</files>
  <action>
    Cross-check:
    1. Every model ID in AiModels.all exists as a key in MODEL_CREDIT_COSTS
    2. Every key in MODEL_CREDIT_COSTS has a corresponding AiModelConfig
    3. Credit costs match between app and Edge Function
    4. Every MODEL_CREDIT_COSTS key is in KIE_MODELS or GEMINI_MODELS
    5. Run `flutter analyze` to confirm 0 issues
  </action>
  <verify>flutter analyze</verify>
  <done>
    - 1:1 mapping between app models and Edge Function models
    - Credit costs match
    - flutter analyze: No issues found
  </done>
</task>

## Success Criteria
- [ ] App `AiModels.all` has 16 entries matching all MODEL_CREDIT_COSTS keys
- [ ] Edge Function `KIE_MODELS` + `GEMINI_MODELS` covers all MODEL_CREDIT_COSTS keys explicitly
- [ ] Credit costs match between `ai_models.dart` and `index.ts`
- [ ] `flutter analyze`: No issues found
- [ ] No functional change to existing generation flow
