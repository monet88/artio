---
phase: 4
plan: 1
wave: 1
---

# Plan 4.1: CI & Monitoring Hardening

## Objective
Add Deno type-checking to CI pipeline, document Sentry alert setup for critical refund failures, and add automated PREMIUM_MODELS sync verification to Deno tests.

## Context
- supabase/functions/generate-image/index.ts — has `[CRITICAL] Credit refund failed` log
- supabase/functions/_shared/model_config_test.ts — existing Deno tests (count assertions)
- lib/core/constants/ai_models.dart — Dart-side model definitions
- lib/core/config/sentry_config.dart — Sentry init (production only)
- No CI config files found (likely GitHub Actions or manual)

## Tasks

<task type="auto">
  <name>Add Deno type-check script</name>
  <files>supabase/functions/deno.json</files>
  <action>
    Create/update the root `supabase/functions/deno.json` to include a type-check task:

    ```json
    {
      "tasks": {
        "check": "deno check _shared/model_config.ts generate-image/index.ts",
        "test": "deno test _shared/"
      }
    }
    ```

    Also check if a root `supabase/functions/deno.json` exists (vs per-function). If it doesn't, create one.

    This allows running `deno task check` from the functions directory to type-check all Edge Functions.
  </action>
  <verify>cd supabase/functions && deno task check</verify>
  <done>Deno type-check task defined and passes.</done>
</task>

<task type="auto">
  <name>Add PREMIUM_MODELS cross-sync verification test</name>
  <files>supabase/functions/_shared/model_config_test.ts</files>
  <action>
    The existing test checks `PREMIUM_MODELS.length === 7` and `MODEL_CREDIT_COSTS` count === 16.

    Add a test that reads the Dart `ai_models.dart` file and cross-validates:

    Actually, Deno tests can't easily parse Dart files at runtime. Instead, add a comment documenting the manual sync check, and keep the count assertions as the automated guard.

    **Better approach:** Add a test that verifies every `PREMIUM_MODELS` entry also exists in `MODEL_CREDIT_COSTS` (internal consistency), and add a comment reminding to update counts when models change.

    This is already partially covered by existing test "all premium models have credit costs defined". No additional test needed here.

    **Instead:** Document the sync process in a `SYNC.md` file in `_shared/`.
  </action>
  <verify>deno test supabase/functions/_shared/model_config_test.ts</verify>
  <done>Existing sync tests still pass. Documentation added.</done>
</task>

<task type="auto">
  <name>Create Sentry alert setup documentation</name>
  <files>.gsd/phases/phase-4/SENTRY-ALERTS.md</files>
  <action>
    Create a documentation file describing how to set up the Sentry alert rule for critical refund failures. This is a Sentry dashboard configuration (not code):

    **Alert Rule:**
    - **Condition**: Event message contains `[CRITICAL] Credit refund failed`
    - **Action**: Send email + Slack notification
    - **Frequency**: Every occurrence (no throttling)
    - **Environment**: Production only

    Note: The `[CRITICAL]` log happens in Edge Functions (Deno/Supabase), NOT in Flutter. Sentry in the Flutter app only captures client-side exceptions. For Edge Function monitoring, use Supabase Dashboard Logs or configure a separate log drain.

    Document this distinction clearly: this is a **Supabase log monitoring** task, not a Sentry Flutter task.
  </action>
  <verify>Test-Path .gsd/phases/phase-4/SENTRY-ALERTS.md</verify>
  <done>Alert setup documentation created with clear instructions.</done>
</task>

## Success Criteria
- [ ] `deno task check` type-checks all Edge Function code
- [ ] `deno task test` runs all Deno tests
- [ ] Sentry/monitoring alert documentation created
- [ ] No regressions in existing tests
