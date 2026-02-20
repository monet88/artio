---
phase: 1
plan: 1
wave: 1
gap_closure: true
---

# Plan 1.1: Dead Code Cleanup & timingSafeEqual Fix

## Objective
Remove the unused `imagePickerProvider` dead code and fix the `revenuecat-webhook` `timingSafeEqual` type error so all Edge Functions pass `deno task check`.

## Context
- `.gsd/milestones/test-coverage-prod-readiness/VERIFICATION.md` — gap source
- `lib/features/create/presentation/providers/image_picker_provider.dart` — dead provider
- `test/features/create/presentation/providers/image_picker_provider_test.dart` — tests for dead provider
- `supabase/functions/revenuecat-webhook/index.ts` — timingSafeEqual L41
- `supabase/functions/deno.json` — check task excluding revenuecat-webhook

## Tasks

<task type="auto">
  <name>Remove dead imagePickerProvider</name>
  <files>
    lib/features/create/presentation/providers/image_picker_provider.dart
    test/features/create/presentation/providers/image_picker_provider_test.dart
  </files>
  <action>
    1. Grep codebase to confirm no widget/screen imports `image_picker_provider.dart`
    2. If zero external imports → delete both files (provider + test)
    3. If any imports found → wire properly instead (but grep shows 0)
    4. Run `flutter analyze` to confirm no broken imports
    5. Run `flutter test` to confirm no test regressions
  </action>
  <verify>
    - `grep -r "image_picker_provider" lib/` → 0 results
    - `flutter analyze` → 0 issues
    - `flutter test` → all pass (count will drop by 6)
  </verify>
  <done>No dead image picker provider code remains. Analyzer clean. Test suite passes.</done>
</task>

<task type="auto">
  <name>Fix revenuecat-webhook timingSafeEqual type error</name>
  <files>
    supabase/functions/revenuecat-webhook/index.ts
    supabase/functions/deno.json
  </files>
  <action>
    1. The issue: `crypto.subtle.timingSafeEqual` exists in Deno runtime but not in the TS type definitions.
    2. Fix: Cast `crypto.subtle` to `any` at the call site, or use `(crypto.subtle as any).timingSafeEqual(...)`.
       Alternative: use `/// <reference lib="deno.ns" />` if types support it.
    3. After fixing, add `revenuecat-webhook/index.ts` back to `deno.json` check task.
    4. Run `deno task check` to verify all 5 files pass.
  </action>
  <verify>
    - `deno task check` includes revenuecat-webhook → passes
    - `deno task test` → 15 tests pass
  </verify>
  <done>`deno task check` covers ALL Edge Functions including revenuecat-webhook. Zero type errors.</done>
</task>

## Success Criteria
- [ ] `image_picker_provider.dart` and test file deleted
- [ ] `flutter analyze` → 0 issues
- [ ] `flutter test` → all pass (651+ tests, minus the 6 deleted)
- [ ] `revenuecat-webhook/index.ts` type-checks clean
- [ ] `deno task check` covers all 5 Edge Function files
- [ ] `deno task test` → 15 pass
