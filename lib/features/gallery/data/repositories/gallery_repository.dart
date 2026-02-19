import 'dart:async';
import 'dart:io';

import 'package:artio/core/config/sentry_config.dart';
import 'package:artio/core/exceptions/app_exception.dart';
import 'package:artio/core/providers/supabase_provider.dart';
import 'package:artio/core/utils/retry.dart';
import 'package:artio/features/gallery/data/repositories/gallery_repository_helpers.dart';
import 'package:artio/features/gallery/domain/entities/gallery_item.dart';
import 'package:artio/features/gallery/domain/repositories/i_gallery_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:storage_client/storage_client.dart' as storage_client;
import 'package:supabase_flutter/supabase_flutter.dart' hide StorageException;

part 'gallery_repository.g.dart';

@riverpod
GalleryRepository galleryRepository(Ref ref) {
  return GalleryRepository(ref.watch(supabaseClientProvider));
}

class GalleryRepository implements IGalleryRepository {

  const GalleryRepository(this._supabase);
  final SupabaseClient _supabase;

  @override
  Future<List<GalleryItem>> fetchGalleryItems({
    int limit = 20,
    int offset = 0,
    String? templateId,
  }) async {
    return retry(() async {
      try {
        var query = _supabase
            .from('generation_jobs')
            .select('*, templates(name)')
            .isFilter('deleted_at', null);

        if (templateId != null) {
          query = query.eq('template_id', templateId);
        }

        final response = await query
            .order('created_at', ascending: false)
            .range(offset, offset + limit - 1);

        final items = <GalleryItem>[];

        for (final row in response as List) {
          final job = row as Map<String, dynamic>;
          final urls = (job['result_urls'] as List?) ?? [];
          if (urls.isEmpty && job['status'] != 'completed') {
            items.add(parseJob(job, 0));
          } else {
            for (var i = 0; i < urls.length; i++) {
              items.add(parseJob(job, i));
            }
          }
        }

        return items;
      } on PostgrestException catch (e) {
        throw AppException.network(message: e.message);
      }
    });
  }

  /// Watch user images with realtime updates
  @override
  Stream<List<GalleryItem>> watchUserImages({required String userId}) {
    return _supabase
        .from('generation_jobs')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at')
        .map((data) {
          final items = <GalleryItem>[];
          for (final row in data) {
            final job = row;
            if (job['deleted_at'] != null) continue;

            final urls = (job['result_urls'] as List?) ?? [];
            if (urls.isEmpty) {
              items.add(parseJob(job, 0));
            } else {
              for (var i = 0; i < urls.length; i++) {
                items.add(parseJob(job, i));
              }
            }
          }
          return items;
        });
  }

  @override
  Future<void> deleteJob(String jobId) async {
    try {
      // Hard delete - use softDeleteImage for soft delete
      final job = await _supabase
          .from('generation_jobs')
          .select('result_urls, user_id')
          .eq('id', jobId)
          .single();

      final userId = job['user_id'] as String;
      final urls = (job['result_urls'] as List?) ?? [];

      for (var i = 0; i < urls.length; i++) {
        try {
          await _supabase.storage
              .from('generated-images')
              .remove(['$userId/$jobId/$i.png']);
        } on storage_client.StorageException catch (e) {
          // Report to Sentry for production visibility
          unawaited(SentryConfig.captureException(e, stackTrace: StackTrace.current));
        }
      }

      await _supabase.from('generation_jobs').delete().eq('id', jobId);
    } on PostgrestException catch (e) {
      throw AppException.storage(message: e.message);
    }
  }

  @override
  Future<void> softDeleteImage(String jobId) async {
    try {
      await _supabase
          .from('generation_jobs')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', jobId);
    } on PostgrestException catch (e) {
      throw AppException.storage(message: e.message);
    }
  }

  @override
  Future<void> restoreImage(String jobId) async {
    try {
      await _supabase
          .from('generation_jobs')
          .update({'deleted_at': null})
          .eq('id', jobId);
    } on PostgrestException catch (e) {
      throw AppException.storage(message: e.message);
    }
  }

  /// Retry failed generation
  @override
  Future<void> retryGeneration(String jobId) async {
    try {
      // Reset status to pending
      await _supabase
          .from('generation_jobs')
          .update({'status': 'pending', 'error_message': null})
          .eq('id', jobId);

      // Re-trigger Edge Function with retry for network resilience
      await retry(() => _supabase.functions.invoke('generate-image', body: {'jobId': jobId}));
    } on PostgrestException catch (e) {
      throw AppException.storage(message: e.message);
    } on FunctionException catch (e) {
      throw AppException.generation(message: e.details?.toString() ?? 'Retry failed');
    } on Exception catch (e) {
      if (e is AppException) rethrow;
      throw AppException.unknown(message: 'Failed to retry generation', originalError: e);
    }
  }

  @override
  Future<String> downloadImage(String imageUrl) async {
    return retry(() async {
      try {
        final directory = await getTemporaryDirectory();
        final file = await downloadToFile(imageUrl, directory, 'artio');

        // Save to gallery on mobile platforms
        if (!kIsWeb &&
            (defaultTargetPlatform == TargetPlatform.android ||
                defaultTargetPlatform == TargetPlatform.iOS)) {
          final result = await ImageGallerySaverPlus.saveFile(file.path);
          await file.delete().catchError((_) => file);
          if (result is Map && result['isSuccess'] == true) {
            return 'Photos';
          }
        }

        // Desktop fallback: move to Documents
        final docsDir = await getApplicationDocumentsDirectory();
        final destPath = '${docsDir.path}/${file.uri.pathSegments.last}';
        await file.rename(destPath);
        return destPath;
      } on FileSystemException catch (e) {
        throw AppException.storage(message: 'Failed to save image: ${e.message}');
      } on Exception catch (e) {
        if (e is AppException) rethrow;
        throw const AppException.network(message: 'Failed to download image');
      }
    });
  }

  @override
  Future<File> getImageFile(String imageUrl) async {
    try {
      final directory = await getTemporaryDirectory();
      return await downloadToFile(imageUrl, directory, 'share');
    } on FileSystemException catch (e) {
      throw AppException.storage(message: 'Failed to save image: ${e.message}');
    } on Exception catch (e) {
      if (e is AppException) rethrow;
      throw const AppException.network(message: 'Failed to get image file');
    }
  }

  @override
  Future<void> toggleFavorite(String itemId, {required bool isFavorite}) async {
    final separatorIndex = itemId.lastIndexOf('_');
    if (separatorIndex == -1) {
      throw const AppException.storage(message: 'Invalid item ID format');
    }
    final jobId = itemId.substring(0, separatorIndex);
    try {
      await _supabase
          .from('generation_jobs')
          .update({'is_favorite': isFavorite}).eq('id', jobId);
    } on PostgrestException catch (e) {
      throw AppException.storage(message: e.message);
    }
  }
}
