import 'package:artio/features/gallery/domain/entities/gallery_item.dart';

/// Test data factories for [GalleryItem]
class GalleryItemFixtures {
  /// Creates a single gallery item
  static GalleryItem single({
    String? id,
    String? jobId,
    String? userId,
    String? templateId,
    String? templateName,
    DateTime? createdAt,
    GenerationStatus? status,
    String? imageUrl,
    String? prompt,
    List<String>? resultPaths,
    bool isFavorite = false,
  }) =>
      GalleryItem(
        id: id ?? 'gallery-${DateTime.now().millisecondsSinceEpoch}',
        jobId: jobId ?? 'job-${DateTime.now().millisecondsSinceEpoch}',
        userId: userId ?? 'user-123',
        templateId: templateId ?? 'template-456',
        templateName: templateName ?? 'Portrait Template',
        createdAt: createdAt ?? DateTime.now().subtract(const Duration(hours: 2)),
        status: status ?? GenerationStatus.completed,
        imageUrl: imageUrl ?? 'https://storage.example.com/images/${DateTime.now().millisecondsSinceEpoch}.png',
        prompt: prompt ?? 'A beautiful portrait',
        resultPaths: resultPaths,
        isFavorite: isFavorite,
      );

  /// Creates a completed gallery item with image
  static GalleryItem completed({
    String? id,
    String? imageUrl,
  }) =>
      GalleryItemFixtures.single(
        id: id,
        imageUrl: imageUrl ?? 'https://storage.example.com/images/completed.png',
        status: GenerationStatus.completed,
        resultPaths: [imageUrl ?? 'https://storage.example.com/images/completed.png'],
      );

  /// Creates a failed gallery item
  static GalleryItem failed({String? id}) => GalleryItemFixtures.single(
        id: id,
        status: GenerationStatus.failed,
        imageUrl: null,
        resultPaths: null,
      );

  /// Creates a processing gallery item
  static GalleryItem processing({String? id}) => GalleryItemFixtures.single(
        id: id,
        status: GenerationStatus.processing,
        imageUrl: null,
        resultPaths: null,
      );

  /// Creates a favorite gallery item
  static GalleryItem favorite({String? id}) => GalleryItemFixtures.single(
        id: id,
        status: GenerationStatus.completed,
        isFavorite: true,
      );

  /// Creates a soft-deleted gallery item
  static GalleryItem deleted({String? id}) => GalleryItemFixtures.completed(
        id: id,
      ).copyWith(deletedAt: DateTime.now());

  /// Creates a list of gallery items
  static List<GalleryItem> list({int count = 10}) => List.generate(
        count,
        (i) {
          final statuses = [
            GenerationStatus.completed,
            GenerationStatus.completed,
            GenerationStatus.completed,
            GenerationStatus.completed,
            GenerationStatus.processing,
            GenerationStatus.failed,
          ];
          final currentStatus = statuses[i % statuses.length];
          return GalleryItemFixtures.single(
            id: 'gallery-$i',
            jobId: 'job-$i',
            status: currentStatus,
            imageUrl: currentStatus == GenerationStatus.completed
                ? 'https://storage.example.com/images/image-$i.png'
                : null,
            resultPaths: currentStatus == GenerationStatus.completed
                ? ['https://storage.example.com/images/image-$i.png']
                : null,
            isFavorite: i % 5 == 0,
          );
        },
      );

  /// Creates an empty list
  static List<GalleryItem> empty() => const [];
}
