# Milestone Audit: UI & Concurrency Polish

**Audited:** 2026-02-20T18:46:18+07:00

## Summary

| Metric             | Value |
|--------------------|-------|
| Phases             | 3     |
| Plans executed     | 3     |
| Tasks completed    | 9     |
| Gap closures       | 0     |
| Technical debt (new) | 2   |
| Test suite         | 478 passing (0 failures) |
| Analyzer           | 0 errors, 5 warnings (pre-existing), 23 infos (pre-existing) |

## Must-Haves Status

| Requirement | Verified | Evidence |
|-------------|----------|----------|
| Concurrent request processing & credit deductions (deduplication & locks) | ✅ | Phase 1 VERIFICATION.md — Edge Function `status = 'pending'` guard + `uq_credit_transactions_generation_ref` unique index |
| Adjust and verify 120s timeout expectation for AI provider polling | ✅ | Phase 1 VERIFICATION.md — `Date.now()` 120s bounds + 10s `AbortController` per fetch |
| Refined Auth flows (OAuth cancel logic, safe password reset feedback) | ✅ | Phase 2 VERIFICATION.md — `AuthException` cancellation interception + generic reset message |
| Resilient parsing (Missing template fields don't fail entire list) | ✅ | Phase 2 VERIFICATION.md — try-catch loop in `fetchByCategory` and `_fetchTemplatesFromNetwork` |
| Better error UX for Gallery (size validation, confirm deletes, pull-to-refresh) | ✅ | Phase 3 VERIFICATION.md — 10MB limit in `image_picker_provider.dart`, `RefreshIndicator` in `gallery_page.dart`, `AlertDialog` in `image_viewer_page.dart` |

**5/5 must-haves verified ✅**

## Phase Quality Analysis

### Phase 1: Concurrency & Backend Limits
- **Verdict:** PASS
- **Gap closures:** 0
- **Quality:** Good. Changes were backend-focused (Edge Function + DB migration). Correctly identified that `deduct_credits` RPC already had atomic guarantees and only added the unique index for idempotency.
- **Note:** No new Flutter tests added for this phase (backend changes). Deno tests exist separately.

### Phase 2: Auth & Template Resilience
- **Verdict:** PASS
- **Gap closures:** 0
- **Quality:** Good. Three distinct concerns addressed cleanly. Test evidence via `flutter test` (45 passing). One issue found during execution: mangled method signatures in `i_auth_repository.dart` — fixed immediately. Missing `Log` import in `auth_view_model.dart` — also fixed.
- **Recurring issue:** File corruption from prior edits required cleanup (`i_auth_repository.dart` had duplicate/mangled signatures).

### Phase 3: Gallery UX & Guards
- **Verdict:** PASS
- **Gap closures:** 0
- **Quality:** Adequate. Tasks were straightforward UI changes. The `image_picker_provider.dart` is a new provider that isn't yet wired into any screen — it's a standalone utility ready for integration when Image-to-Image features are built.
- **Note:** The `RefreshIndicator` currently does an `async {}` invalidation without awaiting the result, so the pull indicator disappears immediately. Consider awaiting the stream's next emission for better UX.

## Concerns

1. **`image_picker_provider.dart` is not wired into any screen yet.** It exists as a standalone provider with the 10MB validation logic, but no screen currently imports or uses it. The `image_picker` package is in `pubspec.yaml` but no existing screen picks images for upload. This means the size validation is theoretically in place but not actively exercised in the UI flow.

2. **`RefreshIndicator` UX could be improved.** The current implementation calls `ref.invalidate(galleryStreamProvider)` inside an `async` callback but doesn't await the next data emission. The spinner disappears immediately rather than staying visible while fresh data loads.

3. **Pre-existing analyzer warnings remain.** 5 warnings (`unused_field` × 2 in `generation_job_manager.dart`, `avoid_dynamic_calls` × 3 in test files) and 12 info-level issues persist unchanged across the milestone.

4. **Flutter SDK `star_border.dart` bug.** Widget tests that touch `StarBorder` fail due to a framework-level `Matrix4` getter error. This is an upstream SDK issue (`sdk: ^3.10.7`), not caused by milestone changes.

## Recommendations

1. **Wire `image_picker_provider.dart` into the Create screen** when Image-to-Image is implemented, or add a note in backlog to track this integration gap.
2. **Improve `RefreshIndicator.onRefresh`** to await `ref.read(galleryStreamProvider.future)` so the pull-to-refresh indicator persists during the actual network fetch.
3. **Address pre-existing analyzer warnings** in a dedicated lint cleanup phase — particularly the `unused_field` warnings in `generation_job_manager.dart`.
4. **Upgrade Flutter SDK** when a patch for `star_border.dart` `Matrix4` is released to restore full widget test coverage.

## Technical Debt to Address

- [ ] `image_picker_provider.dart` not yet integrated into any screen UI
- [ ] `RefreshIndicator` instant dismiss — should await stream re-emission
- [ ] 5 pre-existing analyzer warnings (`unused_field`, `avoid_dynamic_calls`)
- [ ] Flutter SDK `star_border.dart` bug blocking widget tests
- [ ] Replace test AdMob IDs with production IDs (carried forward from previous milestone)
