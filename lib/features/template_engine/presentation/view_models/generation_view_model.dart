import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/generation_job_model.dart';
import '../../data/repositories/generation_repository.dart';

part 'generation_view_model.g.dart';

@riverpod
class GenerationViewModel extends _$GenerationViewModel {
  StreamSubscription<GenerationJobModel>? _jobSubscription;

  @override
  AsyncValue<GenerationJobModel?> build() {
    ref.onDispose(() => _jobSubscription?.cancel());
    return const AsyncData(null);
  }

  Future<void> generate({
    required String templateId,
    required String prompt,
    String aspectRatio = '1:1',
    int imageCount = 1,
  }) async {
    state = const AsyncLoading();

    try {
      final repo = ref.read(generationRepositoryProvider);
      final jobId = await repo.startGeneration(
        templateId: templateId,
        prompt: prompt,
        aspectRatio: aspectRatio,
        imageCount: imageCount,
      );

      _jobSubscription?.cancel();
      _jobSubscription = repo.watchJob(jobId).listen(
        (job) {
          state = AsyncData(job);
          if (job.status == JobStatus.completed ||
              job.status == JobStatus.failed) {
            _jobSubscription?.cancel();
          }
        },
        onError: (Object e, StackTrace st) {
          state = AsyncError(e, st);
        },
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  void reset() {
    _jobSubscription?.cancel();
    state = const AsyncData(null);
  }
}
