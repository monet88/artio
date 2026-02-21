import 'dart:convert';
import 'dart:io';

import 'package:artio/features/gallery/domain/entities/gallery_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gallery_cache_service.g.dart';

@riverpod
GalleryCacheService galleryCacheService(Ref ref) {
  return GalleryCacheService();
}

/// File-based cache service for gallery metadata.
///
/// Stores gallery items as a JSON file with a timestamp for TTL validation.
/// Uses `path_provider` to locate the app's documents directory.
class GalleryCacheService {
  /// Production constructor — resolves path via `path_provider`.
  GalleryCacheService();

  /// Test constructor — uses [directoryPath] directly.
  GalleryCacheService.forTesting(String directoryPath)
    : _directoryPath = directoryPath;

  static const _cacheFileName = 'gallery_cache.json';
  static const _defaultTtl = Duration(minutes: 5);

  String? _directoryPath;
  DateTime? _lastCachedAt;

  Future<File> get _cacheFile async {
    final path =
        _directoryPath ?? (await getApplicationDocumentsDirectory()).path;
    return File('$path/$_cacheFileName');
  }

  /// Returns cached gallery items, or `null` if no cache exists.
  Future<List<GalleryItem>?> getCachedItems() async {
    try {
      final file = await _cacheFile;
      if (!file.existsSync()) return null;

      final contents = await file.readAsString();
      final data = jsonDecode(contents) as Map<String, dynamic>;

      final cachedAtStr = data['cached_at'] as String?;
      if (cachedAtStr != null) {
        _lastCachedAt = DateTime.tryParse(cachedAtStr);
      }

      final items = data['items'] as List<dynamic>;
      return items
          .map((e) => GalleryItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on FormatException catch (_) {
      // Corrupted JSON — treat as miss.
      return null;
    } on FileSystemException catch (_) {
      // File I/O error — treat as miss.
      return null;
    }
  }

  /// Writes [items] to the local cache file with the current timestamp.
  Future<void> cacheItems(List<GalleryItem> items) async {
    final file = await _cacheFile;
    _lastCachedAt = DateTime.now();

    final data = <String, dynamic>{
      'cached_at': _lastCachedAt!.toIso8601String(),
      'items': items.map((e) => e.toJson()).toList(),
    };

    await file.writeAsString(jsonEncode(data));
  }

  /// Returns `true` if the cache exists and is within [maxAge].
  bool isCacheValid({Duration maxAge = _defaultTtl}) {
    if (_lastCachedAt == null) return false;
    return DateTime.now().difference(_lastCachedAt!) < maxAge;
  }

  /// Deletes the cache file and clears the in-memory timestamp.
  Future<void> clearCache() async {
    _lastCachedAt = null;
    final file = await _cacheFile;
    if (file.existsSync()) {
      await file.delete();
    }
  }
}
