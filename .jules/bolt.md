
## 2024-04-03 - Flutter CachedNetworkImage Memory Optimization
**Learning:** By default, Flutter decodes images to their original dimensions. When rendering a grid or list of images fetched over the network, this behavior can easily cause excessive memory consumption and Out-Of-Memory (OOM) crashes, especially for high-resolution images.
**Action:** Always configure `memCacheWidth` or `memCacheHeight` (e.g., to 400) when using `CachedNetworkImage` (or `Image.network` if caching manually) for thumbnails or grid items to ensure images are downscaled at decode time.
