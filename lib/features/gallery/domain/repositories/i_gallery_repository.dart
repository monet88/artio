import 'dart:io';

import 'package:artio/features/gallery/domain/entities/gallery_item.dart';

abstract class IGalleryRepository {
  /// Fetch gallery items with pagination
  Future<List<GalleryItem>> fetchGalleryItems({
    int limit = 20,
    int offset = 0,
    String? templateId,
  });

  /// Watch user images with realtime updates
  Stream<List<GalleryItem>> watchUserImages({required String userId});

  /// Soft delete an image (sets deleted_at)
  Future<void> softDeleteImage(String jobId);

  /// Restore a soft-deleted image
  Future<void> restoreImage(String jobId);

  /// Retry a failed generation
  Future<void> retryGeneration(String jobId);

  /// Hard delete job and storage files
  Future<void> deleteJob(String jobId);

  /// Download image to device
  Future<String> downloadImage(String imageUrl);

  /// Get image file for sharing
  Future<File> getImageFile(String imageUrl);

  /// Toggle favorite status
  Future<void> toggleFavorite(String itemId, {required bool isFavorite});
}
