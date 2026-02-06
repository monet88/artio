import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/design_system/app_dimensions.dart';
import '../../../../core/design_system/app_spacing.dart';
import '../../data/repositories/gallery_repository.dart';
import '../../domain/entities/gallery_item.dart';
import '../providers/gallery_provider.dart';

class ImageViewerPage extends ConsumerStatefulWidget {
  final List<GalleryItem> items;
  final int initialIndex;

  const ImageViewerPage({
    super.key,
    required this.items,
    required this.initialIndex,
  });

  @override
  ConsumerState<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends ConsumerState<ImageViewerPage> {
  late PageController _pageController;
  late int _currentIndex;
  late List<GalleryItem> _items; // Mutable local copy
  bool _isDownloading = false;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items); // Create mutable copy
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  GalleryItem get _currentItem => _items[_currentIndex];

  Future<void> _download() async {
    final imageUrl = _currentItem.imageUrl;
    if (imageUrl == null) return;

    setState(() => _isDownloading = true);
    try {
      final repo = ref.read(galleryRepositoryProvider);
      final path = await repo.downloadImage(imageUrl);
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
    final imageUrl = _currentItem.imageUrl;
    if (imageUrl == null) return;

    setState(() => _isSharing = true);
    try {
      final repo = ref.read(galleryRepositoryProvider);
      final file = await repo.getImageFile(imageUrl);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Created with Artio',
        ),
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
    final item = _currentItem;
    final deletedIndex = _currentIndex;

    // Soft delete in backend
    await ref
        .read(galleryActionsNotifierProvider.notifier)
        .softDeleteImage(item.jobId);

    if (!mounted) return;

    // Remove from local list immediately
    setState(() {
      _items.removeAt(deletedIndex);

      if (_items.isEmpty) {
        context.pop();
        return;
      }

      // If deleted last item, move to previous
      if (_currentIndex >= _items.length) {
        _currentIndex = _items.length - 1;
      }
    });

    // If no items left, we already popped above
    if (_items.isEmpty) return;

    // Jump to adjusted index
    _pageController.jumpToPage(_currentIndex);

    // Show undo snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Image deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            ref
                .read(galleryActionsNotifierProvider.notifier)
                .restoreImage(item.jobId);
            // Re-insert at original position
            setState(() {
              _items.insert(deletedIndex.clamp(0, _items.length), item);
            });
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text('${_currentIndex + 1} / ${_items.length}'),
        actions: [
          IconButton(
            icon: _isSharing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.share),
            onPressed: (_isSharing || _currentItem.imageUrl == null) ? null : _share,
          ),
          IconButton(
            icon: _isDownloading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.download),
            onPressed: (_isDownloading || _currentItem.imageUrl == null) ? null : _download,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _delete,
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: _items.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final item = _items[index];
          final imageUrl = item.imageUrl;

          return InteractiveViewer(
            child: Center(
              child: Hero(
                tag: 'gallery-image-${item.id}',
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                            return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    Icon(Icons.broken_image, color: Colors.white, size: AppDimensions.iconXl),
                                    SizedBox(height: AppSpacing.md),
                                    const Text('Failed to load image', style: TextStyle(color: Colors.white)),
                                ],
                            );
                        },
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          SizedBox(height: AppSpacing.md),
                          Text(
                            item.status == GenerationStatus.pending
                                ? 'Pending...'
                                : 'Processing...',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _currentItem.prompt?.isNotEmpty == true
          ? Container(
              padding: AppSpacing.screenPadding,
              color: Colors.black.withValues(alpha: 0.5),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_currentItem.templateName.isNotEmpty)
                      Text(
                        _currentItem.templateName,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      _currentItem.prompt ?? '',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
