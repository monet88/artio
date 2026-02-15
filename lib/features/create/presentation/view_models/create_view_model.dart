import 'dart:async';

import 'package:artio/core/constants/generation_constants.dart';
import 'package:artio/features/create/domain/entities/create_form_state.dart';
import 'package:artio/features/template_engine/data/repositories/generation_repository.dart';
import 'package:artio/features/template_engine/domain/entities/generation_job_model.dart';
import 'package:artio/features/template_engine/presentation/helpers/generation_job_manager.dart';
import 'package:artio/features/template_engine/presentation/providers/generation_policy_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_view_model.g.dart';

@riverpod
class CreateViewModel extends _$CreateViewModel {
  late final GenerationJobManager _jobManager;

  @override
  AsyncValue<GenerationJobModel?> build() {
    _jobManager = GenerationJobManager();
    ref.onDispose(_jobManager.cancel);
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
        templateId: kFreeTextTemplateId,
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
    } on Exception catch (e, st) {
      await _jobManager.captureOnce(e, st);
      state = AsyncError(e, st);
    }
  }

  void reset() {
    _jobManager.reset();
    state = const AsyncData(null);
  }
}
