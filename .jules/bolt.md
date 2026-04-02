## 2026-04-02 - Parallel Edge Function Promises
**Learning:** Sequential await calls in edge function loops (like downloading/uploading multiple images) cause significant cumulative latency that can be safely reduced by parallelizing with `Promise.allSettled`.
**Action:** Use `Promise.allSettled` over `Promise.all` when parallelizing uploads to ensure all background tasks finish cleanly and orphaned artifacts can be safely handled.
