import 'package:artio/core/design_system/app_animations.dart';
import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/core/services/storage_url_service.dart';
import 'package:artio/features/gallery/domain/entities/gallery_item.dart';
import 'package:artio/features/gallery/presentation/widgets/interactive_gallery_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

/// Masonry image grid with staggered appear animations,
/// shimmer placeholders, and long-press scale effect.
class MasonryImageGrid extends ConsumerStatefulWidget {
  const MasonryImageGrid({
    required this.items,
    required this.onItemTap,
    this.showWatermark = false,
    super.key,
  });
  final List<GalleryItem> items;
  final void Function(
    GalleryItem item,
    int index,
    Map<String, String?> preResolvedUrls,
  )
  onItemTap;
  final bool showWatermark;

  @override
  ConsumerState<MasonryImageGrid> createState() => _MasonryImageGridState();
}

class _MasonryImageGridState extends ConsumerState<MasonryImageGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _staggerController;
  late List<Animation<double>> _itemAnimations;
  int _previousItemCount = 0;

  // Stable list instance: only replaced when item URLs actually change.
  // Prevents gallerySignedUrlsProvider from re-firing on every rebuild
  // because Riverpod family uses List identity equality.
  late List<String> _paths;

  static List<String> _extractPaths(List<GalleryItem> items) =>
      items.map((i) => i.imageUrl).whereType<String>().toList();

  static bool _pathsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    _paths = _extractPaths(widget.items);
    _previousItemCount = widget.items.length;
    _staggerController = AnimationController(
      vsync: this,
      duration: _buildStaggerDuration(widget.items.length),
    );
    _setupAnimations();
    _staggerController.forward();
  }

  Duration _buildStaggerDuration(int itemCount) {
    return Duration(
      milliseconds:
          AppAnimations.normal.inMilliseconds +
          (AppAnimations.staggerDelay.inMilliseconds *
              itemCount.clamp(0, AppAnimations.maxStaggerItems)),
    );
  }

  /// Memoizes staggered animations to prevent creating new Tweens during every scroll
  /// tick in the `itemBuilder`. Reduces memory churn and improves scroll performance.
  void _setupAnimations() {
    const maxItems = AppAnimations.maxStaggerItems;
    final clampedItemCount = widget.items.length.clamp(0, maxItems);
    final totalStaggerTime =
        AppAnimations.staggerDelay.inMilliseconds * clampedItemCount;
    final totalDuration =
        AppAnimations.normal.inMilliseconds + totalStaggerTime;

    _itemAnimations = List.generate(maxItems + 1, (staggerIndex) {
      final startFrac =
          (staggerIndex * AppAnimations.staggerDelay.inMilliseconds) /
          totalDuration;
      final endFrac =
          (staggerIndex * AppAnimations.staggerDelay.inMilliseconds +
              AppAnimations.normal.inMilliseconds) /
          totalDuration;

      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(
            startFrac.clamp(0.0, 1.0),
            endFrac.clamp(0.0, 1.0),
            curve: AppAnimations.defaultCurve,
          ),
        ),
      );
    });
  }

  @override
  void didUpdateWidget(MasonryImageGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items.length != _previousItemCount) {
      _previousItemCount = widget.items.length;
      _staggerController.duration = _buildStaggerDuration(widget.items.length);
      _setupAnimations();
      _staggerController.forward(from: 0);
    }
    if (!identical(oldWidget.items, widget.items)) {
      final newPaths = _extractPaths(widget.items);
      if (!_pathsEqual(_paths, newPaths)) {
        // Only update state (and invalidate provider) when URLs actually changed
        setState(() => _paths = newPaths);
      }
    }
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final int crossAxisCount;
    if (width > 900) {
      crossAxisCount = 4;
    } else if (width > 600) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 2;
    }

    // Batch-resolve all image URLs in a single Supabase API call.
    // _paths is a stable instance — only changes when item URLs actually change.
    final signedUrlsAsync = ref.watch(gallerySignedUrlsProvider(_paths));
    final signedUrlMap = signedUrlsAsync.valueOrNull ?? <String, String?>{};
    return MasonryGridView.count(
      padding: AppSpacing.cardPadding,
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final item = widget.items[index];
        const maxItems = AppAnimations.maxStaggerItems;
        final resolvedUrlAsync = item.imageUrl != null
            ? signedUrlsAsync.whenData((map) => map[item.imageUrl])
            : null;

        final staggerIndex = index.clamp(0, maxItems);
        final itemAnim = _itemAnimations[staggerIndex];

        return AnimatedBuilder(
          animation: itemAnim,
          builder: (context, child) => Opacity(
            opacity: itemAnim.value,
            child: Transform.scale(
              scale: 0.9 + (0.1 * itemAnim.value),
              child: child,
            ),
          ),
          child: InteractiveGalleryItem(
            item: item,
            onTap: () => widget.onItemTap(item, index, signedUrlMap),
            showWatermark: widget.showWatermark,
            resolvedUrlAsync: resolvedUrlAsync,
          ),
        );
      },
    );
  }
}
