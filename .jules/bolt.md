## 2024-05-24 - Optimizing Memory Usage in CachedNetworkImage
**Learning:** In Flutter applications, using `CachedNetworkImage` to display thumbnails in grid or list views without setting memory cache constraints can lead to excessive memory consumption and Out-Of-Memory (OOM) errors, as the images are decoded and cached at their full resolution.
**Action:** Always explicitly configure `memCacheWidth` or `memCacheHeight` (e.g., to 400) for `CachedNetworkImage` instances within list and grid builders to prevent excessive memory usage and OOM errors.
