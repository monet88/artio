# Milestone: Model Sync & Edge Function Tests

## Completed: 2026-02-20

## Deliverables
- ✅ PREMIUM_MODELS synced — Dart `ai_models.dart` ↔ TS `index.ts` (7 models match)
- ✅ MODEL_CREDIT_COSTS synced — all 16 credit costs match
- ✅ Cross-reference ⚠️ SYNC comments in both files
- ✅ Edge Function unit tests — 8 Deno tests for `isPremiumModel` + `getModelCreditCost`

## Phases Completed
1. Phase 1: Model Config Sync — 2026-02-20
2. Phase 2: Edge Function Unit Tests — 2026-02-20

## Metrics
- Total commits: 9
- Files changed: 5
- Duration: 1 day
- Tests: 638 Flutter + 8 Deno = 646 total

## Key Changes
- `lib/core/constants/ai_models.dart` — GPT Image models marked premium, SYNC comment added
- `supabase/functions/_shared/model_config.ts` — NEW: shared module with constants + helpers
- `supabase/functions/_shared/model_config_test.ts` — NEW: 8 Deno tests
- `supabase/functions/generate-image/index.ts` — imports from shared, uses helper functions
- Deno 2.6.10 installed as dev tool

## Bug Fixed
- GPT Image models (`gpt-image/1.5-*`) were incorrectly `isPremium: false` in Dart
  while TS correctly blocked them → client showed no premium badge → UX inconsistency

## Lessons Learned
- `/list-phase-assumptions` caught a critical assumption error BEFORE execution
- Model config should have a single source of truth (cross-ref comments are a stopgap)
- Deno install on Windows was smooth via `irm install.ps1`
