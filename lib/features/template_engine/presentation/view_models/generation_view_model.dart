import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/generation_job_model.dart';
import '../../data/repositories/generation_repository.dart';
import '../providers/generation_policy_provider.dart';
import '../../../../core/config/sentry_config.dart';

part 'generation_view_model.g.dart';

@riverpod
class GenerationViewModel extends _$GenerationViewModel {
  StreamSubscription<GenerationJobModel>? _jobSubscription;
  Timer? _timeoutTimer;
  String? _lastErrorSignature;

  static const _jobTimeoutMinutes = 5;

  @override
  AsyncValue<GenerationJobModel?> build() {
    ref.onDispose(() {
      _jobSubscription?.cancel();
      _timeoutTimer?.cancel();
    });
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

      _jobSubscription?.cancel();
      _timeoutTimer?.cancel();

      // Start timeout timer
      _timeoutTimer = Timer(
        Duration(minutes: _jobTimeoutMinutes),
        () {
          _jobSubscription?.cancel();
          state = AsyncError(
            Exception('Generation timed out after $_jobTimeoutMinutes minutes'),
            StackTrace.current,
          );
        },
      );

      _jobSubscription = repo.watchJob(jobId).listen(
        (job) {
          state = AsyncData(job);
          if (job.status == JobStatus.completed ||
              job.status == JobStatus.failed) {
            _jobSubscription?.cancel();
            _timeoutTimer?.cancel();
          }
        },
         onError: (Object e, StackTrace st) async {
           await _captureOnce(e, st);
           state = AsyncError(e, st);
         },
      );
    } catch (e, st) {
      await _captureOnce(e, st);
      state = AsyncError(e, st);
    }
  }

  void reset() {
    _jobSubscription?.cancel();
    _timeoutTimer?.cancel();
    state = const AsyncData(null);
    _lastErrorSignature = null;
  }

  Future<void> _captureOnce(Object error, StackTrace? stackTrace) async {
    final signature = '${error.runtimeType}:${error.toString()}';
    if (_lastErrorSignature == signature) {
      return;
    }
    _lastErrorSignature = signature;
    await SentryConfig.captureException(error, stackTrace: stackTrace);
  }
}
