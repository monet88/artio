import 'package:artio/core/providers/supabase_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'storage_url_service.g.dart';

const _bucket = 'generated-images';
const _signedUrlExpiry = 3600; // 1 hour

/// Converts a Supabase storage path to a signed HTTPS URL.
class StorageUrlService {
  const StorageUrlService(this._supabase);
  final SupabaseClient _supabase;

  /// Returns a signed URL for a storage path like `userId/filename.jpg`.
  /// If the input is already a full HTTPS URL, returns it unchanged.
  Future<String?> signedUrl(String path) async {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    return _supabase.storage
        .from(_bucket)
        .createSignedUrl(path, _signedUrlExpiry);
  }
}

@riverpod
StorageUrlService storageUrlService(Ref ref) {
  return StorageUrlService(ref.watch(supabaseClientProvider));
}

/// Resolves a single storage path to a signed HTTPS URL.
/// Used in widgets via `ref.watch(signedStorageUrlProvider(path))`.
@riverpod
Future<String?> signedStorageUrl(Ref ref, String storagePath) async {
  final service = ref.watch(storageUrlServiceProvider);
  return service.signedUrl(storagePath);
}
