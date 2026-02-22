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
/// Images are uploaded to `generated-images/{userId}/inputs/{uuid}.jpg`.
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
    final path = '$userId/inputs/${const Uuid().v4()}.jpg';
    await _supabase.storage.from(_bucket).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: false,
          ),
        );
    return path;
  }
}
