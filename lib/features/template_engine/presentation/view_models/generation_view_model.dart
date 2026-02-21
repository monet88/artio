import 'dart:async';

import 'package:artio/features/gallery/data/services/gallery_cache_service.dart';
import 'package:artio/features/template_engine/domain/entities/generation_job_model.dart';
import 'package:artio/features/template_engine/domain/providers/generation_repository_provider.dart';
import 'package:artio/features/template_engine/presentation/helpers/generation_job_manager.dart';
import 'package:artio/features/template_engine/presentation/providers/generation_policy_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generation_view_model.g.dart';

@riverpod
class GenerationViewModel extends _$GenerationViewModel {
  late GenerationJobManager _jobManager;

  bool get isGenerating =>
      state.isLoading ||
      state.valueOrNull?.status == JobStatus.pending ||
      state.valueOrNull?.status == JobStatus.generating ||
      state.valueOrNull?.status == JobStatus.processing;

  @override
  AsyncValue<GenerationJobModel?> build() {
    _jobManager = GenerationJobManager();
    ref.onDispose(_jobManager.cancel);
    return const AsyncData(null);
  }

  Future<void> generate({
    required String templateId,
    required String prompt,
    required String userId,
    String aspectRatio = '1:1',
    int imageCount = 1,
  }) async {
    if (isGenerating) {
      return;
    }

    state = const AsyncLoading();

    try {
      final policy = ref.read(generationPolicyProvider);
      final eligibility = await policy.canGenerate(
        userId: userId,
        templateId: templateId,
      );

      if (eligibility.isDenied) {
        state = AsyncError(
          Exception(eligibility.denialReason ?? 'Generation not allowed'),
          StackTrace.current,
        );
        return;
      }

      final repo = ref.read(generationRepositoryProvider);
      final jobId = await repo.startGeneration(
        userId: userId,
        templateId: templateId,
        prompt: prompt,
        aspectRatio: aspectRatio,
        imageCount: imageCount,
      );

      _jobManager.watchJob(
        jobStream: repo.watchJob(jobId),
        onData: (job) {
          state = AsyncData(job);
          if (job.status == JobStatus.completed) {
            ref.read(galleryCacheServiceProvider).clearCache();
          }
        },
        onError: (e, st) => state = AsyncError(e, st),
        onTimeout: () => state = AsyncError(
          Exception(
            'Generation timed out after '
            '${GenerationJobManager.defaultTimeoutMinutes} minutes',
          ),
          StackTrace.current,
        ),
      );
    } on Object catch (e, st) {
      await _jobManager.captureOnce(e, st);
      state = AsyncError(e, st);
    }
  }

  void reset() {
    _jobManager.reset();
    state = const AsyncData(null);
  }
}
