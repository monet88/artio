## 2025-02-12 - Prevent Unnecessary Rebuilds with Riverpod `select`
**Learning:** Watching the entirety of complex state objects (like `authViewModelProvider` or `subscriptionNotifierProvider`) in heavy UI components (like `GalleryPage` which contains a `MasonryImageGrid`) causes unnecessary, expensive rebuilds whenever unrelated sub-properties of that state change.
**Action:** Always use `.select()` in Riverpod to watch only the specific derived primitive or object needed (e.g. `ref.watch(provider.select((state) => state.isLoggedIn))`) in complex widget trees.
