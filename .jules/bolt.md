## 2024-05-24 - N+1 API Calls with Riverpod Family Providers
**Learning:** Using a Riverpod family provider (like `signedStorageUrlProvider(rawPath)`) inside a list item widget (like `ImageViewerImagePage` rendered within a `PageView` or `ListView`) creates an N+1 API request pattern, especially noticeable as the user scrolls or swipes. Each widget independently requests data, causing multiple network requests that could have been batched. Furthermore, attempting to use a dynamically constructed array for a batch cache key will completely negate caching benefits, leading to full re-requests upon scrolling.
**Action:** When rendering lists of items that require asynchronous resolution (like Supabase signed URLs), use a batch API at the parent level (`MasonryImageGrid`) where the stable source map is already resolved. Pass the pre-resolved map data directly down to child routes or widgets (e.g. through the `extra` args in a `GoRoute` like `GalleryImageRoute`), so no duplicate calls are generated whatsoever when rendering full-screen paginated lists.

## 2025-05-18 - Avoid O(N) Supabase signed URL API requests on gallery updates
**Learning:** In Riverpod, when a `FutureProvider.family` (like `gallerySignedUrlsProvider`) is invalidated due to a list of URLs changing (e.g. adding one new image to a 100-image grid), it refetches the *entire* list. Since Supabase's `createSignedUrls` was being used without local caching, this caused N redundant API requests for paths that were already signed and far from expiry.
**Action:** Always maintain an in-memory application-level cache for backend-generated signed URLs (with an expiry buffer). This drastically reduces redundant API calls and improves UI responsiveness during pagination or realtime list updates.

## 2025-03-04 - Optimize CachedNetworkImage Memory Decoding in Grids
**Learning:** In Flutter applications, using `CachedNetworkImage` to display high-resolution images in grids or lists without specifying `memCacheWidth` or `memCacheHeight` forces the framework to decode the images at full resolution. This leads to massive memory bloating and potential Out-Of-Memory (OOM) crashes, especially on lower-end devices or when rapidly scrolling.
**Action:** Always configure `memCacheWidth` (e.g., to 400 for typical thumbnails) or `memCacheHeight` when using `CachedNetworkImage` for list/grid items to optimize memory footprint during image decoding.

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

## 2025-05-18 - Optimize CachedNetworkImage Cache Key
**Learning:** When using signed URLs that include an expiring token as a query parameter (e.g., Supabase storage URLs), `CachedNetworkImage` defaults to using the full URL as the cache key. This causes continuous cache misses and redundant downloads when the token rotates.
**Action:** Always explicitly set the `cacheKey` property to the URL stripped of its query string (e.g., `url.split('?').first`) to ensure the cache survives token expiration.

## 2024-05-02 - Optimize Static List Filtering in Dart
**Learning:** In Dart, calling `.where(...).toList()` on a static or constant list (like `AiModels.all`) inside a dynamic getter function forces an O(N) evaluation and allocates a new list in memory every single time the getter is accessed. In reactive UI frameworks like Flutter/Riverpod, this can happen many times per frame during rebuilds, leading to unnecessary CPU overhead and garbage collection pressure.
**Action:** When creating filtered subsets of static reference data that never changes at runtime, always declare them as `static final` fields so they are computed exactly once at app startup and cached. Similarly, pre-compute a `Map` for $O(1)$ lookups instead of using `.where(...).first` (or `.firstWhere(...)`), which requires an O(N) scan.
