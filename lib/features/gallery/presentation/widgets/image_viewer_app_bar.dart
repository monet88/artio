import 'package:artio/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// App bar for the image viewer with share, download, info, and delete actions.
class ImageViewerAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ImageViewerAppBar({
    required this.currentIndex,
    required this.totalCount,
    required this.showInfo,
    required this.isSharing,
    required this.isDownloading,
    required this.hasImageUrl,
    required this.onToggleInfo,
    required this.onShare,
    required this.onDownload,
    required this.onDelete,
    super.key,
  });

  final int currentIndex;
  final int totalCount;
  final bool showInfo;
  final bool isSharing;
  final bool isDownloading;
  final bool hasImageUrl;
  final VoidCallback onToggleInfo;
  final VoidCallback onShare;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Text(
        '${currentIndex + 1} / $totalCount',
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
            showInfo ? Icons.info_rounded : Icons.info_outline_rounded,
            color: showInfo ? AppColors.primaryCta : Colors.white,
          ),
          onPressed: onToggleInfo,
          tooltip: 'Image info',
        ),
        // Share
        IconButton(
          icon: isSharing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.share_rounded),
          onPressed: (isSharing || !hasImageUrl) ? null : onShare,
          tooltip: 'Share',
        ),
        // Download
        IconButton(
          icon: isDownloading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.download_rounded),
          onPressed: (isDownloading || !hasImageUrl) ? null : onDownload,
          tooltip: 'Download',
        ),
        // Delete
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded),
          onPressed: onDelete,
          tooltip: 'Delete',
        ),
      ],
    );
  }
}
