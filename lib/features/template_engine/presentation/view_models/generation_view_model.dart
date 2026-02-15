import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/generation_job_model.dart';
import '../../data/repositories/generation_repository.dart';
import '../providers/generation_policy_provider.dart';
import '../helpers/generation_job_manager.dart';

part 'generation_view_model.g.dart';

@riverpod
class GenerationViewModel extends _$GenerationViewModel {
  late final GenerationJobManager _jobManager;

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
        templateId: templateId,
        prompt: prompt,
        aspectRatio: aspectRatio,
        imageCount: imageCount,
      );

      _jobManager.watchJob(
        jobStream: repo.watchJob(jobId),
        onData: (job) => state = AsyncData(job),
        onError: (e, st) => state = AsyncError(e, st),
        onTimeout: () => state = AsyncError(
          Exception(
            'Generation timed out after '
            '${GenerationJobManager.defaultTimeoutMinutes} minutes',
          ),
          StackTrace.current,
        ),
      );
    } catch (e, st) {
      await _jobManager.captureOnce(e, st);
      state = AsyncError(e, st);
    }
  }

  void reset() {
    _jobManager.reset();
    state = const AsyncData(null);
  }
}
