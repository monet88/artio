---
phase: 3
plan: 1
wave: 1
gap_closure: false
---

# Plan 3.1: Gallery Data Caching

## Objective
Add local file-based cache for gallery metadata so the gallery screen loads instantly from cache. Uses the same cache-first pattern as Phase 2 (template caching), adapted for user-specific, paginated gallery data. The `fetchGalleryItems()` first page loads from cache; the realtime stream (`watchUserImages`) remains unaffected.

## Context
Load these files for context:
- .gsd/ARCHITECTURE.md
- lib/features/gallery/domain/repositories/i_gallery_repository.dart
- lib/features/gallery/data/repositories/gallery_repository.dart
- lib/features/gallery/domain/entities/gallery_item.dart
- lib/features/gallery/presentation/providers/gallery_provider.dart
- lib/features/template_engine/data/services/template_cache_service.dart (reference pattern)

## Tasks

<task type="auto">
  <name>Create GalleryCacheService</name>
  <files>
    lib/features/gallery/data/services/gallery_cache_service.dart
  </files>
  <action>
    Create a file-based cache service for gallery data, following the TemplateCacheService pattern.

    Steps:
    1. Create `lib/features/gallery/data/services/gallery_cache_service.dart`
    2. Use `path_provider` to get app documents directory
    3. Store gallery items as JSON file (`gallery_cache.json`)
    4. Store cache metadata (timestamp) within the JSON envelope
    5. Implement methods:
       - `Future<List<GalleryItem>?> getCachedItems()` — returns null if no cache
       - `Future<void> cacheItems(List<GalleryItem> items)` — writes list + timestamp
       - `bool isCacheValid({Duration maxAge})` — checks if cache is within TTL (default 5 min)
       - `Future<void> clearCache()` — deletes cache file + resets timestamp
    6. Add `GalleryCacheService.forTesting(String directoryPath)` constructor for test isolation
    7. Add a Riverpod provider for the service

    AVOID: Using SharedPreferences (not suited for large lists)
    USE: dart:io File + path_provider
    USE: dart:convert for JSON (GalleryItem already has toJson/fromJson)
    FOLLOW: TemplateCacheService pattern exactly (forTesting, _directoryPath, error handling)
  </action>
  <verify>
    flutter analyze lib/features/gallery/data/services/
  </verify>
  <done>
    - GalleryCacheService class exists with all 4 methods + forTesting constructor
    - Riverpod provider for the service exists
    - flutter analyze reports 0 issues on the file
  </done>
</task>

<task type="auto">
  <name>Integrate cache into GalleryRepository</name>
  <files>
    lib/features/gallery/domain/repositories/i_gallery_repository.dart
    lib/features/gallery/data/repositories/gallery_repository.dart
    lib/features/gallery/data/repositories/gallery_repository.g.dart
  </files>
  <action>
    Update GalleryRepository to use cache-first strategy for fetchGalleryItems.

    Steps:
    1. Add `refreshGalleryItems()` method to `IGalleryRepository` interface
       - Signature: `Future<List<GalleryItem>> refreshGalleryItems({int limit, int offset, String? templateId})`
    2. Inject `GalleryCacheService` into `GalleryRepository` constructor
    3. Update `fetchGalleryItems()`:
       - Only cache the first page (offset == 0, no templateId filter)
       - If offset == 0 and no filter: check cache first, return if valid (< 5 min)
       - Otherwise (pagination or filtered): always fetch from network
       - On network error with offset 0: return cached data as fallback
    4. Add `refreshGalleryItems()` implementation:
       - Always fetch from network, update cache (for first page), return fresh data
    5. Invalidate cache on write operations (softDelete, restore, toggleFavorite, deleteJob)
       - Call `_cache.clearCache()` after each mutation succeeds
    6. Update galleryRepository provider to inject cache service
    7. Run build_runner to regenerate .g.dart files

    AVOID: Caching filtered or paginated results — only cache the default first page
    AVOID: Caching realtime stream — watchUserImages stays as-is
    AVOID: Breaking any existing methods (downloadImage, getImageFile, etc.)
    USE: 5-minute TTL as constant
  </action>
  <verify>
    flutter analyze
  </verify>
  <done>
    - IGalleryRepository has `refreshGalleryItems()` method
    - GalleryRepository constructor takes GalleryCacheService
    - fetchGalleryItems(offset: 0) returns cached data when cache is valid
    - fetchGalleryItems with offset > 0 or filter always hits network
    - Network errors fall back to cached data for first page
    - Write mutations (softDelete, restore, toggleFavorite, deleteJob) clear cache
    - watchUserImages unchanged
    - flutter analyze reports 0 issues
  </done>
</task>

<task type="auto">
  <name>Write tests for gallery caching</name>
  <files>
    test/features/gallery/data/services/gallery_cache_service_test.dart
    test/features/gallery/data/repositories/gallery_repository_test.dart
  </files>
  <action>
    Write unit tests for the gallery caching functionality.

    Steps:
    1. Create test for GalleryCacheService:
       - Test cacheItems + getCachedItems roundtrip
       - Test getCachedItems returns null when no cache
       - Test isCacheValid with fresh vs expired cache
       - Test clearCache removes cached data
       - Test corrupted JSON returns null
       - Use temp directory via forTesting constructor
    2. Add cache integration tests to gallery_repository_test.dart:
       - Test cache hit returns data
       - Test cache miss returns null
       - Test stale cache still returns data (for fallback scenario)
       - Test cache overwrite with new data
    3. Use existing test fixtures (GalleryItemFixtures) if available,
       otherwise create simple GalleryItem instances directly

    USE: temp directories for test isolation
    AVOID: Depending on path_provider in tests — use forTesting constructor
  </action>
  <verify>
    flutter test test/features/gallery/data/
  </verify>
  <done>
    - All cache service tests pass
    - All repository cache integration tests pass
    - Existing tests still pass (full suite)
    - flutter analyze clean
  </done>
</task>

## Must-Haves
After all tasks complete, verify:
- [ ] Gallery first page loads from cache on subsequent opens (no network call if cache < 5 min old)
- [ ] Cache updates from network when TTL expires
- [ ] Network errors fall back to cached data gracefully (first page only)
- [ ] Write mutations (delete, restore, favorite) invalidate cache
- [ ] Realtime stream (`watchUserImages`) is unchanged
- [ ] `flutter analyze` remains clean (0 errors)
- [ ] All existing tests still pass (620+ tests)

## Success Criteria
- [ ] All tasks verified passing
- [ ] Must-haves confirmed
- [ ] No regressions in tests
