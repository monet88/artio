import 'dart:async';

import 'package:artio/core/config/sentry_config.dart';
import 'package:artio/features/create/domain/entities/create_form_state.dart';
import 'package:artio/features/template_engine/data/repositories/generation_repository.dart';
import 'package:artio/features/template_engine/domain/entities/generation_job_model.dart';
import 'package:artio/features/template_engine/presentation/providers/generation_policy_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_view_model.g.dart';

@riverpod
class CreateViewModel extends _$CreateViewModel {
  StreamSubscription<GenerationJobModel>? _jobSubscription;
  Timer? _timeoutTimer;
  String? _lastErrorSignature;

  static const _jobTimeoutMinutes = 5;

  @override
  AsyncValue<GenerationJobModel?> build() {
    ref.onDispose(() {
      unawaited(_jobSubscription?.cancel());
      _timeoutTimer?.cancel();
    });
    return const AsyncData(null);
  }

  Future<void> generate({
    required CreateFormState formState,
    required String userId,
  }) async {
    if (!formState.isValid) {
      state = AsyncError(
        Exception('Prompt must be at least 3 characters'),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncLoading();

    try {
      final policy = ref.read(generationPolicyProvider);
      final eligibility = await policy.canGenerate(
        userId: userId,
        templateId: 'free-text',
      );

      if (eligibility.isDenied) {
        state = AsyncError(
          Exception(eligibility.denialReason ?? 'Generation not allowed'),
          StackTrace.current,
        );
        return;
      }

      final params = formState.toGenerationParams();
      final repo = ref.read(generationRepositoryProvider);
      final jobId = await repo.startGeneration(
        templateId: params.templateId,
        prompt: params.prompt,
        aspectRatio: params.aspectRatio,
        imageCount: params.imageCount,
      );

      unawaited(_jobSubscription?.cancel());
      _timeoutTimer?.cancel();

      _timeoutTimer = Timer(
        const Duration(minutes: _jobTimeoutMinutes),
        () {
          unawaited(_jobSubscription?.cancel());
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
            unawaited(_jobSubscription?.cancel());
            _timeoutTimer?.cancel();
          }
        },
        onError: (Object e, StackTrace st) async {
          await _captureOnce(e, st);
          state = AsyncError(e, st);
        },
      );
    } on Exception catch (e, st) {
      await _captureOnce(e, st);
      state = AsyncError(e, st);
    }
  }

  void reset() {
    unawaited(_jobSubscription?.cancel());
    _timeoutTimer?.cancel();
    state = const AsyncData(null);
    _lastErrorSignature = null;
  }

  Future<void> _captureOnce(Object error, StackTrace? stackTrace) async {
    final signature = '${error.runtimeType}:$error';
    if (_lastErrorSignature == signature) {
      return;
    }
    _lastErrorSignature = signature;
    await SentryConfig.captureException(error, stackTrace: stackTrace);
  }
}
