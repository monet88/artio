---
milestone: Test Coverage & Production Readiness
verified: 2026-02-20T20:33+07:00
status: passed
score: 3/3 must-haves verified
is_re_verification: true
---

# Milestone Verification: Test Coverage & Production Readiness

## Must-Haves

### Truths
| Truth | Status | Evidence |
|-------|--------|----------|
| 🔴 ImagePickerNotifier >10MB rejection has unit test | ✓ VERIFIED | `flutter test test/.../image_picker_provider_test.dart` → `+6: All tests passed!` Test at L43 sends 11MB via `_MockFileOverrides`, asserts error message "Image is too large. Maximum size is 10MB." and `pickedImage == null`. Closes audit gap from UI & Concurrency Polish AUDIT.md L55. |
| AdMob IDs switch between test/prod by build mode | ✓ VERIFIED | `rewarded_ad_service.dart` L19-25: `_adUnitId` getter checks `kReleaseMode` → returns test IDs in debug, prod IDs in release. `_adUnitId` consumed at L78 in `loadAd()`. |
| Edge Function credit logic has integration tests | ✓ VERIFIED | `deno task test` → `ok | 15 passed | 0 failed`. 7 new tests in `credit_logic_test.ts` covering: deduct success, insufficient credits, RPC error, refund 1st attempt, retry success, exhausted retries + CRITICAL log, thrown exception handling. |

### Artifacts
| Path | Exists | Substantive | Wired |
|------|--------|-------------|-------|
| `test/.../image_picker_provider_test.dart` | ✓ | ✓ (125 lines, 6 tests, IOOverrides for File.length mock) | ✓ (imports `image_picker_provider.dart`, tests `ImagePickerNotifier`) |
| `supabase/functions/_shared/credit_logic.ts` | ✓ | ✓ (85 lines, 2 exported functions with retry + backoff) | ✓ (imported at `index.ts` L5, called at L481, L506, L520, L537, L563) |
| `supabase/functions/_shared/credit_logic_test.ts` | ✓ | ✓ (80 lines, 7 Deno tests with mock Supabase) | ✓ (imports from `./credit_logic.ts`) |
| `supabase/functions/deno.json` | ✓ | ✓ (check + test tasks) | ✓ (`deno task check` passes, `deno task test` passes) |
| `lib/core/services/rewarded_ad_service.dart` | ✓ | ✓ (kReleaseMode gate, QA docs in docstring) | ✓ (`_adUnitId` used at L78 in `RewardedAd.load`) |
| `lib/.../image_picker_provider.dart` | ✓ | ✓ (constructor injection for testability) | ⚠️ Provider defined but not imported by any UI widget (pre-existing — out of scope) |
| `.gsd/phases/phase-4/SENTRY-ALERTS.md` | ✓ | ✓ (47 lines, 3 setup options, response procedure) | N/A (documentation) |

### Key Links
| From | To | Via | Status |
|------|-----|-----|--------|
| `index.ts` | `credit_logic.ts` | `import { checkAndDeductCredits, refundCreditsOnFailure }` | ✓ WIRED |
| `credit_logic_test.ts` | `credit_logic.ts` | `import { checkAndDeductCredits, refundCreditsOnFailure }` | ✓ WIRED |
| `image_picker_provider_test.dart` | `image_picker_provider.dart` | `import 'package:artio/.../image_picker_provider.dart'` | ✓ WIRED |
| `rewarded_ad_service.dart` | `_adUnitId` | `adUnitId: _adUnitId` at L78 | ✓ WIRED |
| `deno.json` `check` task | all Edge Function files | `deno check` command | ✓ WIRED |

## Anti-Patterns Found
- ⚠️ **Placeholder AdMob IDs** — `ca-app-pub-XXXXX/YYYYY` in `rewarded_ad_service.dart` L16-17. Tracked in backlog, must be replaced before release. Protected by `kReleaseMode` gate so won't crash debug builds.
- ⚠️ **ImagePickerNotifier not consumed by UI** — `imagePickerProvider` defined at L54 but no widget imports `image_picker_provider.dart`. This is **pre-existing** (not introduced by this milestone). The provider was created in UI & Concurrency Polish Phase 3 but the UI wiring was done differently. Out of scope for this milestone.
- ⚠️ **`credit_logic.ts` uses `any` type** — `supabase: any` at L10, L41. Pragmatic workaround for Supabase client type mismatch, but loses type safety. Acceptable for now.
- ⚠️ **`revenuecat-webhook/index.ts`** excluded from `deno task check` due to pre-existing `timingSafeEqual` type error. Tracked in backlog.
- ⚠️ **SYNC comment drift** — `credit_logic.ts` L1 says "Must match lib/core/constants/ai_models.dart" but the file contains credit deduction/refund logic, not model definitions. Copy-paste from `model_config.ts`.

## Human Verification Needed
### 1. AdMob Flow (Pre-release)
**Test:** Build release APK and load a rewarded ad
**Expected:** Real ad unit loads (not test ad)
**Why human:** Requires physical device + real AdMob account
**When:** Before first production release

## Verdict
**STATUS: ✅ PASSED**

All 3 must-haves verified with empirical evidence. 5 warnings found — all are either pre-existing, tracked in backlog, or cosmetic. No blockers.

**Test evidence:**
- Flutter: `+6: All tests passed!` (image picker tests) / `+657: All tests passed!` (full suite)
- Deno: `ok | 15 passed | 0 failed` (7 credit + 8 model config)
- Analyzer: `No errors`
- Type-check: `deno task check` clean
