import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../domain/entities/gallery_item.dart';
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
    var query = _supabase
        .from('generation_jobs')
        .select('*, templates(name)')
        .isFilter('deleted_at', null); // Only non-deleted items

    if (templateId != null) {
      query = query.eq('template_id', templateId);
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    
    final items = <GalleryItem>[];

    for (final job in response as List) {
      final urls = (job['result_urls'] as List?) ?? [];
      if (urls.isEmpty && job['status'] != 'completed') {
        // Show pending/failed jobs without images
        items.add(_parseJob(job, 0));
      } else {
        for (int i = 0; i < urls.length; i++) {
          items.add(_parseJob(job, i));
        }
      }
    }

    return items;
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
          for (final job in data) {
            if (job['deleted_at'] != null) continue; // Skip deleted
            
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
      } catch (_) {
        // Continue even if storage deletion fails
      }
    }

    await _supabase.from('generation_jobs').delete().eq('id', jobId);
  }

  /// Soft delete - sets deleted_at timestamp
  @override
  Future<void> softDeleteImage(String jobId) async {
    await _supabase
        .from('generation_jobs')
        .update({'deleted_at': DateTime.now().toIso8601String()})
        .eq('id', jobId);
  }

  /// Restore soft-deleted image
  @override
  Future<void> restoreImage(String jobId) async {
    await _supabase
        .from('generation_jobs')
        .update({'deleted_at': null})
        .eq('id', jobId);
  }

  /// Retry failed generation
  @override
  Future<void> retryGeneration(String jobId) async {
    // Reset status to pending
    await _supabase
        .from('generation_jobs')
        .update({'status': 'pending', 'error_message': null})
        .eq('id', jobId);

    // Re-trigger Edge Function
    await _supabase.functions.invoke('generate-image', body: {'jobId': jobId});
  }

  @override
  Future<String> downloadImage(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to download image');
    }

    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'artio_${DateTime.now().millisecondsSinceEpoch}.png';
    final filePath = '${directory.path}/$fileName';

    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);

    return filePath;
  }

  @override
  Future<File> getImageFile(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to download image');
    }

    final directory = await getTemporaryDirectory();
    final file = File(
      '${directory.path}/share_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(response.bodyBytes);

    return file;
  }

  @override
  Future<void> toggleFavorite(String itemId, bool isFavorite) async {
    final jobId = itemId.split('_').first;
    await _supabase
        .from('generation_jobs')
        .update({'is_favorite': isFavorite}).eq('id', jobId);
  }
}
