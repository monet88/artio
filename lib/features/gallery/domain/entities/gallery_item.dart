import 'package:freezed_annotation/freezed_annotation.dart';

part 'gallery_item.freezed.dart';
part 'gallery_item.g.dart';

/// Generation status for gallery items
enum GenerationStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('generating')
  generating,
  @JsonValue('processing')
  processing,
  @JsonValue('completed')
  completed,
  @JsonValue('failed')
  failed,
}

@freezed
class GalleryItem with _$GalleryItem {
  const factory GalleryItem({
    required String id,
    required String jobId,
    required String userId,
    required String templateId,
    required String templateName,
    required DateTime createdAt,
    required GenerationStatus status,
    String? imageUrl,
    String? prompt,
    List<String>? resultPaths,
    DateTime? deletedAt,
    @Default(false) bool isFavorite,
  }) = _GalleryItem;

  factory GalleryItem.fromJson(Map<String, dynamic> json) =>
      _$GalleryItemFromJson(json);
}
