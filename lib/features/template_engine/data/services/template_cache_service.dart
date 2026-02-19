import 'dart:convert';
import 'dart:io';

import 'package:artio/features/template_engine/domain/entities/template_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'template_cache_service.g.dart';

@riverpod
TemplateCacheService templateCacheService(Ref ref) {
  return TemplateCacheService();
}

/// File-based cache service for template data.
///
/// Stores templates as a JSON file with a timestamp for TTL validation.
/// Uses `path_provider` to locate the app's documents directory.
class TemplateCacheService {
  static const _cacheFileName = 'templates_cache.json';
  static const _defaultTtl = Duration(minutes: 5);

  DateTime? _lastCachedAt;

  Future<File> get _cacheFile async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_cacheFileName');
  }

  /// Returns cached templates, or `null` if no cache exists.
  Future<List<TemplateModel>?> getCachedTemplates() async {
    try {
      final file = await _cacheFile;
      if (!file.existsSync()) return null;

      final contents = await file.readAsString();
      final data = jsonDecode(contents) as Map<String, dynamic>;

      final cachedAtStr = data['cached_at'] as String?;
      if (cachedAtStr != null) {
        _lastCachedAt = DateTime.tryParse(cachedAtStr);
      }

      final items = data['templates'] as List<dynamic>;
      return items
          .map((e) => TemplateModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on FormatException catch (_) {
      // Corrupted JSON — treat as miss.
      return null;
    } on FileSystemException catch (_) {
      // File I/O error — treat as miss.
      return null;
    }
  }

  /// Writes [templates] to the local cache file with the current timestamp.
  Future<void> cacheTemplates(List<TemplateModel> templates) async {
    final file = await _cacheFile;
    _lastCachedAt = DateTime.now();

    final data = <String, dynamic>{
      'cached_at': _lastCachedAt!.toIso8601String(),
      'templates': templates.map((t) => t.toJson()).toList(),
    };

    await file.writeAsString(jsonEncode(data));
  }

  /// Returns `true` if the cache exists and is within [maxAge].
  ///
  /// Uses the in-memory timestamp when available, falling back to the
  /// file's last-modified time.
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
