import 'dart:io';

import 'package:artio/core/utils/watermark_util.dart';
import 'package:artio/features/gallery/domain/repositories/i_gallery_repository.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:share_plus/share_plus.dart';

/// Encapsulates watermark + download/share logic for the image viewer actions.
class ImageViewerActionHelper {
  const ImageViewerActionHelper._();

  /// Download image: with watermark for free users, direct save otherwise.
  /// Returns a user-friendly save location string (e.g. "Photos" or path).
  static Future<String> download(
    IGalleryRepository repo,
    String imageUrl, {
    required bool isFreeUser,
  }) async {
    if (isFreeUser) {
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
      return 'Photos';
    } else {
      return repo.downloadImage(imageUrl);
    }
  }

  /// Share image: with watermark for free users, original otherwise.
  static Future<void> share(
    IGalleryRepository repo,
    String imageUrl, {
    required bool isFreeUser,
  }) async {
    final file = await repo.getImageFile(imageUrl);
    if (isFreeUser) {
      final bytes = await file.readAsBytes();
      final watermarked = await WatermarkUtil.applyWatermark(bytes);
      final watermarkedFile = File(
        '${file.parent.path}/watermarked_${file.uri.pathSegments.last}',
      );
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
      try {
        await SharePlus.instance.share(
          ShareParams(files: [XFile(file.path)], text: 'Created with Artio'),
        );
      } finally {
        await file.delete().catchError((_) => file);
      }
    }
  }
}
