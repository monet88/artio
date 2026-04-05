
## 2024-05-18 - [Limit CachedNetworkImage Memory Cache for Thumbnails]
**Learning:** In Flutter applications, when using `CachedNetworkImage` to display thumbnails in grid or list views, not limiting the cache size causes the framework to decode full-resolution images into memory. This results in excessive memory consumption and potential Out-Of-Memory (OOM) errors.
**Action:** Always explicitly configure `memCacheWidth` or `memCacheHeight` (e.g., to 400) on `CachedNetworkImage` widgets that are used to display thumbnails in large lists or grids to prevent unnecessary memory bloat.
