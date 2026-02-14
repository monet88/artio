import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/design_system/app_animations.dart';
import '../../../../core/design_system/app_gradients.dart';
import '../../../../core/design_system/app_spacing.dart';
import '../../../../core/utils/app_exception_mapper.dart';
import '../../../../theme/app_colors.dart';
import '../../data/repositories/gallery_repository.dart';
import '../../domain/entities/gallery_item.dart';
import '../providers/gallery_provider.dart';

/// Enhanced Image Viewer with:
/// - Glassmorphism info bottom sheet
/// - Copy prompt & metadata display
/// - Haptic feedback on actions
/// - Smooth page indicator
/// - Swipe-down-to-dismiss
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

class _ImageViewerPageState extends ConsumerState<ImageViewerPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late int _currentIndex;
  late List<GalleryItem> _items;
  bool _isDownloading = false;
  bool _isSharing = false;
  bool _showInfo = false;

  // Swipe-down-to-dismiss
  double _dragOffset = 0;
  double _dragScale = 1.0;
  bool _isDragging = false;

  // Page indicator animation
  late final AnimationController _indicatorController;
  late final Animation<double> _indicatorOpacity;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    _indicatorController = AnimationController(
      vsync: this,
      duration: AppAnimations.normal,
    );
    _indicatorOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _indicatorController, curve: Curves.easeOut),
    );

    // Auto-hide indicator after 3 seconds
    _resetIndicatorTimer();
  }

  void _resetIndicatorTimer() {
    _indicatorController.reverse();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_isDragging) {
        _indicatorController.forward();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _indicatorController.dispose();
    super.dispose();
  }

  GalleryItem get _currentItem => _items[_currentIndex];

  Future<void> _download() async {
    final imageUrl = _currentItem.imageUrl;
    if (imageUrl == null) return;

    HapticFeedback.lightImpact();
    setState(() => _isDownloading = true);
    try {
      final repo = ref.read(galleryRepositoryProvider);
      final path = await repo.downloadImage(imageUrl);
      HapticFeedback.mediumImpact();
      if (mounted) {
        _showCustomSnackbar(
          context,
          icon: Icons.download_done_rounded,
          message: 'Saved to $path',
          type: _SnackbarType.success,
        );
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      if (mounted) {
        _showCustomSnackbar(
          context,
          icon: Icons.error_outline_rounded,
          message: AppExceptionMapper.toUserMessage(e),
          type: _SnackbarType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _share() async {
    final imageUrl = _currentItem.imageUrl;
    if (imageUrl == null) return;

    HapticFeedback.lightImpact();
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
        _showCustomSnackbar(
          context,
          icon: Icons.error_outline_rounded,
          message: AppExceptionMapper.toUserMessage(e),
          type: _SnackbarType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Future<void> _delete() async {
    HapticFeedback.mediumImpact();
    final item = _currentItem;
    final deletedIndex = _currentIndex;

    await ref
        .read(galleryActionsNotifierProvider.notifier)
        .softDeleteImage(item.jobId);

    if (!mounted) return;

    setState(() {
      _items.removeAt(deletedIndex);
      if (_items.isEmpty) {
        context.pop();
        return;
      }
      if (_currentIndex >= _items.length) {
        _currentIndex = _items.length - 1;
      }
    });

    if (_items.isEmpty) return;
    _pageController.jumpToPage(_currentIndex);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Image deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            HapticFeedback.lightImpact();
            ref
                .read(galleryActionsNotifierProvider.notifier)
                .restoreImage(item.jobId);
            setState(() {
              _items.insert(deletedIndex.clamp(0, _items.length), item);
            });
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _copyPrompt() {
    final prompt = _currentItem.prompt;
    if (prompt == null || prompt.isEmpty) return;

    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: prompt));
    _showCustomSnackbar(
      context,
      icon: Icons.content_copy_rounded,
      message: 'Prompt copied to clipboard',
      type: _SnackbarType.info,
    );
  }

  void _toggleInfoSheet() {
    HapticFeedback.selectionClick();
    setState(() => _showInfo = !_showInfo);
  }

  @override
  Widget build(BuildContext context) {
    final viewerOpacity = (_dragOffset.abs() > 100)
        ? (1.0 - ((_dragOffset.abs() - 100) / 200).clamp(0.0, 0.6))
        : 1.0;

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: viewerOpacity),
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // Main image viewer with swipe-to-dismiss
          GestureDetector(
            onVerticalDragStart: (_) {
              setState(() => _isDragging = true);
            },
            onVerticalDragUpdate: (details) {
              setState(() {
                _dragOffset += details.delta.dy;
                _dragScale = 1.0 - (_dragOffset.abs() / 1500).clamp(0.0, 0.15);
              });
            },
            onVerticalDragEnd: (details) {
              if (_dragOffset.abs() > 150) {
                // Dismiss
                HapticFeedback.lightImpact();
                context.pop();
              } else {
                setState(() {
                  _dragOffset = 0;
                  _dragScale = 1.0;
                  _isDragging = false;
                });
              }
            },
            child: Transform.translate(
              offset: Offset(0, _dragOffset),
              child: Transform.scale(
                scale: _dragScale,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _items.length,
                  onPageChanged: (index) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _currentIndex = index;
                    });
                    _resetIndicatorTimer();
                  },
                  itemBuilder: (context, index) {
                    return _buildImagePage(_items[index]);
                  },
                ),
              ),
            ),
          ),

          // Page indicator dots
          if (_items.length > 1)
            Positioned(
              bottom: _showInfo ? 320 : 100,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _indicatorOpacity,
                child: _buildPageIndicator(),
              ),
            ),

          // Info bottom sheet
          if (_showInfo) _buildInfoBottomSheet(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Text(
        '${_currentIndex + 1} / ${_items.length}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      actions: [
        // Info toggle
        IconButton(
          icon: Icon(
            _showInfo ? Icons.info_rounded : Icons.info_outline_rounded,
            color: _showInfo ? AppColors.primaryCta : Colors.white,
          ),
          onPressed: _toggleInfoSheet,
          tooltip: 'Image info',
        ),
        // Share
        IconButton(
          icon: _isSharing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.share_rounded),
          onPressed:
              (_isSharing || _currentItem.imageUrl == null) ? null : _share,
          tooltip: 'Share',
        ),
        // Download
        IconButton(
          icon: _isDownloading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.download_rounded),
          onPressed:
              (_isDownloading || _currentItem.imageUrl == null) ? null : _download,
          tooltip: 'Download',
        ),
        // Delete
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded),
          onPressed: _delete,
          tooltip: 'Delete',
        ),
      ],
    );
  }

  Widget _buildImagePage(GalleryItem item) {
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
                    final progress =
                        loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null;
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 48,
                            height: 48,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 2.5,
                              color: AppColors.primaryCta,
                              backgroundColor: AppColors.white10,
                            ),
                          ),
                          if (progress != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              '${(progress * 100).toInt()}%',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (bounds) =>
                              AppGradients.primaryGradient
                                  .createShader(bounds),
                          child: const Icon(
                            Icons.broken_image_rounded,
                            size: 56,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const Text(
                          'Failed to load image',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    );
                  },
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.primaryCta,
                        backgroundColor: AppColors.white10,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      item.status == GenerationStatus.pending
                          ? 'Pending...'
                          : 'Processing...',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _items.length.clamp(0, 10), // Max 10 dots
        (index) {
          final isActive = index == _currentIndex;
          return AnimatedContainer(
            duration: AppAnimations.fast,
            curve: AppAnimations.defaultCurve,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: isActive ? 24 : 6,
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: isActive
                  ? AppColors.primaryCta
                  : Colors.white.withValues(alpha: 0.4),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoBottomSheet() {
    final item = _currentItem;
    final dateStr = DateFormat('MMM d, yyyy · h:mm a').format(item.createdAt);

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: AppAnimations.normal,
        curve: AppAnimations.sharpCurve,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                border: const Border(
                  top: BorderSide(
                    color: AppColors.white10,
                    width: 0.5,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.white20,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Template name
                    if (item.templateName.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            color: AppColors.primaryCta,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item.templateName,
                            style: const TextStyle(
                              color: AppColors.primaryCta,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Prompt with copy button
                    if (item.prompt?.isNotEmpty == true) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'PROMPT',
                                  style: TextStyle(
                                    color: AppColors.textHint,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.prompt!,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          _GlassIconButton(
                            icon: Icons.content_copy_rounded,
                            onTap: _copyPrompt,
                            tooltip: 'Copy prompt',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Metadata row
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.white05,
                        border: Border.all(
                          color: AppColors.white10,
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          _MetadataChip(
                            icon: Icons.calendar_today_rounded,
                            label: dateStr,
                          ),
                          const SizedBox(width: 12),
                          _MetadataChip(
                            icon: Icons.check_circle_outline_rounded,
                            label: item.status.name.toUpperCase(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCustomSnackbar(
    BuildContext context, {
    required IconData icon,
    required String message,
    required _SnackbarType type,
  }) {
    final color = switch (type) {
      _SnackbarType.success => AppColors.success,
      _SnackbarType.error => AppColors.error,
      _SnackbarType.info => AppColors.info,
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black.withValues(alpha: 0.85),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: color.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        content: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

enum _SnackbarType { success, error, info }

/// Frosted glass-style icon button for the info panel.
class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.white10,
              border: Border.all(
                color: AppColors.white10,
                width: 0.5,
              ),
            ),
            child: Icon(icon, color: Colors.white70, size: 18),
          ),
        ),
      ),
    );
  }
}

/// Small metadata chip for the info panel.
class _MetadataChip extends StatelessWidget {
  const _MetadataChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.textHint, size: 14),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
