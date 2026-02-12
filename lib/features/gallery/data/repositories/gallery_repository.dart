import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:storage_client/storage_client.dart' as storage_client;

import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/utils/retry.dart';
import '../../domain/entities/gallery_item.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../domain/repositories/i_gallery_repository.dart';

part 'gallery_repository.g.dart';

@riverpod
GalleryRepository galleryRepository(Ref ref) {
  return GalleryRepository(ref.watch(supabaseClientProvider));
}

class GalleryRepository implements IGalleryRepository {
  final SupabaseClient _supabase;

  const GalleryRepository(this._supabase);

  /// Convert job status string to enum
  GenerationStatus _parseStatus(String? status) {
    switch (status) {
      case 'pending':
        return GenerationStatus.pending;
      case 'generating':
        return GenerationStatus.generating;
      case 'processing':
        return GenerationStatus.processing;
      case 'completed':
        return GenerationStatus.completed;
      case 'failed':
        return GenerationStatus.failed;
      default:
        return GenerationStatus.pending;
    }
  }

  /// Parse job data to GalleryItem
  GalleryItem _parseJob(Map<String, dynamic> job, int imageIndex) {
    final urls = (job['result_urls'] as List?) ?? [];
    final imageUrl = imageIndex < urls.length ? urls[imageIndex] as String : null;
    
    return GalleryItem(
      id: '${job['id']}_$imageIndex',
      jobId: job['id'] as String,
      userId: job['user_id'] as String,
      imageUrl: imageUrl,
      templateId: (job['template_id'] as String?) ?? '',
      templateName: (job['templates']?['name'] as String?) ?? 'Unknown',
      prompt: job['prompt'] as String?,
      createdAt: DateTime.parse(job['created_at'] as String),
      status: _parseStatus(job['status'] as String?),
      resultPaths: urls.cast<String>(),
      deletedAt: job['deleted_at'] != null 
          ? DateTime.parse(job['deleted_at'] as String) 
          : null,
      isFavorite: (job['is_favorite'] as bool?) ?? false,
    );
  }

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
            items.add(_parseJob(job, 0));
          } else {
            for (int i = 0; i < urls.length; i++) {
              items.add(_parseJob(job, i));
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
            final job = row as Map<String, dynamic>;
            if (job['deleted_at'] != null) continue;

            final urls = (job['result_urls'] as List?) ?? [];
            if (urls.isEmpty) {
              items.add(_parseJob(job, 0));
            } else {
              for (int i = 0; i < urls.length; i++) {
                items.add(_parseJob(job, i));
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

      for (int i = 0; i < urls.length; i++) {
        try {
          await _supabase.storage
              .from('generated-images')
              .remove(['$userId/$jobId/$i.png']);
        } on storage_client.StorageException catch (e) {
          // Log but continue - orphaned files acceptable
          debugPrint('Storage cleanup failed: ${e.message}');
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

      // Re-trigger Edge Function
      await _supabase.functions.invoke('generate-image', body: {'jobId': jobId});
    } on PostgrestException catch (e) {
      throw AppException.storage(message: e.message);
    } on FunctionException catch (e) {
      throw AppException.generation(message: e.details?.toString() ?? 'Retry failed');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.unknown(message: 'Failed to retry generation', originalError: e);
    }
  }

  /// Extract file extension from URL path, fallback to .png
  String _extensionFromUrl(String url) {
    try {
      final path = Uri.parse(url).path;
      final lastDot = path.lastIndexOf('.');
      if (lastDot != -1 && lastDot < path.length - 1) {
        final ext = path.substring(lastDot).toLowerCase();
        if (const ['.png', '.jpg', '.jpeg', '.webp', '.gif'].contains(ext)) {
          return ext;
        }
      }
    } catch (_) {}
    return '.png';
  }

  /// Download image bytes to a file in the given directory
  Future<File> _downloadToFile(
    String imageUrl,
    Directory directory,
    String prefix,
  ) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode != 200) {
      throw AppException.network(
        message: 'Download failed',
        statusCode: response.statusCode,
      );
    }

    final ext = _extensionFromUrl(imageUrl);
    final fileName = '${prefix}_${DateTime.now().millisecondsSinceEpoch}$ext';
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  @override
  Future<String> downloadImage(String imageUrl) async {
    return retry(() async {
      try {
        final directory = await getTemporaryDirectory();
        final file = await _downloadToFile(imageUrl, directory, 'artio');

        // Save to gallery on mobile platforms
        if (!kIsWeb &&
            (defaultTargetPlatform == TargetPlatform.android ||
                defaultTargetPlatform == TargetPlatform.iOS)) {
          final result = await ImageGallerySaverPlus.saveFile(file.path);
          await file.delete().catchError((_) => file);
          if (result['isSuccess'] == true) {
            return 'Photos';
          }
        }

        // Desktop fallback: move to Documents
        final docsDir = await getApplicationDocumentsDirectory();
        final destPath = '${docsDir.path}/${file.uri.pathSegments.last}';
        await file.rename(destPath);
        return destPath;
      } catch (e) {
        if (e is AppException) rethrow;
        throw AppException.network(message: 'Failed to download image');
      }
    });
  }

  @override
  Future<File> getImageFile(String imageUrl) async {
    try {
      final directory = await getTemporaryDirectory();
      return await _downloadToFile(imageUrl, directory, 'share');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.network(message: 'Failed to get image file');
    }
  }

  @override
  Future<void> toggleFavorite(String itemId, bool isFavorite) async {
    try {
      final jobId = itemId.split('_').first;
      await _supabase
          .from('generation_jobs')
          .update({'is_favorite': isFavorite}).eq('id', jobId);
    } on PostgrestException catch (e) {
      throw AppException.storage(message: e.message);
    }
  }
}
