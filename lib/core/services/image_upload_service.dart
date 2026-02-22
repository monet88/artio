import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:artio/core/providers/supabase_provider.dart';

part 'image_upload_service.g.dart';

@riverpod
ImageUploadService imageUploadService(Ref ref) {
  return ImageUploadService(ref.watch(supabaseClientProvider));
}

/// Handles parallel image upload to Supabase Storage.
/// Images are uploaded to `generated-images/{userId}/inputs/{uuid}.{ext}`.
class ImageUploadService {
  const ImageUploadService(this._supabase);

  final SupabaseClient _supabase;
  static const _bucket = 'generated-images';

  /// Upload multiple images in parallel.
  /// Returns list of storage paths (relative to bucket root).
  Future<List<String>> uploadAll({
    required List<XFile> files,
    required String userId,
  }) async {
    if (files.isEmpty) return [];
    return Future.wait(
      files.map((f) => _uploadSingle(file: f, userId: userId)),
    );
  }

  Future<String> _uploadSingle({
    required XFile file,
    required String userId,
  }) async {
    final bytes = await file.readAsBytes();
    final mimeType = _detectMimeType(file);
    final ext = _extensionFromMime(mimeType);
    final path = '$userId/inputs/${const Uuid().v4()}$ext';
    await _supabase.storage.from(_bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: mimeType,
            upsert: false,
          ),
        );
    return path;
  }

  /// Detect MIME type from XFile metadata, falling back to extension then JPEG.
  static String _detectMimeType(XFile file) {
    // XFile.mimeType is set by image_picker on most platforms
    final xMime = file.mimeType;
    if (xMime != null && xMime.startsWith('image/')) return xMime;

    // Fallback: infer from file extension
    final name = file.name.toLowerCase();
    if (name.endsWith('.png')) return 'image/png';
    if (name.endsWith('.webp')) return 'image/webp';
    if (name.endsWith('.gif')) return 'image/gif';

    // Default: image_picker with imageQuality always outputs JPEG
    return 'image/jpeg';
  }

  static String _extensionFromMime(String mimeType) {
    return switch (mimeType) {
      'image/png' => '.png',
      'image/webp' => '.webp',
      'image/gif' => '.gif',
      _ => '.jpg',
    };
  }
}
