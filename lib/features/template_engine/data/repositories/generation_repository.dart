import 'dart:async';

import 'package:artio/core/config/sentry_config.dart';
import 'package:artio/core/constants/generation_constants.dart';
import 'package:artio/core/exceptions/app_exception.dart';
import 'package:artio/core/providers/supabase_provider.dart';
import 'package:artio/core/utils/retry.dart';
import 'package:artio/features/template_engine/domain/entities/generation_job_model.dart';
import 'package:artio/features/template_engine/domain/repositories/i_generation_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'generation_repository.g.dart';

@riverpod
GenerationRepository generationRepository(Ref ref) {
  return GenerationRepository(ref.watch(supabaseClientProvider));
}

class GenerationRepository implements IGenerationRepository {
  const GenerationRepository(this._supabase);
  final SupabaseClient _supabase;

  static const _maxEmptyWatchEvents = 3;

  @override
  Future<String> startGeneration({
    required String userId,
    required String templateId,
    required String prompt,
    String aspectRatio = '1:1',
    int imageCount = 1,
    String? outputFormat,
    String? modelId,
  }) async {
    try {
      // Step 1: Create job row in DB first (Edge Function verifies ownership)
      final jobInsert = await _supabase
          .from('generation_jobs')
          .insert({
            'user_id': userId,
            'template_id': templateId,
            'prompt': prompt,
            'status': 'pending',
            if (modelId != null) 'model_id': modelId,
          })
          .select('id')
          .single();

      final jobId = jobInsert['id'] as String;

      // Step 2: Call Edge Function — retry only this step, cleanup on failure
      try {
        final response = await retry(
          () => _supabase.functions
              .invoke(
                'generate-image',
                body: {
                  'jobId': jobId,
                  'userId': userId,
                  'template_id': templateId,
                  'prompt': prompt.trim(),
                  'aspect_ratio': aspectRatio,
                  'image_count': imageCount,
                  if (outputFormat != null) 'outputFormat': outputFormat,
                  if (modelId != null) 'model': modelId,
                },
              )
              .timeout(
                const Duration(seconds: kGenerationRequestTimeoutSeconds),
              ),
        );

        if (response.status == 429) {
          throw const AppException.network(
            message: 'Too many requests. Please wait a moment and try again.',
            statusCode: 429,
          );
        }

        if (response.status == 402) {
          throw const AppException.payment(
            message: 'Insufficient credits',
            code: 'insufficient_credits',
          );
        }

        if (response.status != 200) {
          final errorMsg = response.data is Map<String, dynamic>
              ? ((response.data as Map<String, dynamic>)['error'] as String?) ??
                    'Generation failed'
              : 'Generation failed';
          throw AppException.generation(message: errorMsg);
        }

        return jobId;
      } on Object {
        // Best-effort cleanup — mark orphaned job as failed
        try {
          await _supabase
              .from('generation_jobs')
              .update({'status': 'failed'})
              .eq('id', jobId);
        } on Object catch (e, st) {
          debugPrint('Failed to mark orphaned job $jobId as failed: $e');
          unawaited(SentryConfig.captureException(e, stackTrace: st));
        }
        rethrow;
      }
    } on FunctionException catch (e) {
      if (e.status == 429) {
        throw const AppException.network(
          message: 'Too many requests. Please wait a moment and try again.',
          statusCode: 429,
        );
      }
      if (e.status == 402) {
        throw const AppException.payment(
          message: 'Insufficient credits',
          code: 'insufficient_credits',
        );
      }
      throw AppException.generation(
        message: e.reasonPhrase ?? 'Generation failed',
      );
    } on TimeoutException {
      throw const AppException.network(
        message: 'Image generation timed out. Please try again.',
        statusCode: 408,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException.unknown(message: e.toString(), originalError: e);
    }
  }

  @override
  Stream<GenerationJobModel> watchJob(String jobId) {
    var emptyEventCount = 0;

    return _supabase
        .from('generation_jobs')
        .stream(primaryKey: ['id'])
        .eq('id', jobId)
        .transform(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              if (data.isEmpty) {
                emptyEventCount += 1;
                if (emptyEventCount >= _maxEmptyWatchEvents) {
                  sink.addError(
                    AppException.generation(
                      message: 'Job not found',
                      jobId: jobId,
                    ),
                  );
                }
                return;
              }

              emptyEventCount = 0;
              sink.add(GenerationJobModel.fromJson(data.first));
            },
          ),
        );
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

      return response.map(GenerationJobModel.fromJson).toList();
    } on PostgrestException catch (e) {
      throw AppException.network(message: e.message);
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
      throw AppException.network(message: e.message);
    } catch (e) {
      throw AppException.unknown(message: e.toString(), originalError: e);
    }
  }
}
