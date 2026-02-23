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

  /// Batch-resolves multiple storage paths in a single Supabase API call.
  /// Returns a map of storagePath → signedUrl (null if resolution failed).
  /// Paths that are already HTTPS URLs are returned as-is without an API call.
  Future<Map<String, String?>> signedUrls(List<String> paths) async {
    if (paths.isEmpty) return {};

    // Split: paths that need signing vs already-full URLs
    final toSign = <String>[];
    final result = <String, String?>{};

    for (final p in paths) {
      if (p.startsWith('http://') || p.startsWith('https://')) {
        result[p] = p;
      } else {
        toSign.add(p);
      }
    }

    if (toSign.isEmpty) return result;

    // Single API call for all storage paths
    final signed = await _supabase.storage
        .from(_bucket)
        .createSignedUrls(toSign, _signedUrlExpiry);

    for (final entry in signed) {
      result[entry.path] = entry.signedUrl;
    }

    return result;
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

/// Batch-resolves a list of gallery item image paths to signed URLs.
/// Returns a map of storagePath → signedUrl.
/// Use this at the page level to avoid N+1 signed URL API calls.
@riverpod
Future<Map<String, String?>> gallerySignedUrls(
  Ref ref,
  List<String> paths,
) async {
  final service = ref.watch(storageUrlServiceProvider);
  return service.signedUrls(paths);
}
