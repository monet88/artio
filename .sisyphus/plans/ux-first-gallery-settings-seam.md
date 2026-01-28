---
title: "UX-First Strategy: Gallery + Settings + Monetization Seam"
description: "Complete user experience flow before monetization, with domain seam to prevent bolt-on architecture"
status: complete
priority: P1
effort: 20h
created: 2026-01-28
updated: 2026-01-28
progress: 100%
oracle_consultation: ses_3ff70852bffeS0HEO7nulSK0d7
strategy: ux-first-hybrid
interview_complete: true
---

# UX-First Strategy: Gallery + Settings + Monetization Seam

## Context

**Oracle Consultation**: Session `ses_3ff70852bffeS0HEO7nulSK0d7` (3m 55s analysis)

**Strategic Decision**: 
- **Approach B (UX-First) + Hybrid** recommended over Monetization-First
- Rationale: Complete value loop early (generate -> view -> share) enables faster iteration, better testing, and earlier demo capability
- Hybrid element: Add domain seam + Edge Function skeleton NOW to prevent "bolt-on monetization" later

**Current State**:
- Auth working (Phase 1-3 complete)
- Template Engine working (Phase 4 complete)
- 3-layer architecture (Plan 1 complete)
- **Critical Gap**: Users can generate images but **can't view/download/manage** them
- Settings incomplete -> Can't logout, change theme, manage account

**What This Plan Delivers**:
- Complete user experience: Login -> Generate -> **View Gallery** -> Download/Share -> **Manage Settings**
- Domain abstraction for future monetization (prevents refactoring)
- Edge Function with image mirroring for long-term storage
- Demo-able product in 2-3 days

---

## Interview Decisions Summary

### Image Storage & Gallery Core

| Decision | Choice |
|----------|--------|
| Current image storage | External CDN (Replicate/Fal) |
| Long-term storage | Mirror to Supabase Storage (server-side during generation) |
| Storage bucket structure | User-based folders: `{user_id}/{image_id}.png` |
| Delete behavior | Soft delete flag on `generation_jobs`, keep DB record |
| Gallery pagination | Infinite scroll |
| Grid layout | Masonry (`flutter_staggered_grid_view`) |
| Masonry columns | Responsive (2 mobile, 3 tablet, 4+ desktop) |
| Loading placeholder | Shimmer skeleton (randomized heights) |
| Image quality | Grid: low-res thumbnails, Viewer: full-res |
| Cache size | 100MB, no manual clear option |
| Refresh strategy | Realtime (INSERT + UPDATE) + pull-to-refresh |
| Pull-to-refresh style | Material default |
| Realtime filter | Filter by current user_id in subscription |
| Error state | Inline error + retry button |
| Broken image fallback | Broken icon + delete option |
| Empty state CTA | Navigate to template picker |

### Image Viewer

| Decision | Choice |
|----------|--------|
| Gestures | Pinch zoom, double-tap zoom, swipe down close, swipe left/right nav, tap toggle UI |
| Background | Solid black |
| Info overlay | Template name, creation date/time, generation prompt (tap to reveal) |
| Share options | Copy URL, native share (share_plus), download to device, copy prompt |
| Download mechanism | `gallery_saver` / `image_gallery_saver` |
| Download permission | Request on first download |
| Delete confirmation | Immediate delete + Undo snackbar |
| Delete last image | Pop back to grid |

### Generation States in Gallery

| Decision | Choice |
|----------|--------|
| Failed generations | Show with retry option |
| Retry mechanism | Reset status to 'pending', re-trigger Edge Function |

### Settings

| Decision | Choice |
|----------|--------|
| Theme persistence | Device-local only (shared_preferences) |
| Theme switcher | SegmentedButton (Material 3) |
| Settings style | Grouped ListTiles (iOS style) |
| Account email | Display only (read-only) |
| Change password | Email reset link (Supabase default) |
| App version format | Version + build number (e.g., '1.0.0 (42)') |
| Privacy/Terms links | Hide until URLs ready |
| Logout confirmation | Simple confirm dialog |
| Logout data cleanup | Keep image cache, clear auth only |

### Platform & Scope

| Decision | Choice |
|----------|--------|
| Platform priority | Mobile primary, web degraded OK |
| Effort estimate | **20h** (increased from 16h based on scope) |

---

## Phases Overview

| # | Phase | Effort | Priority | Status |
|---|-------|--------|----------|--------|
| 0 | [Edge Function Verification + Mirroring](#phase-0-edge-function-verification--mirroring) | 1.5h | P0 Critical | ✅ Complete |
| 1 | [Domain Seam for Monetization](#phase-1-domain-seam-for-monetization) | 2h | P1 High | ✅ Complete |
| 2 | [Gallery MVP](#phase-2-gallery-mvp) | 10h | P1 High | ✅ Complete |
| 3 | [Settings MVP](#phase-3-settings-mvp) | 4h | P1 High | ✅ Complete |
| 4 | [Integration Testing & Polish](#phase-4-integration-testing--polish) | 2.5h | P2 Medium | ✅ Complete |

**Total Effort**: 20h (realistic estimate based on interview scope)

**After This Plan**: Execute Plan 2 (Credit/Premium/Rate Limit) with clean retrofit

---

## Phase 0: Edge Function Verification + Mirroring

**Duration**: 1.5h  
**Priority**: P0 - Critical (Blocking issue)

### Problem

Code calls `invoke('generate-image')` but Edge Function source missing from repo. Images currently stored on External CDN (Replicate/Fal) which expires.

**Interview Decision**: Single Edge Function that generates + mirrors to Supabase Storage

### Tasks

- [x] Check Edge Function existence
  ```bash
  ls -la supabase/functions/
  ```
- [x] If missing: Check Supabase Dashboard for deployed functions
- [x] If deployed but source missing: Pull source to `supabase/functions/generate-image/`
- [x] If not deployed: Identify current generation mechanism

#### Add Image Mirroring Logic

- [x] Update Edge Function to mirror CDN images to Supabase Storage:
  ```typescript
  // After getting CDN URL from Replicate/Fal
  const cdnUrl = result.output[0];
  
  // Download image
  const imageResponse = await fetch(cdnUrl);
  const imageBuffer = await imageResponse.arrayBuffer();
  
  // Upload to Supabase Storage
  const storagePath = `${userId}/${jobId}.png`;
  await supabase.storage
    .from('generated-images')
    .upload(storagePath, imageBuffer, {
      contentType: 'image/png',
      upsert: true
    });
  
  // Update job record with storage path (NOT CDN URL)
  await supabase
    .from('generation_jobs')
    .update({ result_paths: [storagePath] })
    .eq('id', jobId);
  ```

- [x] Verify storage bucket `generated-images` exists with RLS:
  ```sql
  -- Users can read own images
  CREATE POLICY "Users can view own images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'generated-images' AND auth.uid()::text = (storage.foldername(name))[1]);
  
  -- Users can delete own images  
  CREATE POLICY "Users can delete own images"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'generated-images' AND auth.uid()::text = (storage.foldername(name))[1]);
  ```

- [x] Document findings in `.sisyphus/notepads/ux-first-gallery-settings-seam/issues.md`

### Success Criteria

- [x] Edge Function status confirmed (exists or created)
- [x] Image mirroring logic added to Edge Function
- [x] Storage bucket with RLS policies verified
- [x] Storage path convention documented: `{user_id}/{image_id}.png`
- [x] Test generation saves to Supabase Storage (not just CDN URL)

---

## Phase 1: Domain Seam for Monetization

**Duration**: 2h  
**Priority**: P1 - High (Prevents future refactoring)

### Objective

Create domain abstraction layer for generation eligibility **now**, implement as "allow all" for MVP, replace with real monetization logic later (Plan 2).

**Oracle's key point**: "Dung de presentation tu check credits va tu chan - se hard-code business logic vao UI"

### Architecture

```
Presentation Layer (UI)
    | calls
Use Case (StartGenerationUseCase)
    | checks via
Domain Policy (IGenerationPolicy)
    | implementation
Data Layer (FreeBetaPolicy -> later: PremiumPolicy with RevenueCat)
```

### Implementation Steps

#### 1.1 Create Domain Interfaces

**File**: `lib/features/template_engine/domain/policies/generation_policy.dart`

```dart
/// Abstraction for generation eligibility rules
abstract class IGenerationPolicy {
  /// Check if user can generate with current template
  /// Returns eligibility with reason if denied
  Future<GenerationEligibility> canGenerate({
    required String userId,
    required String templateId,
  });
}

/// Result of eligibility check
class GenerationEligibility {
  final bool allowed;
  final String? denialReason;
  final int? remainingCredits;
  
  const GenerationEligibility.allowed({this.remainingCredits})
      : allowed = true,
        denialReason = null;
  
  const GenerationEligibility.denied(this.denialReason)
      : allowed = false,
        remainingCredits = null;
}
```

#### 1.2 Create MVP Implementation

**File**: `lib/features/template_engine/data/policies/free_beta_policy.dart`

```dart
/// MVP implementation - allows all generations during beta
class FreeBetaPolicy implements IGenerationPolicy {
  @override
  Future<GenerationEligibility> canGenerate({
    required String userId,
    required String templateId,
  }) async {
    // MVP: Allow unlimited generations
    return const GenerationEligibility.allowed(
      remainingCredits: 999, // Display as "unlimited" in UI
    );
  }
}
```

#### 1.3 Create Provider

**File**: `lib/features/template_engine/presentation/providers/generation_policy_provider.dart`

```dart
@riverpod
IGenerationPolicy generationPolicy(GenerationPolicyRef ref) {
  // MVP: Return free beta policy
  // Plan 2: Replace with PremiumPolicy(
  //   revenueCatService: ref.watch(revenueCatServiceProvider),
  //   supabase: ref.watch(supabaseClientProvider),
  // )
  return FreeBetaPolicy();
}
```

#### 1.4 Integrate into Generation Flow

**Modify**: `lib/features/template_engine/presentation/view_models/generation_view_model.dart`

```dart
// Add policy check before generation
final policy = ref.read(generationPolicyProvider);
final eligibility = await policy.canGenerate(
  userId: userId,
  templateId: template.id,
);

if (!eligibility.allowed) {
  state = AsyncError(
    AppException.generation(eligibility.denialReason ?? 'Cannot generate'),
    StackTrace.current,
  );
  return;
}

// Proceed with existing generation logic
await _repository.startGeneration(...);
```

### Success Criteria

- [x] `IGenerationPolicy` interface created in domain layer
- [x] `FreeBetaPolicy` implementation returns "allow all"
- [x] Provider wired to generation flow
- [x] Generation ViewModel checks policy before invoking Edge Function
- [x] No business logic in presentation layer
- [x] Code compiles and generates successfully

### Must Do

- Keep interface **domain-layer pure** (no Riverpod/Supabase imports)
- Check policy **before** Edge Function call
- Return structured `GenerationEligibility`

### Must Not Do

- Do NOT implement real credit logic yet (Plan 2)
- Do NOT add RevenueCat calls (Plan 2)
- Do NOT put policy checks in UI layer

---

## Phase 2: Gallery MVP

**Duration**: 10h (increased from 8h due to interview scope)  
**Priority**: P1 - High (Critical UX gap)

### Objective

Enable users to view, share, download, and delete their generated images. Complete the core user value loop: Generate -> View -> Download/Share.

### Architecture

```
lib/features/gallery/
├── domain/
│   ├── entities/
│   │   └── generated_image.dart        # Domain model
│   └── repositories/
│       └── i_gallery_repository.dart   # Abstract interface
├── data/
│   ├── dtos/
│   │   └── generated_image_dto.dart    # JSON serialization
│   ├── repositories/
│   │   └── gallery_repository.dart     # Supabase implementation
│   └── data_sources/
│       └── gallery_remote_data_source.dart
└── presentation/
    ├── providers/
    │   ├── gallery_provider.dart       # State management
    │   └── gallery_realtime_provider.dart  # Realtime subscription
    ├── screens/
    │   ├── gallery_screen.dart         # Main gallery view
    │   └── image_viewer_screen.dart    # Fullscreen viewer
    └── widgets/
        ├── masonry_image_grid.dart     # Masonry layout
        ├── gallery_image_card.dart     # Individual card
        ├── shimmer_grid.dart           # Loading skeleton
        ├── empty_gallery_state.dart    # Empty state with CTA
        ├── failed_image_card.dart      # Failed generation card
        └── image_info_overlay.dart     # Viewer info overlay
```

### Data Model

**Leverage existing**: `generation_jobs` table with soft delete flag

```dart
// domain/entities/generated_image.dart
@freezed
class GeneratedImage with _$GeneratedImage {
  const factory GeneratedImage({
    required String id,
    required String userId,
    required String templateId,
    required String templateName,
    required List<String> resultPaths,  // Storage paths (NOT CDN URLs!)
    required DateTime createdAt,
    required GenerationStatus status,
    String? prompt,
    DateTime? deletedAt,  // Soft delete flag
  }) = _GeneratedImage;
}

enum GenerationStatus { pending, processing, completed, failed }
```

### Implementation Steps

#### 2.1 Domain Layer (1h)

- [x] Create `GeneratedImage` entity with Freezed
- [x] Add `deletedAt` field for soft delete
- [x] Create `IGalleryRepository` interface:
  ```dart
  abstract class IGalleryRepository {
    Stream<List<GeneratedImage>> watchUserImages({required String userId});
    
    Future<List<GeneratedImage>> getUserImages({
      required String userId,
      int limit = 20,
      int offset = 0,
    });
    
    Future<String> getSignedUrl(String storagePath);
    Future<String> getThumbnailUrl(String storagePath); // Low-res for grid
    
    Future<void> softDeleteImage(String imageId);
    Future<void> retryGeneration(String jobId);
  }
  ```

#### 2.2 Data Layer (2.5h)

- [x] Create `GeneratedImageDto` for JSON serialization
- [x] Implement `GalleryRepository`:
  - Query `generation_jobs` table with pagination
  - Filter: `deleted_at IS NULL` for active images
  - Order by `created_at DESC`
  - Filter by `user_id` (RLS enforced)
  
- [x] Implement Realtime subscription:
  ```dart
  Stream<List<GeneratedImage>> watchUserImages({required String userId}) {
    return _supabase
      .from('generation_jobs')
      .stream(primaryKey: ['id'])
      .eq('user_id', userId)
      .order('created_at', ascending: false)
      .map((data) => data
        .where((row) => row['deleted_at'] == null)
        .map((row) => GeneratedImageDto.fromJson(row).toDomain())
        .toList());
  }
  ```

- [x] Implement `getSignedUrl()` and `getThumbnailUrl()`:
  ```dart
  Future<String> getSignedUrl(String storagePath) async {
    return await _supabase.storage
      .from('generated-images')
      .createSignedUrl(storagePath, 3600); // 1h expiry
  }
  
  Future<String> getThumbnailUrl(String storagePath) async {
    // Use Supabase transform for low-res
    return await _supabase.storage
      .from('generated-images')
      .createSignedUrl(storagePath, 3600, transform: TransformOptions(
        width: 400,
        quality: 70,
      ));
  }
  ```

- [x] Implement `softDeleteImage()`:
  ```dart
  Future<void> softDeleteImage(String imageId) async {
    await _supabase
      .from('generation_jobs')
      .update({'deleted_at': DateTime.now().toIso8601String()})
      .eq('id', imageId);
    // Note: Storage file NOT deleted (keeps audit trail)
  }
  ```

- [x] Implement `retryGeneration()`:
  ```dart
  Future<void> retryGeneration(String jobId) async {
    // Reset status to pending
    await _supabase
      .from('generation_jobs')
      .update({'status': 'pending', 'error': null})
      .eq('id', jobId);
    
    // Re-trigger Edge Function
    await _supabase.functions.invoke('generate-image', body: {'jobId': jobId});
  }
  ```

#### 2.3 Presentation Layer - Providers (1h)

**File naming convention**: `*_provider.dart` for functional, `*_notifier.dart` for class-based

- [x] Create `gallery_stream_provider.dart`:
  ```dart
  @riverpod
  Stream<List<GeneratedImage>> galleryStream(GalleryStreamRef ref) {
    final userId = ref.watch(authProvider).value?.id;
    if (userId == null) return Stream.value([]);
    
    final repository = ref.watch(galleryRepositoryProvider);
    return repository.watchUserImages(userId: userId);
  }
  ```

- [x] Create `gallery_actions_notifier.dart`:
  ```dart
  @riverpod
  class GalleryActionsNotifier extends _$GalleryActionsNotifier {
    @override
    FutureOr<void> build() {}
    
    Future<void> deleteImage(String imageId) async {
      final repository = ref.read(galleryRepositoryProvider);
      await repository.softDeleteImage(imageId);
    }
    
    Future<void> retryGeneration(String jobId) async {
      final repository = ref.read(galleryRepositoryProvider);
      await repository.retryGeneration(jobId);
    }
    
    Future<void> undoDelete(String imageId) async {
      await ref.read(galleryRepositoryProvider).restoreImage(imageId);
    }
  }
  ```

- [x] **CRITICAL**: Realtime subscription cleanup in repository:
  ```dart
  // In GalleryRepository - return cancelable stream
  Stream<List<GeneratedImage>> watchUserImages({required String userId}) {
    final channel = _supabase
      .channel('gallery_$userId')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'generation_jobs',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'user_id',
          value: userId,
        ),
        callback: (payload) => _controller.add(payload),
      )
      .subscribe();
    
    // Cleanup on stream cancel
    return _controller.stream.doOnCancel(() {
      channel.unsubscribe();
    });
  }
  ```

#### 2.4 Presentation Layer - Gallery Screen (2.5h)

- [x] Create `GalleryScreen` with **AsyncValue.when()** pattern:
  ```dart
  class GalleryScreen extends ConsumerWidget {
    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final galleryAsync = ref.watch(galleryStreamProvider);
      
      return Scaffold(
        appBar: AppBar(title: Text('Your Creations')),
        body: RefreshIndicator(
          onRefresh: () => ref.refresh(galleryStreamProvider.future),
          child: galleryAsync.when(
            data: (images) => images.isEmpty
              ? EmptyGalleryState()
              : MasonryImageGrid(images: images),
            loading: () => ShimmerGrid(),
            error: (error, stack) => ErrorRetryWidget(
              message: error.toString(),
              onRetry: () => ref.invalidate(galleryStreamProvider),
            ),
          ),
        ),
      );
    }
  }
  ```

- [x] Create `MasonryImageGrid` with **Hero animation**:
  ```dart
  MasonryGridView.count(
    crossAxisCount: _getColumnCount(context),
    mainAxisSpacing: 8,
    crossAxisSpacing: 8,
    itemBuilder: (context, index) {
      final image = images[index];
      if (image.status == GenerationStatus.failed) {
        return FailedImageCard(
          image: image,
          onRetry: () => ref.read(galleryActionsNotifierProvider.notifier)
            .retryGeneration(image.id),
        );
      }
      return GalleryImageCard(
        image: image,
        // Hero tag for smooth transition to viewer
        heroTag: 'gallery-image-${image.id}',
      );
    },
  )
  
  int _getColumnCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    return 2;
  }
  ```

- [x] Create `GalleryImageCard` with Hero wrapper:
  ```dart
  class GalleryImageCard extends StatelessWidget {
    final GeneratedImage image;
    final String heroTag;
    
    @override
    Widget build(BuildContext context) {
      return GestureDetector(
        onTap: () => context.push('/gallery/${image.id}'),
        child: Hero(
          tag: heroTag,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: image.thumbnailUrl, // Low-res
              fit: BoxFit.cover,
              placeholder: (_, __) => ShimmerPlaceholder(),
              errorWidget: (_, __, ___) => BrokenImageCard(
                onDelete: () => _showDeleteOption(context),
              ),
            ),
          ),
        ),
      );
    }
  }
  ```

- [x] Create `EmptyGalleryState`:
  ```dart
  // CTA navigates to template picker
  ElevatedButton(
    onPressed: () => context.go('/templates'),
    child: Text('Create Your First Image'),
  )
  ```

- [x] Create `FailedImageCard`:
  ```dart
  // Shows error message + retry button
  Card(
    color: Theme.of(context).colorScheme.errorContainer,
    child: Column(
      children: [
        Icon(Icons.error_outline),
        Text('Generation Failed'),
        TextButton(onPressed: onRetry, child: Text('Retry')),
      ],
    ),
  )
  ```

#### 2.5 Presentation Layer - Image Viewer (2h)

- [x] Create `ImageViewerScreen` with **Hero animation** and gestures:
  ```dart
  class ImageViewerScreen extends ConsumerStatefulWidget {
    final String imageId;
    
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.black, // Solid black background
        body: Stack(
          children: [
            // Hero + InteractiveViewer for zoom
            GestureDetector(
              onTap: () => setState(() => _showOverlay = !_showOverlay),
              child: Hero(
                tag: 'gallery-image-$imageId',
                child: InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 4.0,
                  child: CachedNetworkImage(
                    imageUrl: fullResUrl, // Full-res for viewer
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            // Overlay with info + actions
            if (_showOverlay) ImageInfoOverlay(image: image),
          ],
        ),
      );
    }
  }
  ```

- [x] Implement swipe gestures:
  ```dart
  // Swipe down to close
  Dismissible(
    direction: DismissDirection.down,
    onDismissed: (_) => context.pop(),
    child: // ... viewer content
  )
  
  // Swipe left/right for next/prev (use PageView)
  PageView.builder(
    controller: _pageController,
    itemCount: images.length,
    onPageChanged: (index) => _currentIndex = index,
    itemBuilder: (context, index) => ImageViewerPage(image: images[index]),
  )
  ```

- [x] Create `ImageInfoOverlay`:
  ```dart
  // Visible content:
  // - Template name
  // - Creation date/time
  // - Prompt (tap to reveal)
  
  Column(
    children: [
      Text(image.templateName),
      Text(DateFormat.yMMMd().add_jm().format(image.createdAt)),
      GestureDetector(
        onTap: () => setState(() => _showPrompt = !_showPrompt),
        child: _showPrompt 
          ? Text(image.prompt ?? 'No prompt')
          : Text('Tap to show prompt'),
      ),
    ],
  )
  ```

- [x] Action buttons with **ref.listen for side-effects**:
  ```dart
  // Use ref.listen for snackbar/navigation side effects
  ref.listen(galleryActionsNotifierProvider, (prev, next) {
    next.whenOrNull(
      error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      ),
    );
  });
  
  // Action buttons
  IconButton(
    icon: Icon(Icons.copy),
    onPressed: () async {
      await Clipboard.setData(ClipboardData(text: signedUrl));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('URL copied')),
      );
    },
  ),
  IconButton(
    icon: Icon(Icons.share),
    onPressed: () => Share.share(signedUrl),
  ),
  IconButton(
    icon: Icon(Icons.download),
    onPressed: () => _downloadImage(context, signedUrl),
  ),
  IconButton(
    icon: Icon(Icons.content_copy),
    onPressed: () async {
      await Clipboard.setData(ClipboardData(text: image.prompt ?? ''));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Prompt copied')),
      );
    },
  ),
  ```

- [x] Delete with Undo (immediate + snackbar):
  ```dart
  Future<void> _deleteImage(GeneratedImage image) async {
    // Optimistic delete
    await ref.read(galleryActionsNotifierProvider.notifier).deleteImage(image.id);
    
    // Show undo snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Image deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => ref.read(galleryActionsNotifierProvider.notifier)
            .undoDelete(image.id),
        ),
        duration: Duration(seconds: 5),
      ),
    );
    
    // Pop back to grid if last image
    if (isLastImage) context.pop();
  }
  ```

#### 2.6 Router Integration (0.5h)

- [x] Update `app_router.dart`:
  ```dart
  import '../features/gallery/presentation/screens/gallery_screen.dart';
  import '../features/gallery/presentation/screens/image_viewer_screen.dart';
  
  // Routes
  GoRoute(
    path: '/gallery',
    builder: (context, state) => const GalleryScreen(),
  ),
  GoRoute(
    path: '/gallery/:imageId',
    builder: (context, state) => ImageViewerScreen(
      imageId: state.pathParameters['imageId']!,
    ),
  ),
  ```

#### 2.7 Dependencies (0.5h)

- [x] Add to `pubspec.yaml` (verified for Flutter 3.10.x):
  ```yaml
  # Gallery - Masonry grid
  flutter_staggered_grid_view: ^0.7.0  # Compatible with Flutter 3.x
  
  # Sharing
  share_plus: ^10.0.0  # Latest, web fallback: copy to clipboard
  
  # Download to device
  image_gallery_saver_plus: ^3.0.5  # Fork with Android 13+ support
  permission_handler: ^11.3.1  # For storage permission
  
  # Loading states
  shimmer: ^3.0.0
  ```

- [x] **Android 13+ permission handling** (`AndroidManifest.xml`):
  ```xml
  <!-- For Android 13+ (API 33+) -->
  <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
  <!-- For Android 12 and below -->
  <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="32"/>
  ```

- [x] **Web fallback** for share_plus:
  ```dart
  Future<void> _shareImage(String url) async {
    if (kIsWeb) {
      // Web: copy to clipboard instead
      await Clipboard.setData(ClipboardData(text: url));
      _showSnackbar('Link copied to clipboard');
    } else {
      await Share.share(url);
    }
  }
  ```

### Success Criteria

- [x] Gallery screen accessible from bottom nav
- [x] Masonry grid displays images with responsive columns
- [x] Realtime updates when new image generated
- [x] Shimmer skeleton during loading
- [x] Empty state with CTA to template picker
- [x] Failed generations show retry option
- [x] Tap image opens fullscreen viewer
- [x] All viewer gestures work (zoom, swipe, tap)
- [x] Info overlay shows template name, date, prompt (tap to reveal)
- [x] Share options: copy URL, native share, download, copy prompt
- [x] Download requests permission on first use
- [x] Delete with undo snackbar
- [x] Delete last image pops back to grid
- [x] Broken images show icon + delete option
- [x] Pull-to-refresh works
- [x] Infinite scroll pagination
- [x] Web: download gracefully degraded (copy link only)

### Must Do

- Use storage **paths** not signed URLs for persistence
- Soft delete only (keep DB record with `deleted_at`)
- Low-res thumbnails for grid, full-res for viewer
- Filter realtime by user_id
- Request download permission only when needed

### Must Not Do

- Do NOT hard delete records (audit trail loss)
- Do NOT store CDN URLs (expire quickly)
- Do NOT implement multi-image variants UI (deferred)
- Do NOT implement pending carousel (deferred)
- Do NOT implement gallery tab badge (deferred)

---

## Phase 3: Settings MVP

**Duration**: 4h  
**Priority**: P1 - High (Completes UX loop)

### Objective

Minimal settings screen to complete user experience: theme switching, logout, account management basics.

### Architecture

```
lib/features/settings/
├── domain/
│   └── repositories/
│       └── i_settings_repository.dart
├── data/
│   └── repositories/
│       └── settings_repository.dart
└── presentation/
    ├── providers/
    │   └── settings_provider.dart
    ├── screens/
    │   └── settings_screen.dart
    └── widgets/
        ├── theme_switcher.dart
        ├── account_section.dart
        └── about_section.dart
```

### Implementation Steps

#### 3.1 Domain Layer (0.5h)

- [x] Create `ISettingsRepository` interface:
  ```dart
  abstract class ISettingsRepository {
    Future<void> saveThemeMode(ThemeMode mode);
    Future<ThemeMode> getThemeMode();
  }
  ```

#### 3.2 Data Layer (1h)

- [x] Implement `SettingsRepository`:
  ```dart
  class SettingsRepository implements ISettingsRepository {
    final SharedPreferences _prefs;
    static const _themeKey = 'theme_mode';
    
    @override
    Future<void> saveThemeMode(ThemeMode mode) async {
      await _prefs.setString(_themeKey, mode.name);
    }
    
    @override
    Future<ThemeMode> getThemeMode() async {
      final value = _prefs.getString(_themeKey);
      return ThemeMode.values.firstWhere(
        (m) => m.name == value,
        orElse: () => ThemeMode.system,
      );
    }
  }
  ```

- [x] Create provider:
  ```dart
  @riverpod
  class ThemeSettings extends _$ThemeSettings {
    @override
    Future<ThemeMode> build() async {
      final repo = ref.watch(settingsRepositoryProvider);
      return await repo.getThemeMode();
    }
    
    Future<void> setThemeMode(ThemeMode mode) async {
      final repo = ref.read(settingsRepositoryProvider);
      await repo.saveThemeMode(mode);
      ref.invalidateSelf();
    }
  }
  ```

#### 3.3 Presentation Layer (2h)

##### Settings Screen (Grouped ListTiles - iOS style)

- [x] Create `SettingsScreen`:
  ```dart
  ListView(
    children: [
      // Account Section
      _SectionHeader('Account'),
      ListTile(
        leading: Icon(Icons.email_outlined),
        title: Text('Email'),
        subtitle: Text(user.email), // Read-only
      ),
      ListTile(
        leading: Icon(Icons.lock_outline),
        title: Text('Change Password'),
        trailing: Icon(Icons.chevron_right),
        onTap: _sendPasswordResetEmail,
      ),
      ListTile(
        leading: Icon(Icons.logout, color: Colors.red),
        title: Text('Logout', style: TextStyle(color: Colors.red)),
        onTap: _showLogoutConfirmation,
      ),
      
      // Appearance Section
      _SectionHeader('Appearance'),
      ListTile(
        leading: Icon(Icons.palette_outlined),
        title: Text('Theme'),
        trailing: ThemeSwitcher(), // SegmentedButton
      ),
      
      // About Section
      _SectionHeader('About'),
      ListTile(
        leading: Icon(Icons.info_outline),
        title: Text('Version'),
        trailing: Text('1.0.0 (42)'), // From package_info_plus
      ),
      // Privacy/Terms hidden until URLs ready
    ],
  )
  ```

##### Theme Switcher (SegmentedButton - Material 3)

- [x] Create `ThemeSwitcher`:
  ```dart
  SegmentedButton<ThemeMode>(
    segments: [
      ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode)),
      ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode)),
      ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.settings_suggest)),
    ],
    selected: {currentMode},
    onSelectionChanged: (modes) {
      ref.read(themeSettingsProvider.notifier).setThemeMode(modes.first);
    },
  )
  ```

##### Change Password Flow

- [x] Send password reset email:
  ```dart
  Future<void> _sendPasswordResetEmail() async {
    final email = ref.read(authProvider).value?.email;
    if (email == null) return;
    
    await supabase.auth.resetPasswordForEmail(email);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Password reset email sent to $email')),
    );
  }
  ```

##### Logout Flow

- [x] Simple confirm dialog:
  ```dart
  Future<void> _showLogoutConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Logout')),
        ],
      ),
    );
    
    if (confirmed == true) {
      await ref.read(authRepositoryProvider).signOut();
      // Router auto-redirects to login (auth guard)
      // Note: Image cache kept, auth cleared only
    }
  }
  ```

##### Theme Integration in main.dart

- [x] Wire theme provider:
  ```dart
  final themeMode = ref.watch(themeSettingsProvider).valueOrNull ?? ThemeMode.system;
  
  return MaterialApp.router(
    themeMode: themeMode,
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    // ...
  );
  ```

#### 3.4 Router Integration (0.5h)

- [x] Update `app_router.dart`:
  ```dart
  import '../features/settings/presentation/screens/settings_screen.dart';
  ```

#### 3.5 Dependencies

- [x] Add to `pubspec.yaml`:
  ```yaml
  package_info_plus: ^5.0.1
  ```

### Success Criteria

- [x] Settings screen accessible from bottom nav
- [x] Grouped ListTiles (iOS style) layout
- [x] Email displayed (read-only)
- [x] Change Password sends reset email + shows snackbar
- [x] Theme switcher (SegmentedButton) works
- [x] Theme persists across app restarts (device-local)
- [x] Theme updates immediately without restart
- [x] Logout confirmation dialog
- [x] Logout clears auth, keeps image cache
- [x] App version displayed (Version + build number)
- [x] Privacy/Terms links hidden (until URLs ready)

### Must Do

- Device-local theme only (shared_preferences)
- Simple confirm dialog for logout
- Keep image cache on logout

### Must Not Do

- Do NOT sync theme to Supabase
- Do NOT implement account deletion
- Do NOT show Privacy/Terms until URLs ready

---

## Phase 4: Integration Testing & Polish

**Duration**: 2.5h  
**Priority**: P2 - Medium (Quality gate)

### Objective

Test complete user flow, fix integration bugs, polish rough edges.

### Testing Flow

- [x] **Complete User Journey**:
  1. Fresh install / logout state
  2. Sign up new user
  3. Select template
  4. Generate image
  5. Wait for completion (realtime update)
  6. Navigate to Gallery
  7. Verify image appears (realtime worked)
  8. Open fullscreen viewer
  9. Test all gestures (zoom, swipe, tap)
  10. View info overlay (template, date, prompt)
  11. Share/copy link
  12. Download to device (permission flow)
  13. Delete image (undo snackbar)
  14. Navigate to Settings
  15. Change theme (verify immediate update)
  16. Restart app (verify theme persisted)
  17. Logout
  18. Login again (verify theme still persisted)

- [x] **Edge Cases**:
  - Empty gallery (CTA works)
  - Failed generation (retry works)
  - Network error (inline error + retry)
  - Broken image (icon + delete option)
  - Delete last image (pops to grid)
  - Web platform (download gracefully degraded)

### Bug Fixes

- [x] Fix any navigation issues
- [x] Fix theme switching bugs
- [x] Fix gallery realtime sync
- [x] Fix image viewer gestures
- [x] Fix delete undo flow
- [x] Fix permission request flow

### Polish

- [x] Consistent shimmer skeletons
- [x] Consistent error messages
- [x] Smooth hero animations
- [x] Responsive layout checks (mobile, tablet, desktop)
- [x] Accessibility: tap targets >= 48dp
- [x] Empty states helpful and branded

### Performance

- [x] Gallery infinite scroll smooth
- [x] Low-res thumbnails load fast
- [x] Full-res loads progressively
- [x] No jank on theme switching
- [x] No memory leaks on image viewer

### Success Criteria

- [x] Complete user flow works end-to-end
- [x] No crashes or unhandled exceptions
- [x] Theme persistence works
- [x] Gallery realtime works
- [x] All gestures smooth
- [x] App feels polished and professional

---

## Fast-Follow Features (Deferred)

These features were discussed in interview but deferred to keep MVP scope manageable. Track in this plan for quick implementation after MVP.

### Multi-Image Variants UI
**Effort**: 2h  
**Description**: When generation produces multiple images, show primary in grid with badge, thumbnail grid in viewer to navigate variants.

### Gallery Tab Pending Badge
**Effort**: 1h  
**Description**: Show count badge on Gallery bottom nav for pending generations. Share same realtime subscription.

### Pending Section Carousel
**Effort**: 1.5h  
**Description**: Horizontal carousel at top of gallery showing in-progress generations with status.

---

## Dependencies

### Existing (Verified)

- `cached_network_image: ^3.4.1`
- `shared_preferences: ^2.3.4`
- `path_provider: ^2.1.5`
- Supabase client
- Riverpod state management
- Freezed for data classes

### Add for This Plan

```yaml
# Gallery
flutter_staggered_grid_view: ^0.7.0
share_plus: ^7.2.1
image_gallery_saver: ^2.0.3
permission_handler: ^11.1.0
shimmer: ^3.0.0

# Settings
package_info_plus: ^5.0.1
```

---

## Risks & Mitigation

| Risk | Impact | Mitigation |
|------|--------|------------|
| Edge Function doesn't exist | High | Phase 0 verification, create if missing |
| CDN URLs expire before mirroring | High | Mirror in Edge Function immediately after generation |
| Storage RLS misconfigured | High | Test with multiple users, verify policies |
| Gallery realtime issues | Medium | Fallback to pull-to-refresh |
| Download permission denied | Low | Show settings link, fallback to copy URL |
| Web download not supported | Low | Copy URL fallback, document limitation |

---

## What This Plan Does NOT Include

**Deferred to Plan 2 (Monetization)**:
- Credits system
- Premium subscriptions
- Rate limiting
- RevenueCat integration
- Payment flows

**Deferred to Fast-Follow**:
- Multi-image variants UI
- Gallery tab pending badge
- Pending section carousel

**Deferred to Future Phases**:
- Favorites/starred images
- Albums/folders
- Image editing (crop/filter/enhance)
- Multi-select bulk actions
- Search/filter gallery
- Account deletion
- Notification settings
- Language selection

---

## After This Plan

**You will have**:
- Complete user experience (onboarding -> generate -> view -> manage)
- Demo-able product for stakeholders/users
- Feedback loop ready (real user testing)
- Architecture ready for monetization retrofit
- Edge Function with image mirroring

**Next step**:
- Execute **Plan 2: Credit, Premium & Rate Limit** (8h)
- Retrofit will be clean thanks to domain seam
- Can test payment flow with complete UX

---

## Quick Start

```bash
# Start work session
/start-work .sisyphus/plans/ux-first-gallery-settings-seam.md

# Or execute phases individually:
# Phase 0: Edge Function + mirroring
# Phase 1: Domain seam
# Phase 2: Gallery MVP
# Phase 3: Settings MVP
# Phase 4: Integration testing
```

---

**Created**: 2026-01-28  
**Updated**: 2026-01-28 (Interview complete)  
**Strategy**: UX-First + Hybrid (Oracle-validated)  
**Oracle Session**: ses_3ff70852bffeS0HEO7nulSK0d7  
**Total Effort**: 20h (1.5h + 2h + 10h + 4h + 2.5h)
