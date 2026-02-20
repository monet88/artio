import 'package:artio/core/exceptions/app_exception.dart';
import 'package:artio/core/providers/supabase_provider.dart';
import 'package:artio/core/utils/retry.dart';
import 'package:artio/features/template_engine/data/services/template_cache_service.dart';
import 'package:artio/features/template_engine/domain/entities/template_model.dart';
import 'package:artio/features/template_engine/domain/repositories/i_template_repository.dart';
import 'package:artio/utils/logger_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'template_repository.g.dart';

@riverpod
TemplateRepository templateRepository(Ref ref) {
  return TemplateRepository(
    ref.watch(supabaseClientProvider),
    ref.watch(templateCacheServiceProvider),
  );
}

class TemplateRepository implements ITemplateRepository {
  const TemplateRepository(this._supabase, this._cache);

  final SupabaseClient _supabase;
  final TemplateCacheService _cache;

  @override
  Future<List<TemplateModel>> fetchTemplates() async {
    // Cache-first: return cached data if valid.
    if (_cache.isCacheValid()) {
      final cached = await _cache.getCachedTemplates();
      if (cached != null) return cached;
    }

    // Cache miss or expired — fetch from network.
    try {
      final templates = await _fetchTemplatesFromNetwork();
      await _cache.cacheTemplates(templates);
      return templates;
    } on AppException {
      // Network error: fallback to stale cache if available.
      final stale = await _cache.getCachedTemplates();
      if (stale != null) return stale;
      rethrow;
    }
  }

  @override
  Future<List<TemplateModel>> refreshTemplates() async {
    final templates = await _fetchTemplatesFromNetwork();
    await _cache.cacheTemplates(templates);
    return templates;
  }

  @override
  Future<TemplateModel?> fetchTemplate(String id) async {
    try {
      final response = await _supabase
          .from('templates')
          .select()
          .eq('id', id)
          .maybeSingle();

      return response != null ? TemplateModel.fromJson(response) : null;
    } on PostgrestException catch (e) {
      throw AppException.network(message: e.message);
    } catch (e) {
      throw AppException.unknown(message: e.toString(), originalError: e);
    }
  }

  @override
  Future<List<TemplateModel>> fetchByCategory(String category) async {
    try {
      final response = await _supabase
          .from('templates')
          .select()
          .eq('category', category)
          .eq('is_active', true)
          .order('order', ascending: true);

      final results = <TemplateModel>[];
      for (final item in response) {
        try {
          results.add(TemplateModel.fromJson(item));
        } on Exception catch (e) {
          // Skip the corrupted template and log the failure
          Log.w('Failed to parse a template from fetched category ($category): $e');
        }
      }
      return results;
    } on PostgrestException catch (e) {
      throw AppException.network(message: e.message);
    } catch (e) {
      throw AppException.unknown(message: e.toString(), originalError: e);
    }
  }

  @override
  Stream<List<TemplateModel>> watchTemplates() {
    return _supabase
        .from('templates')
        .stream(primaryKey: ['id'])
        .order('order', ascending: true)
        .map((data) => data.map(TemplateModel.fromJson).toList());
  }

  /// Internal: always goes to the network with retry.
  Future<List<TemplateModel>> _fetchTemplatesFromNetwork() async {
    return retry(() async {
      try {
        final response = await _supabase
            .from('templates')
            .select()
            .eq('is_active', true)
            .order('order', ascending: true);

        final results = <TemplateModel>[];
        for (final item in response) {
          try {
            results.add(TemplateModel.fromJson(item));
          } on Exception catch (e) {
            // Skip the corrupted template and log the failure
            Log.w('Failed to parse a template from network sync: $e');
          }
        }
        return results;
      } on PostgrestException catch (e) {
        throw AppException.network(message: e.message);
      } catch (e) {
        throw AppException.unknown(message: e.toString(), originalError: e);
      }
    });
  }
}
