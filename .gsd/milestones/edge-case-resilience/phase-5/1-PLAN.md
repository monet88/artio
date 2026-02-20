---
phase: 5
plan: 1
wave: 1
---

# Plan 5.1: Milestone Verification

## Objective
Verify the entire milestone: zero analyzer issues, full test suite passes (Flutter + Deno), and all must-haves are delivered.

## Context
- All phases 1-4 should be complete before this runs
- Must-haves from ROADMAP.md:
  1. 🔴 Unit test for ImagePickerNotifier >10MB rejection path
  2. AdMob ID build flavor switching
  3. Edge Function integration tests

## Tasks

<task type="auto">
  <name>Run full verification suite</name>
  <files>N/A</files>
  <action>
    Run in sequence:
    1. `flutter analyze` — expect zero issues
    2. `flutter test` — expect all tests pass
    3. `deno test supabase/functions/_shared/` — expect all Deno tests pass
    4. `deno task check` (from supabase/functions/) — expect type-check passes

    Capture output of each command.
  </action>
  <verify>flutter analyze && flutter test</verify>
  <done>Zero analyzer issues. All Flutter tests pass. All Deno tests pass. Deno type-check clean.</done>
</task>

<task type="auto">
  <name>Create verification report</name>
  <files>.gsd/phases/phase-5/VERIFICATION.md</files>
  <action>
    Create verification report with evidence:

    ```markdown
    # Verification Report: Test Coverage & Production Readiness

    ## Must-Haves

    | Requirement | Status | Evidence |
    |-------------|--------|----------|
    | 🔴 ImagePickerNotifier >10MB test | ✅ | test output showing 4 new tests pass |
    | AdMob build flavor switching | ✅ | code review: kReleaseMode guard |
    | Edge Function integration tests | ✅ | deno test output showing 5+ new tests pass |

    ## Metrics
    - Flutter tests: {N} passing
    - Deno tests: {N} passing
    - Analyzer issues: 0
    ```

    Fill in actual numbers from step 1 output.
  </action>
  <verify>Test-Path .gsd/phases/phase-5/VERIFICATION.md</verify>
  <done>Verification report created with empirical evidence.</done>
</task>

## Success Criteria
- [ ] `flutter analyze` — 0 issues
- [ ] `flutter test` — all pass
- [ ] `deno test` — all pass
- [ ] VERIFICATION.md created with evidence
