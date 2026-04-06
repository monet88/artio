## 2025-04-02 - Hoist constant loop calculations out of builder functions
**Learning:** In Flutter's lazily rendered lists and grids (`MasonryGridView.count`, `SliverGrid.builder`), any logic placed inside `itemBuilder` is executed for every rendered item. Variables dependent solely on the collection's full size rather than the specific item index were being recalculated repeatedly.
**Action:** Always hoist variables that do not change based on index (such as `maxItems`, `totalDuration`, and `clampedItemCount`) outside of the `itemBuilder` loop closure. This avoids O(N) redundant calculations per scroll frame.

## 2026-04-02 - Parallel Edge Function Promises
**Learning:** Sequential await calls in edge function loops (like downloading/uploading multiple images) cause significant cumulative latency that can be safely reduced by parallelizing with `Promise.allSettled`.
**Action:** Use `Promise.allSettled` over `Promise.all` when parallelizing uploads to ensure all background tasks finish cleanly and orphaned artifacts can be safely handled.

## 2026-04-02 - Fix N+1 API Calls on Riverpod Batch Loading
**Learning:** When using Riverpod to batch API requests (e.g., gallery signed URLs) and passing results to children, extracting `.valueOrNull` in the parent while the provider is `AsyncLoading` results in passing `null` to children. If children interpret `null` as "no batch available" and fallback to individual `ref.watch` calls, it triggers N simultaneous API calls before the batch resolves, defeating the purpose of the batch.
**Action:** Pass the full `AsyncValue` state to child widgets. This allows children to observe the loading state and display placeholders, rather than falling back to individual fetching while the batch is still loading.
