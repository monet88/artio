## 2026-03-04 - Network Image Caching
**Learning:** Using `Image.network` for Supabase signed storage URLs causes redundant downloads when widgets rebuild or users scroll, because the standard image widget does not cache images aggressively on disk across sessions or re-renders. This leads to higher network overhead, slower UX, and higher load on Supabase Storage.
**Action:** Always prefer `CachedNetworkImage` over `Image.network` for remote images, especially for user-generated content or template thumbnails, as it provides persistent on-disk caching, avoids unnecessary re-downloads, and improves scroll performance. Crucially, when using signed URLs that include an expiring token as a query parameter (e.g., Supabase storage URLs), you *must* explicitly set the `cacheKey` property (e.g., to the raw storage path or the URL without the query string). Otherwise, each new signed URL will be treated as a new image, resulting in cache misses and disk bloat.

## 2025-02-12 - Prevent Unnecessary Rebuilds with Riverpod `select`
**Learning:** Watching the entirety of complex state objects (like `authViewModelProvider` or `subscriptionNotifierProvider`) in heavy UI components (like `GalleryPage` which contains a `MasonryImageGrid`) causes unnecessary, expensive rebuilds whenever unrelated sub-properties of that state change.
**Action:** Always use `.select()` in Riverpod to watch only the specific derived primitive or object needed (e.g. `ref.watch(provider.select((state) => state.isLoggedIn))`) in complex widget trees.

## 2026-04-02 - Pre-calculate Animations in Grid itemBuilders
**Learning:** Instantiating `Tween` and `CurvedAnimation` objects inside an `itemBuilder` (such as in `MasonryGridView` or `SliverGrid`) creates O(n) new objects per scroll tick. This leads to memory churn and garbage collection pressure, causing UI jank during scrolling.
**Action:** Pre-calculate and cache static stagger animations inside `initState` or `didUpdateWidget` into a list. In the `itemBuilder`, perform an O(1) array lookup using the item index to retrieve the pre-built animation.

## 2023-10-27 - Parallel I/O in Supabase Edge Functions
**Learning:** Sequential `await` calls in a `for` loop for network requests (like generating signed URLs or uploading images) in Supabase Edge functions introduce significant latency, scaling $O(N)$ with the number of images. Replacing them with parallel execution using `Promise.all` or `Promise.allSettled` changes the time complexity to $O(1)$ relative to the network request time.
**Action:** When performing multiple independent I/O operations, use `Promise.all` (if partial failure should abort early) or `Promise.allSettled` (if cleanup of successful partial uploads is needed) to execute them in parallel.

## 2025-04-02 - Hoist constant loop calculations out of builder functions
**Learning:** In Flutter's lazily rendered lists and grids (`MasonryGridView.count`, `SliverGrid.builder`), any logic placed inside `itemBuilder` is executed for every rendered item. Variables dependent solely on the collection's full size rather than the specific item index were being recalculated repeatedly.
**Action:** Always hoist variables that do not change based on index (such as `maxItems`, `totalDuration`, and `clampedItemCount`) outside of the `itemBuilder` loop closure. This avoids O(N) redundant calculations per scroll frame.

## 2026-04-02 - Parallel Edge Function Promises
**Learning:** Sequential await calls in edge function loops (like downloading/uploading multiple images) cause significant cumulative latency that can be safely reduced by parallelizing with `Promise.allSettled`.
**Action:** Use `Promise.allSettled` over `Promise.all` when parallelizing uploads to ensure all background tasks finish cleanly and orphaned artifacts can be safely handled.

## 2026-04-02 - Fix N+1 API Calls on Riverpod Batch Loading
**Learning:** When using Riverpod to batch API requests (e.g., gallery signed URLs) and passing results to children, extracting `.valueOrNull` in the parent while the provider is `AsyncLoading` results in passing `null` to children. If children interpret `null` as "no batch available" and fallback to individual `ref.watch` calls, it triggers N simultaneous API calls before the batch resolves, defeating the purpose of the batch.
**Action:** Pass the full `AsyncValue` state to child widgets. This allows children to observe the loading state and display placeholders, rather than falling back to individual fetching while the batch is still loading.
