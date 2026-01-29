# Phase 07: Flutter Code Quality - Gallery

## Parallelization Info

| Property | Value |
|----------|-------|
| Group | C (Flutter) |
| Can Run With | Phases 05, 06, 08 |
| Blocked By | Group B (Phases 03, 04) |
| Blocks | Group E (Phases 10, 11) |

## File Ownership (Exclusive)

- `lib/features/gallery/presentation/pages/image_viewer_page.dart`

## Priority: MEDIUM

**Issue**: After deleting an image in PageView, deleted item still visible until user manually navigates away. The `widget.items` list is immutable (passed via GoRouter extra).

## Current State Analysis

```dart
// widget.items is final and immutable
final List<GalleryItem> items;

// After delete, we check if it was last item
if (widget.items.length <= 1) {
  context.pop();
} else {
  // Problem: deleted item still visible in PageView
  // because widget.items hasn't changed
}
```

## Implementation Steps

### Option A: Local Mutable State (Recommended)

Maintain a local copy of items that can be modified:

```dart
class _ImageViewerPageState extends ConsumerState<ImageViewerPage> {
  late PageController _pageController;
  late int _currentIndex;
  late List<GalleryItem> _items;  // Mutable local copy
  bool _isDownloading = false;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);  // Create mutable copy
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  GalleryItem get _currentItem => _items[_currentIndex];

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

      // Adjust current index if needed
      if (_items.isEmpty) {
        // No items left, pop
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
    // Guard against empty list during async operations
    if (_items.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text('${_currentIndex + 1} / ${_items.length}'),  // Show position
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
        itemCount: _items.length,  // Use local list
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final item = _items[index];  // Use local list
          // ... rest unchanged
        },
      ),
      // ... bottomNavigationBar unchanged
    );
  }

  // _download() and _share() methods unchanged
}
```

### Key Changes Summary

1. Create mutable `_items` copy in `initState`
2. `_delete()` removes item from local list immediately
3. Adjust `_currentIndex` after deletion
4. Use `_pageController.jumpToPage()` to update view
5. Undo re-inserts item at original position
6. Add position indicator in AppBar title

## Success Criteria

- [ ] Deleted image immediately removed from PageView
- [ ] Index adjusts correctly (no out-of-bounds)
- [ ] Undo restores image to correct position
- [ ] Pop when last/only image deleted
- [ ] Position indicator shows "X / Y" in AppBar
- [ ] No visual glitches during delete animation

## Conflict Prevention

- Only this phase modifies `image_viewer_page.dart`
- Backend soft-delete logic unchanged

## Edge Cases to Test

1. Delete first image
2. Delete last image
3. Delete middle image
4. Delete only image (should pop)
5. Undo after delete
6. Undo after navigating to different image
7. Rapid delete multiple images
