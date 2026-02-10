import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../domain/entities/generation_job_model.dart';
import '../../domain/repositories/i_generation_repository.dart';

part 'generation_repository.g.dart';

@riverpod
GenerationRepository generationRepository(Ref ref) {
  return GenerationRepository(ref.watch(supabaseClientProvider));
}

class GenerationRepository implements IGenerationRepository {
  final SupabaseClient _supabase;

  const GenerationRepository(this._supabase);

  @override
  Future<String> startGeneration({
    required String templateId,
    required String prompt,
    String aspectRatio = '1:1',
    int imageCount = 1,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'generate-image',
        body: {
          'template_id': templateId,
          'prompt': prompt.trim(),
          'aspect_ratio': aspectRatio,
          'image_count': imageCount,
        },
      );

      if (response.status == 429) {
        throw const AppException.generation(
          message: 'Too many requests. Please wait a moment and try again.',
        );
      }

      if (response.status != 200) {
        final errorMsg = response.data is Map
            ? (response.data['error'] as String?) ?? 'Generation failed'
            : 'Generation failed';
        throw AppException.generation(message: errorMsg);
      }

      final data = response.data as Map<String, dynamic>?;
      if (data == null || data['job_id'] == null) {
        throw const AppException.generation(message: 'Invalid response from server');
      }

      return data['job_id'] as String;
    } on FunctionException catch (e) {
      if (e.status == 429) {
        throw const AppException.generation(
          message: 'Too many requests. Please wait a moment and try again.',
        );
      }
      throw AppException.generation(message: e.reasonPhrase ?? 'Generation failed');
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException.unknown(message: e.toString(), originalError: e);
    }
  }

  @override
  Stream<GenerationJobModel> watchJob(String jobId) {
    return _supabase
        .from('generation_jobs')
        .stream(primaryKey: ['id'])
        .eq('id', jobId)
        .map((data) {
          if (data.isEmpty) {
            throw AppException.generation(message: 'Job not found', jobId: jobId);
          }
          return GenerationJobModel.fromJson(data.first);
        });
  }

  @override
  Future<List<GenerationJobModel>> fetchUserJobs({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase
          .from('generation_jobs')
          .select()
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response.map((json) => GenerationJobModel.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw AppException.network(message: e.message, statusCode: int.tryParse(e.code ?? ''));
    } catch (e) {
      throw AppException.unknown(message: e.toString(), originalError: e);
    }
  }

  @override
  Future<GenerationJobModel?> fetchJob(String jobId) async {
    try {
      final response = await _supabase
          .from('generation_jobs')
          .select()
          .eq('id', jobId)
          .maybeSingle();

      return response != null ? GenerationJobModel.fromJson(response) : null;
    } on PostgrestException catch (e) {
      throw AppException.network(message: e.message, statusCode: int.tryParse(e.code ?? ''));
    } catch (e) {
      throw AppException.unknown(message: e.toString(), originalError: e);
    }
  }
}
