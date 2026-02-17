---
phase: analysis-fixes
verified_at: 2026-02-17T21:57:00+07:00
verdict: PASS
---

# Phase analysis-fixes Verification Report

## Summary
9/9 must-haves verified

## Must-Haves

### ✅ 1. `dart fix --apply` applied — 0 auto-fixable remaining
**Status:** PASS
**Evidence:**
```
$ dart fix --dry-run
Computing fixes in artio (dry run)...
Nothing to fix!
```

### ✅ 2. 0 `avoid_catches_without_on_clauses` issues
**Status:** PASS
**Evidence:**
```
$ flutter analyze 2>&1 | grep "avoid_catches_without_on_clauses" | wc -l
0
```

### ✅ 3. 0 `cascade_invocations` issues
**Status:** PASS
**Evidence:**
```
$ flutter analyze 2>&1 | grep "cascade_invocations" | wc -l
0
```

### ✅ 4. 0 `avoid_print` issues
**Status:** PASS
**Evidence:**
```
$ flutter analyze 2>&1 | grep "avoid_print" | wc -l
0
```

### ✅ 5. 0 inference failure / `strict_raw_type` issues
**Status:** PASS
**Evidence:**
```
$ flutter analyze 2>&1 | grep -E "inference_failure|strict_raw_type" | wc -l
0
```

### ✅ 6. 0 `avoid_dynamic_calls` / `unawaited_futures` / `unused_*` / `avoid_positional_boolean` issues
**Status:** PASS
**Evidence:**
```
$ flutter analyze 2>&1 | grep -E "avoid_dynamic|unawaited|unused_|depend_on|avoid_positional" | wc -l
0
```

### ✅ 7. Total analysis issues ≤ 5
**Status:** PASS (exactly 5)
**Evidence:**
```
$ flutter analyze
Analyzing artio...

warning • The asset file '.env' doesn't exist • admin/pubspec.yaml:45:7 • asset_does_not_exist
   info • Unnecessary use of an abstract class • lib/features/template_engine/domain/policies/generation_policy.dart:5:16 • one_member_abstracts
   info • Dependencies not sorted alphabetically • pubspec.yaml:14:3 • sort_pub_dependencies
   info • Dependencies not sorted alphabetically • pubspec.yaml:66:3 • sort_pub_dependencies
   info • 'parent' is deprecated and shouldn't be used. • test/core/helpers/pump_app.dart:44:9 • deprecated_member_use

5 issues found. (ran in 2.9s)
```

**Remaining issues breakdown (all acceptable):**
| # | Issue | Justification |
|---|-------|---------------|
| 1 | `asset_does_not_exist` | Admin subproject — `.env` not committed to git |
| 2 | `one_member_abstracts` | Intentional clean architecture interface pattern |
| 3-4 | `sort_pub_dependencies` (×2) | Dependencies grouped by purpose with comments |
| 5 | `deprecated_member_use` | Riverpod `parent` — awaiting 3.0 upgrade |

### ✅ 8. No warnings or errors remain (in main app)
**Status:** PASS
**Evidence:** The single warning is in `admin/pubspec.yaml` (separate subproject), not the main artio app. 0 errors.

### ✅ 9. All tests pass
**Status:** PASS
**Evidence:**
```
$ flutter test --exclude-tags integration
00:17 +443: All tests passed!
```

## Verdict
**PASS** — All 9 must-haves verified with empirical evidence.

## Notes
- Reduced from 712 → 5 issues across 3 waves (auto-fix, manual catch/cascade, manual type/bool/misc)
- All remaining 5 issues are info-level or in admin subproject
- 443 tests pass with 0 regressions
