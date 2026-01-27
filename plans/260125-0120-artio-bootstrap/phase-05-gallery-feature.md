---
title: "Phase 5: Gallery Feature"
status: pending
effort: 4h
---

# Phase 5: Gallery Feature

## Context Links

- [Supabase Storage](https://supabase.com/docs/guides/storage)
- [cached_network_image package](https://pub.dev/packages/cached_network_image)

## Overview

**Priority**: P1 (High)
**Status**: pending
**Effort**: 4h

Display user's generated images in a gallery with options to view, download, share, and delete.

## Key Insights

- **Pagination is critical** for performance with large galleries (20 items per page)
- **cached_network_image** reduces bandwidth and improves scroll performance
- **Pull-to-refresh** provides intuitive update mechanism for new generations
- **Storage retention** differs by tier: Free (30 days), Paid (1 year)
- **Multi-select mode** enables batch operations for better UX

## Requirements

### Functional
- Grid view of all user's generations
- Albums/Folders organization
- Multi-select mode for batch delete
- Simple favorites (heart icon + filter)
- Full-screen image viewer
- Download image to device
- Share image via system share
- Delete generated images
- Filter by template/date
- History: output + template used
- Basic editing: crop, rotate, filter
- Storage: Free 30 days, Paid 1 year

### Non-Functional
- Lazy loading with pagination
- Image caching for performance
- Pull-to-refresh
- Empty state UI

## Architecture

### Feature Structure
```
lib/features/gallery/
├── domain/
│   ├── entities/
│   │   ├── gallery_item.dart
│   │   └── album.dart
│   └── repositories/
│       └── i_gallery_repository.dart
├── data/
│   ├── data_sources/
│   │   └── gallery_remote_data_source.dart
│   ├── dtos/
│   │   └── gallery_item_dto.dart
│   └── repositories/
│       └── gallery_repository_impl.dart
└── presentation/
    ├── providers/
    │   └── gallery_provider.dart
    ├── pages/
    │   ├── gallery_page.dart
    │   ├── image_viewer_page.dart
    │   └── image_editor_page.dart
    └── widgets/
        ├── gallery_grid.dart
        ├── gallery_item.dart
        ├── gallery_filters.dart
        ├── album_selector.dart
        └── favorite_button.dart
```

## Related Code Files

### Files to Create
- `lib/features/gallery/data/models/gallery_item_model.dart`
- `lib/features/gallery/data/repositories/gallery_repository.dart`
- `lib/features/gallery/domain/gallery_notifier.dart`
- `lib/features/gallery/presentation/pages/gallery_page.dart`
- `lib/features/gallery/presentation/pages/image_viewer_page.dart`
- `lib/features/gallery/presentation/widgets/gallery_grid.dart`
- `lib/features/gallery/presentation/widgets/gallery_item.dart`

### Files to Modify
- `lib/core/router/app_router.dart` - Add gallery routes

### Files to Delete
- None

## Implementation Steps

### 1. Gallery Item Model
```dart
// lib/features/gallery/data/models/gallery_item_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'gallery_item_model.freezed.dart';
part 'gallery_item_model.g.dart';

@freezed
class GalleryItemModel with _$GalleryItemModel {
  const factory GalleryItemModel({
    required String id,
    required String jobId,
    required String imageUrl,
    required String templateId,
    String? templateName,
    String? prompt,
    required DateTime createdAt,
  }) = _GalleryItemModel;

  factory GalleryItemModel.fromJson(Map<String, dynamic> json) =>
      _$GalleryItemModelFromJson(json);
}
```

### 2. Gallery Repository
```dart
// lib/features/gallery/data/repositories/gallery_repository.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';
import '../models/gallery_item_model.dart';

part 'gallery_repository.g.dart';

@riverpod
GalleryRepository galleryRepository(GalleryRepositoryRef ref) =>
    GalleryRepository();

class GalleryRepository {
  final _supabase = Supabase.instance.client;

  Future<List<GalleryItemModel>> fetchGalleryItems({
    int limit = 20,
    int offset = 0,
    String? templateId,
  }) async {
    var query = _supabase
        .from('generation_jobs')
        .select('*, templates(name)')
        .eq('status', 'completed')
        .not('result_urls', 'is', null)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    if (templateId != null) {
      query = query.eq('template_id', templateId);
    }

    final response = await query;
    final items = <GalleryItemModel>[];

    for (final job in response as List) {
      final urls = (job['result_urls'] as List?) ?? [];
      for (int i = 0; i < urls.length; i++) {
        items.add(GalleryItemModel(
          id: '${job['id']}_$i',
          jobId: job['id'],
          imageUrl: urls[i],
          templateId: job['template_id'],
          templateName: job['templates']?['name'],
          prompt: job['prompt'],
          createdAt: DateTime.parse(job['created_at']),
        ));
      }
    }

    return items;
  }

  Future<void> deleteJob(String jobId) async {
    // Get job to find image paths
    final job = await _supabase
        .from('generation_jobs')
        .select('result_urls, user_id')
        .eq('id', jobId)
        .single();

    // Delete from storage
    final userId = job['user_id'];
    final urls = (job['result_urls'] as List?) ?? [];

    for (int i = 0; i < urls.length; i++) {
      await _supabase.storage
          .from('generated-images')
          .remove(['$userId/$jobId/$i.png']);
    }

    // Delete job record
    await _supabase.from('generation_jobs').delete().eq('id', jobId);
  }

  Future<String> downloadImage(String imageUrl) async {
    final dio = Dio();
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'artio_${DateTime.now().millisecondsSinceEpoch}.png';
    final filePath = '${directory.path}/$fileName';

    await dio.download(imageUrl, filePath);
    return filePath;
  }

  Future<File> getImageFile(String imageUrl) async {
    final dio = Dio();
    final response = await dio.get<List<int>>(
      imageUrl,
      options: Options(responseType: ResponseType.bytes),
    );

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/share_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(response.data!);
    return file;
  }
}
```

### 3. Gallery Notifier
```dart
// lib/features/gallery/domain/gallery_notifier.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/gallery_item_model.dart';
import '../data/repositories/gallery_repository.dart';

part 'gallery_notifier.g.dart';

@riverpod
class GalleryNotifier extends _$GalleryNotifier {
  static const _pageSize = 20;
  int _currentPage = 0;
  bool _hasMore = true;

  @override
  Future<List<GalleryItemModel>> build() async {
    return _fetchPage(0);
  }

  Future<List<GalleryItemModel>> _fetchPage(int page) async {
    final repo = ref.read(galleryRepositoryProvider);
    final items = await repo.fetchGalleryItems(
      limit: _pageSize,
      offset: page * _pageSize,
    );
    _hasMore = items.length == _pageSize;
    return items;
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;

    _currentPage++;
    try {
      final newItems = await _fetchPage(_currentPage);
      final currentItems = state.value ?? [];
      state = AsyncValue.data([...currentItems, ...newItems]);
    } catch (e, st) {
      _currentPage--;
      // Don't update state - keep existing items
    }
  }

  Future<void> refresh() async {
    _currentPage = 0;
    _hasMore = true;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPage(0));
  }

  Future<void> deleteItem(String jobId) async {
    final repo = ref.read(galleryRepositoryProvider);
    await repo.deleteJob(jobId);

    // Remove from local state
    final currentItems = state.value ?? [];
    state = AsyncValue.data(
      currentItems.where((item) => item.jobId != jobId).toList(),
    );
  }

  bool get hasMore => _hasMore;
}
```

### 4. Gallery Page
```dart
// lib/features/gallery/presentation/pages/gallery_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/gallery_notifier.dart';
import '../widgets/gallery_grid.dart';

class GalleryPage extends ConsumerWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleryState = ref.watch(galleryNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gallery')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(galleryNotifierProvider.notifier).refresh(),
        child: galleryState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: $e'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.read(galleryNotifierProvider.notifier).refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (items) {
            if (items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No images yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text('Start generating to see your creations here'),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => context.go('/home'),
                      child: const Text('Create'),
                    ),
                  ],
                ),
              );
            }

            return GalleryGrid(
              items: items,
              onLoadMore: ref.read(galleryNotifierProvider.notifier).loadMore,
              hasMore: ref.read(galleryNotifierProvider.notifier).hasMore,
              onItemTap: (item) {
                context.push('/gallery/${item.id}', extra: item);
              },
            );
          },
        ),
      ),
    );
  }
}
```

### 5. Image Viewer Page
```dart
// lib/features/gallery/presentation/pages/image_viewer_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/gallery_item_model.dart';
import '../../data/repositories/gallery_repository.dart';
import '../../domain/gallery_notifier.dart';

class ImageViewerPage extends ConsumerStatefulWidget {
  final GalleryItemModel item;

  const ImageViewerPage({super.key, required this.item});

  @override
  ConsumerState<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends ConsumerState<ImageViewerPage> {
  bool _isDownloading = false;
  bool _isSharing = false;

  Future<void> _download() async {
    setState(() => _isDownloading = true);
    try {
      final repo = ref.read(galleryRepositoryProvider);
      final path = await repo.downloadImage(widget.item.imageUrl);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved to $path')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _share() async {
    setState(() => _isSharing = true);
    try {
      final repo = ref.read(galleryRepositoryProvider);
      final file = await repo.getImageFile(widget.item.imageUrl);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Created with Artio',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Share failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Image'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(galleryNotifierProvider.notifier).deleteItem(widget.item.jobId);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: _isSharing
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.share),
            onPressed: _isSharing ? null : _share,
          ),
          IconButton(
            icon: _isDownloading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.download),
            onPressed: _isDownloading ? null : _download,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _delete,
          ),
        ],
      ),
      body: InteractiveViewer(
        child: Center(
          child: Hero(
            tag: widget.item.id,
            child: Image.network(
              widget.item.imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
      bottomNavigationBar: widget.item.prompt != null
          ? Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black.withOpacity(0.5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.item.templateName != null)
                    Text(
                      widget.item.templateName!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    widget.item.prompt!,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
```

### 6. Gallery Grid Widget
```dart
// lib/features/gallery/presentation/widgets/gallery_grid.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/gallery_item_model.dart';

class GalleryGrid extends StatelessWidget {
  final List<GalleryItemModel> items;
  final VoidCallback onLoadMore;
  final bool hasMore;
  final void Function(GalleryItemModel) onItemTap;

  const GalleryGrid({
    super.key,
    required this.items,
    required this.onLoadMore,
    required this.hasMore,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 200 &&
            hasMore) {
          onLoadMore();
        }
        return false;
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: items.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= items.length) {
            return const Center(child: CircularProgressIndicator());
          }

          final item = items[index];
          return GestureDetector(
            onTap: () => onItemTap(item),
            child: Hero(
              tag: item.id,
              child: CachedNetworkImage(
                imageUrl: item.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                ),
                errorWidget: (_, __, ___) => const Icon(Icons.error),
              ),
            ),
          );
        },
      ),
    );
  }
}
```

## Todo List

- [ ] Create gallery_item_model.dart
- [ ] Implement gallery_repository.dart with pagination
- [ ] Implement gallery_notifier.dart with loadMore
- [ ] Create gallery_page.dart with empty state
- [ ] Create image_viewer_page.dart with zoom
- [ ] Create gallery_grid.dart widget
- [ ] Add share_plus package
- [ ] Implement download to device
- [ ] Implement share functionality
- [ ] Implement delete with confirmation
- [ ] Add route for image viewer
- [ ] Test pagination and infinite scroll
- [ ] Test offline image caching

## Success Criteria

- [ ] `flutter analyze` reports 0 errors
- [ ] Gallery loads user's images
- [ ] Infinite scroll works
- [ ] Pull-to-refresh works
- [ ] Download saves to device
- [ ] Share opens system share sheet
- [ ] Delete removes from Storage and DB

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Large gallery slow to load | High | High | Implement pagination (20 items) + image caching with cached_network_image |
| Download fails silently | Medium | Medium | Show progress indicator and detailed error messages |
| Storage deletion fails but DB succeeds | Low | High | Implement transaction-like cleanup with error recovery |
| Image cache grows too large | Medium | Medium | Configure cache size limits and eviction policies |

## Next Steps

→ Phase 6: Subscription & Credits

## Security Considerations

- **RLS policies** ensure users can only access their own gallery items
- **Download permissions** must be requested on Android 10+ (scoped storage)
- **Storage URLs** are signed by Supabase with time-limited access
- **Deletion cascade** ensures orphaned files don't remain in storage
