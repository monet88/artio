---
phase: 1
plan: 1
wave: 1
---

# Plan 1: Model Config Sync

## Objective
Fix 3 PREMIUM_MODELS mismatches between `ai_models.dart` (Dart client) and `index.ts` (Edge Function server). Add cross-reference comments to prevent future drift. Verify credit costs are already in sync.

## Context
- `lib/core/constants/ai_models.dart` — Client-side model config (source of truth for UI)
- `supabase/functions/generate-image/index.ts` — Server-side model config (L42-68)
- `.gsd/DECISIONS.md` — Decision: quick fix + cross-reference comments

## Drift Analysis (pre-computed)

| Model ID | Dart `isPremium` | TS `PREMIUM_MODELS` | Action |
|----------|:---:|:---:|--------|
| `gpt-image/1.5-text-to-image` | false | ✓ in list | **Remove from TS** (Dart is source of truth for premium) |
| `gpt-image/1.5-image-to-image` | false | ✓ in list | **Remove from TS** (Dart is source of truth for premium) |
| `gemini-3-pro-image-preview` | true | ✗ not in list | **Add to TS** (missing enforcement) |

Credit costs: All 16 models match ✅ — no changes needed.

## Decision: Which source is correct?

**Dart `ai_models.dart` is the source of truth** because:
- GPT Image models are expensive (15-18 credits) but NOT premium — they're available to all users
- Gemini 3 Pro IS premium (marked true in Dart) but was missing from TS enforcement

## Tasks

<task type="auto">
  <name>Fix PREMIUM_MODELS in index.ts</name>
  <files>supabase/functions/generate-image/index.ts</files>
  <action>
    1. Remove `gpt-image/1.5-text-to-image` and `gpt-image/1.5-image-to-image` from PREMIUM_MODELS array (L61-68)
    2. Add `gemini-3-pro-image-preview` to PREMIUM_MODELS array
    3. Add cross-reference comment above PREMIUM_MODELS:
       `// ⚠️ SYNC: Must match isPremium flags in lib/core/constants/ai_models.dart`
    4. Add cross-reference comment above MODEL_CREDIT_COSTS:
       `// ⚠️ SYNC: Must match creditCost values in lib/core/constants/ai_models.dart`
  </action>
  <verify>
    grep "PREMIUM_MODELS" supabase/functions/generate-image/index.ts
    — Should contain exactly 5 models: imagen4-ultra, pro-image-to-image, flux-2/pro-text-to-image, flux-2/pro-image-to-image, gemini-3-pro-image-preview
  </verify>
  <done>PREMIUM_MODELS in TS matches all isPremium:true entries in Dart. Cross-reference comment present.</done>
</task>

<task type="auto">
  <name>Add cross-reference comment in ai_models.dart</name>
  <files>lib/core/constants/ai_models.dart</files>
  <action>
    1. Add comment above `class AiModels`:
       `/// ⚠️ SYNC: isPremium flags and creditCost values must match`
       `/// supabase/functions/generate-image/index.ts (PREMIUM_MODELS + MODEL_CREDIT_COSTS)`
    2. Do NOT change any model data — Dart is already correct.
  </action>
  <verify>
    grep "SYNC" lib/core/constants/ai_models.dart
    — Should find cross-reference comment
  </verify>
  <done>Cross-reference comment present in ai_models.dart pointing to index.ts.</done>
</task>

## Success Criteria
- [ ] PREMIUM_MODELS has exactly 5 entries matching Dart isPremium:true
- [ ] MODEL_CREDIT_COSTS unchanged (already in sync)
- [ ] Cross-reference comments in both files
- [ ] `deno check` passes on index.ts (if available) OR no syntax errors
- [ ] `flutter analyze` passes on ai_models.dart
