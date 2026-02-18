import 'dart:io';

import 'package:artio/core/design_system/app_animations.dart';
import 'package:artio/core/services/haptic_service.dart';
import 'package:artio/core/utils/app_exception_mapper.dart';
import 'package:artio/core/utils/watermark_util.dart';
import 'package:artio/features/gallery/domain/entities/gallery_item.dart';
import 'package:artio/features/gallery/domain/providers/gallery_repository_provider.dart';
import 'package:artio/features/gallery/presentation/providers/gallery_provider.dart';
import 'package:artio/features/gallery/presentation/widgets/image_info_bottom_sheet.dart';
import 'package:artio/features/gallery/presentation/widgets/image_viewer_app_bar.dart';
import 'package:artio/features/gallery/presentation/widgets/image_viewer_image_page.dart';
import 'package:artio/features/gallery/presentation/widgets/image_viewer_page_indicator.dart';
import 'package:artio/features/gallery/presentation/widgets/image_viewer_swipe_dismiss.dart';
import 'package:artio/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:artio/shared/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:share_plus/share_plus.dart';

/// Image viewer with swipe-to-dismiss, haptic feedback, and info sheet.
class ImageViewerPage extends ConsumerStatefulWidget {

  const ImageViewerPage({
    required this.items, required this.initialIndex, super.key,
  });
  final List<GalleryItem> items;
  final int initialIndex;

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
  double _dragOffset = 0;
  bool _isDragging = false;
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
    _indicatorOpacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _indicatorController, curve: Curves.easeOut),
    );
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

  bool get _isFreeUser =>
      ref.read(subscriptionNotifierProvider).maybeWhen(
            data: (status) => status.isFree,
            orElse: () => true,
          );

  Future<void> _download() async {
    final imageUrl = _currentItem.imageUrl;
    if (imageUrl == null) return;
    HapticService.buttonTap();
    setState(() => _isDownloading = true);
    try {
      final repo = ref.read(galleryRepositoryProvider);
      if (_isFreeUser) {
        // Download to temp, watermark to separate file, then save to gallery.
        final file = await repo.getImageFile(imageUrl);
        final bytes = await file.readAsBytes();
        final watermarked = await WatermarkUtil.applyWatermark(bytes);
        final watermarkedFile = File(
          '${file.parent.path}/watermarked_${file.uri.pathSegments.last}',
        );
        await watermarkedFile.writeAsBytes(watermarked);
        await ImageGallerySaverPlus.saveFile(watermarkedFile.path);
        await watermarkedFile.delete().catchError((_) => watermarkedFile);
        await file.delete().catchError((_) => file);
        HapticService.downloadComplete();
        if (mounted) {
          AppSnackbar.success(context, 'Saved to Photos');
        }
      } else {
        final path = await repo.downloadImage(imageUrl);
        HapticService.downloadComplete();
        if (mounted) {
          AppSnackbar.success(context, 'Saved to $path');
        }
      }
    } on Exception catch (e) {
      HapticService.error();
      if (mounted) {
        AppSnackbar.error(context, AppExceptionMapper.toUserMessage(e));
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _share() async {
    final imageUrl = _currentItem.imageUrl;
    if (imageUrl == null) return;
    HapticService.share();
    setState(() => _isSharing = true);
    try {
      final repo = ref.read(galleryRepositoryProvider);
      final file = await repo.getImageFile(imageUrl);
      if (_isFreeUser) {
        final bytes = await file.readAsBytes();
        final watermarked = await WatermarkUtil.applyWatermark(bytes);
        final watermarkedFile = File('${file.parent.path}/watermarked_${file.uri.pathSegments.last}');
        await watermarkedFile.writeAsBytes(watermarked);
        try {
          await SharePlus.instance.share(
            ShareParams(
              files: [XFile(watermarkedFile.path)],
              text: 'Created with Artio',
            ),
          );
        } finally {
          await watermarkedFile.delete().catchError((_) => watermarkedFile);
          await file.delete().catchError((_) => file);
        }
      } else {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path)],
            text: 'Created with Artio',
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        AppSnackbar.error(context, AppExceptionMapper.toUserMessage(e));
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Future<void> _delete() async {
    HapticService.destructive();
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
    AppSnackbar.show(
      context,
      message: 'Image deleted',
      actionLabel: 'Undo',
      onAction: () {
        HapticService.buttonTap();
        ref
            .read(galleryActionsNotifierProvider.notifier)
            .restoreImage(item.jobId);
        setState(() {
          _items.insert(deletedIndex.clamp(0, _items.length), item);
        });
      },
      duration: const Duration(seconds: 5),
    );
  }

  void _copyPrompt() {
    final prompt = _currentItem.prompt;
    if (prompt == null || prompt.isEmpty) return;
    HapticService.copy();
    Clipboard.setData(ClipboardData(text: prompt));
    AppSnackbar.info(context, 'Prompt copied to clipboard');
  }

  void _toggleInfoSheet() {
    HapticService.navigationTap();
    setState(() => _showInfo = !_showInfo);
  }

  @override
  Widget build(BuildContext context) {
    const kOpacityFadeStart = 100.0;
    const kOpacityFadeRange = 200.0;
    final showWatermark = ref.watch(subscriptionNotifierProvider).maybeWhen(
          data: (status) => status.isFree,
          orElse: () => true,
        );
    final viewerOpacity = (_dragOffset.abs() > kOpacityFadeStart)
        ? (1.0 -
            ((_dragOffset.abs() - kOpacityFadeStart) / kOpacityFadeRange)
                .clamp(0.0, 0.6))
        : 1.0;

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: viewerOpacity),
      extendBodyBehindAppBar: true,
      appBar: ImageViewerAppBar(
        currentIndex: _currentIndex,
        totalCount: _items.length,
        showInfo: _showInfo,
        isSharing: _isSharing,
        isDownloading: _isDownloading,
        hasImageUrl: _currentItem.imageUrl != null,
        onToggleInfo: _toggleInfoSheet,
        onShare: _share,
        onDownload: _download,
        onDelete: _delete,
      ),
      body: Stack(
        children: [
          ImageViewerSwipeDismiss(
            onDismiss: () {
              HapticService.dragThreshold();
              context.pop();
            },
            onDragStateChanged: (offset, _, {required isDragging}) {
              setState(() {
                _dragOffset = offset;
                _isDragging = isDragging;
              });
            },
            child: PageView.builder(
              controller: _pageController,
              itemCount: _items.length,
              onPageChanged: (index) {
                HapticService.pageTurn();
                setState(() => _currentIndex = index);
                _resetIndicatorTimer();
              },
              itemBuilder: (context, index) {
                return ImageViewerImagePage(
                  item: _items[index],
                  showWatermark: showWatermark,
                );
              },
            ),
          ),
          if (_items.length > 1)
            Positioned(
              bottom: _showInfo ? 320 : 100,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _indicatorOpacity,
                child: ImageViewerPageIndicator(
                  itemCount: _items.length,
                  currentIndex: _currentIndex,
                ),
              ),
            ),
          if (_showInfo)
            ImageInfoBottomSheet(
              item: _currentItem,
              onCopyPrompt: _copyPrompt,
            ),
        ],
      ),
    );
  }
}
