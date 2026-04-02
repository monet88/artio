
## 2024-05-15 - [Supabase Storage Signed URL Caching]
**Learning:** [When using Supabase Storage with signed URLs in Flutter, `CachedNetworkImage` (and standard network images) will cache based on the full URL by default. Because signed URLs rotate and contain different token query parameters after expiration, the cache misses and forces a re-download of the same underlying file. This is especially painful when navigating from a grid thumbnail to a full-screen image viewer.]
**Action:** [Always manually set the `cacheKey` in `CachedNetworkImage` to the raw storage path (e.g. `userId/filename.jpg`) rather than the signed URL. This guarantees the cache hit persists across signed URL expirations, dramatically reducing latency and bandwidth when opening the full-screen viewer.]
