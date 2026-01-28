import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

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
  bool _isDownloading = false;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  GalleryItem get _currentItem => widget.items[_currentIndex];

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
    
    // Soft delete immediately
    await ref
        .read(galleryActionsNotifierProvider.notifier)
        .softDeleteImage(item.jobId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Image deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              ref
                  .read(galleryActionsNotifierProvider.notifier)
                  .restoreImage(item.jobId);
            },
          ),
          duration: const Duration(seconds: 5),
        ),
      );

      // If this was the only item, pop
      if (widget.items.length <= 1) {
        context.pop();
      } else {
        // Since we're passing the list statically via GoRouter extra, 
        // strictly speaking the list in this widget won't update automatically 
        // unless we passed a specialized controller or listener.
        // However, the gallery page underneath WILL update because it watches the stream.
        // For the viewer, we should probably close it if the user deletes the current item
        // OR we just let them swipe to the next one?
        // 
        // The plan says: "Pop if was last image". 
        // It's ambiguous if "last image" means "only one left" or "last index".
        // Assuming "only one left in the view".
        //
        // However, standard UX is often to remove it from the view locally or close the viewer.
        // Since we don't have a mutable list here (it's passed in widget), 
        // the easiest "MVP" approach is to close the viewer on delete, 
        // OR simply accept that it's "deleted" in backend but still visible in this session until pop.
        //
        // But the requirements say "Pop if was last image".
        // If we have multiple images, maybe we shouldn't pop? 
        // 
        // Let's stick to the simplest interpretation:
        // We performed the action. The user can Undo.
        // If we want to hide it from the PageView, we'd need to manage the list state locally.
        //
        // Let's implement local list management to remove it from view instantly?
        // But `widget.items` is final.
        //
        // Re-reading plan: "Pop if was last image"
        // Let's just pop context if items.length == 1.
        
        if (widget.items.length == 1) {
             context.pop();
        }
      }
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
        itemCount: widget.items.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final item = widget.items[index];
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
                            return const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    Icon(Icons.broken_image, color: Colors.white, size: 48),
                                    SizedBox(height: 16),
                                    Text('Failed to load image', style: TextStyle(color: Colors.white)),
                                ],
                            );
                        },
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
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
              padding: const EdgeInsets.all(16),
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
                    const SizedBox(height: 4),
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
