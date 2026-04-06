
## 2026-04-02 - Fix N+1 API Calls on Riverpod Batch Loading
**Learning:** When using Riverpod to batch API requests (e.g., gallery signed URLs) and passing results to children, extracting `.valueOrNull` in the parent while the provider is `AsyncLoading` results in passing `null` to children. If children interpret `null` as "no batch available" and fallback to individual `ref.watch` calls, it triggers N simultaneous API calls before the batch resolves, defeating the purpose of the batch.
**Action:** Pass the full `AsyncValue` state to child widgets. This allows children to observe the loading state and display placeholders, rather than falling back to individual fetching while the batch is still loading.
