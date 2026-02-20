---
phase: 2
plan: 1
wave: 1
---

# Plan 2.1: Reconnection Logic & imageCount Assertion

## Objective
Add auto-reconnect on realtime subscription disconnect in `GenerationJobManager` and client-side `imageCount` bounds assertion in `GenerationOptionsModel`. Both are in the `template_engine` feature.

## Context
- `plans/reports/review-260220-1533-edge-cases-verification.md` — Edge case #1 (reconnect) and #11 (imageCount client-side)
- `lib/features/template_engine/presentation/helpers/generation_job_manager.dart` — 87 lines
- `lib/features/template_engine/domain/entities/generation_options_model.dart` — 19 lines

## Tasks

<task type="auto">
  <name>Add reconnection logic to GenerationJobManager</name>
  <files>
    - lib/features/template_engine/presentation/helpers/generation_job_manager.dart
  </files>
  <action>
    Currently `onError` (L49-53) calls `captureOnce`, then `onError`, then `cancel()`.
    This means on any stream error, the subscription is permanently killed.

    Modify `watchJob` to retry on transient errors:

    1. Add a `_retryCount` field and `static const maxRetries = 3`
    2. Add a `_retryDelay` field: `static const retryDelayMs = 2000`
    3. Store the `watchJob` arguments so they can be replayed on retry
    4. In `onError` handler:
       - If `_retryCount < maxRetries`:
         - Increment `_retryCount`
         - Log warning: `[GenerationJobManager] Stream error, retrying (${_retryCount}/$maxRetries)...`
         - Set a `Timer` to call `_resubscribe()` after `retryDelayMs * _retryCount` (backoff)
       - If `_retryCount >= maxRetries`:
         - Call `captureOnce`, `onError`, `cancel()` as before (give up)

    5. Add `_resubscribe()` method that re-calls `jobStream.listen()` with the same handlers
    6. Reset `_retryCount = 0` on successful data event (meaning connection recovered)
    7. Reset `_retryCount` in `reset()` and `cancel()`

    What to AVOID:
    - Do NOT change the public API of `watchJob()` — keep same signature
    - Do NOT recreate the stream — just re-listen to the same `jobStream`
    - Do NOT retry on terminal errors (job completed/failed) — only on stream errors
  </action>
  <verify>
    1. `flutter analyze` — no new issues
    2. Existing tests still pass: `flutter test`
    3. Code review: confirm retry only on stream errors, not on terminal job states
  </verify>
  <done>
    - `GenerationJobManager` retries up to 3 times on stream errors
    - Backoff between retries (2s × attempt)
    - Gives up after 3 retries with original error handling
    - Retry count resets on successful data
    - No public API changes
  </done>
</task>

<task type="auto">
  <name>Add imageCount bounds assertion to GenerationOptionsModel</name>
  <files>
    - lib/features/template_engine/domain/entities/generation_options_model.dart
  </files>
  <action>
    Add a Freezed `@Assert` annotation to validate imageCount is in [1, 4] range:

    ```dart
    @freezed
    class GenerationOptionsModel with _$GenerationOptionsModel {
      @Assert('imageCount >= 1 && imageCount <= 4', 'imageCount must be between 1 and 4')
      const factory GenerationOptionsModel({
        @Default('1:1') String aspectRatio,
        @Default(1) int imageCount,
        @Default('jpg') String outputFormat,
        @Default('google/imagen4') String modelId,
        @Default('') String otherIdeas,
      }) = _GenerationOptionsModel;

      factory GenerationOptionsModel.fromJson(Map<String, dynamic> json) =>
          _$GenerationOptionsModelFromJson(json);
    }
    ```

    After adding `@Assert`, run `dart run build_runner build --delete-conflicting-outputs` to regenerate the Freezed code.

    What to AVOID:
    - Do NOT change any other field or default value
    - Do NOT add manual validation — use Freezed's `@Assert` which generates an assert in the factory
  </action>
  <verify>
    1. `dart run build_runner build --delete-conflicting-outputs` succeeds
    2. `flutter analyze` — no issues
    3. `flutter test` — all tests pass
  </verify>
  <done>
    - `GenerationOptionsModel` throws assertion error if `imageCount` is outside [1, 4]
    - Default value of 1 still works
    - Freezed codegen runs cleanly
  </done>
</task>

## Success Criteria
- [ ] `GenerationJobManager` reconnects up to 3 times on stream errors
- [ ] `GenerationOptionsModel` asserts `imageCount` in [1, 4]
- [ ] `flutter analyze` clean
- [ ] All tests pass
