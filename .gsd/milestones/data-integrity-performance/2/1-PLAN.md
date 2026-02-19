---
phase: 2
plan: 1
wave: 1
gap_closure: false
---

# Plan 2.1: Template Data Caching

## Objective
Add local file-based persistence for template data so the template list loads instantly from cache on subsequent opens. Uses cache-first with TTL strategy: return cached data if fresh (< 5 min), otherwise fetch from network and update cache. Reduces Supabase API calls on app open.

## Context
Load these files for context:
- .gsd/ARCHITECTURE.md
- lib/features/template_engine/domain/repositories/i_template_repository.dart
- lib/features/template_engine/data/repositories/template_repository.dart
- lib/features/template_engine/domain/entities/template_model.dart
- lib/features/template_engine/presentation/providers/template_provider.dart

## Tasks

<task type="auto">
  <name>Create TemplateCacheService</name>
  <files>
    lib/features/template_engine/data/services/template_cache_service.dart
  </files>
  <action>
    Create a file-based cache service for template data.

    Steps:
    1. Create `lib/features/template_engine/data/services/template_cache_service.dart`
    2. Use `path_provider` to get app documents directory
    3. Store templates as JSON file (`templates_cache.json`)
    4. Store cache metadata (timestamp) in a separate file or as part of JSON
    5. Implement methods:
       - `Future<List<TemplateModel>?> getCachedTemplates()` — returns null if no cache
       - `Future<void> cacheTemplates(List<TemplateModel> templates)` — writes list + timestamp
       - `bool isCacheValid(Duration maxAge)` — checks if cache is within TTL
       - `Future<void> clearCache()` — deletes cache file
    6. Add a Riverpod provider for the service

    AVOID: Using SharedPreferences (1MB platform limits, not ideal for large JSON lists)
    USE: dart:io File + path_provider for reliable file-based caching
    USE: dart:convert for JSON serialization (TemplateModel already has toJson/fromJson)
  </action>
  <verify>
    flutter analyze lib/features/template_engine/data/services/
  </verify>
  <done>
    - TemplateCacheService class exists with all 4 methods
    - Riverpod provider for the service exists
    - flutter analyze reports 0 issues on the file
  </done>
</task>

<task type="auto">
  <name>Integrate cache into TemplateRepository</name>
  <files>
    lib/features/template_engine/domain/repositories/i_template_repository.dart
    lib/features/template_engine/data/repositories/template_repository.dart
    lib/features/template_engine/data/repositories/template_repository.g.dart
  </files>
  <action>
    Update TemplateRepository to use cache-first strategy with TTL.

    Steps:
    1. Add `refreshTemplates()` method to `ITemplateRepository` interface
    2. Inject `TemplateCacheService` into `TemplateRepository` constructor
    3. Update `fetchTemplates()`:
       - Check cache first: if valid (< 5 min TTL), return cached data
       - If cache miss or expired: fetch from network, cache result, return
       - On network error with valid cache (even expired): return cached data as fallback
    4. Add `refreshTemplates()` implementation:
       - Always fetch from network, update cache, return fresh data
    5. Update provider to pass cache service to repository
    6. Run build_runner to regenerate .g.dart files

    AVOID: Breaking existing fetchTemplate(id) and fetchByCategory() — leave them as-is
    AVOID: Making the TTL configurable via constructor — use a constant
    USE: 5-minute TTL as default (Duration(minutes: 5))
  </action>
  <verify>
    flutter analyze
  </verify>
  <done>
    - ITemplateRepository has `refreshTemplates()` method
    - TemplateRepository constructor takes TemplateCacheService
    - fetchTemplates() returns cached data when cache is valid
    - fetchTemplates() fetches from network when cache expired
    - fetchTemplates() falls back to cache on network error
    - refreshTemplates() always fetches fresh data
    - flutter analyze reports 0 issues
  </done>
</task>

<task type="auto">
  <name>Write tests for caching layer</name>
  <files>
    test/features/template_engine/data/services/template_cache_service_test.dart
    test/features/template_engine/data/repositories/template_repository_test.dart
  </files>
  <action>
    Write unit tests for the caching functionality.

    Steps:
    1. Create test for TemplateCacheService:
       - Test cacheTemplates + getCachedTemplates roundtrip
       - Test getCachedTemplates returns null when no cache
       - Test isCacheValid with fresh vs expired cache
       - Test clearCache removes cached data
       - Use a temp directory for test isolation
    2. Update existing TemplateRepository tests (or create new):
       - Test cache hit returns cached data without network call
       - Test cache miss triggers network fetch and caches result
       - Test network error with cache fallback
       - Test refreshTemplates always hits network
       - Mock TemplateCacheService and SupabaseClient

    USE: mocktail for mocking
    AVOID: Depending on real file system in repository tests — mock the cache service
  </action>
  <verify>
    flutter test test/features/template_engine/data/
  </verify>
  <done>
    - All cache service tests pass
    - All repository cache integration tests pass
    - Existing tests still pass
    - flutter analyze clean
  </done>
</task>

## Must-Haves
After all tasks complete, verify:
- [ ] Template list loads from cache on subsequent opens (no network call if cache < 5 min old)
- [ ] Cache updates from network when TTL expires
- [ ] Network errors fall back to cached data gracefully
- [ ] `flutter analyze` remains clean (0 errors)
- [ ] All existing tests still pass

## Success Criteria
- [ ] All tasks verified passing
- [ ] Must-haves confirmed
- [ ] No regressions in tests
