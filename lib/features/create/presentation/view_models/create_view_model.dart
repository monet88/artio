import 'dart:async';

import 'package:artio/core/constants/ai_models.dart';
import 'package:artio/core/constants/generation_constants.dart';
import 'package:artio/core/exceptions/app_exception.dart';
import 'package:artio/core/state/credit_balance_state_provider.dart';
import 'package:artio/features/create/domain/entities/create_form_state.dart';
import 'package:artio/features/gallery/data/services/gallery_cache_service.dart';
import 'package:artio/features/template_engine/domain/entities/generation_job_model.dart';
import 'package:artio/features/template_engine/domain/providers/generation_repository_provider.dart';
import 'package:artio/features/template_engine/presentation/helpers/generation_job_manager.dart';
import 'package:artio/features/template_engine/presentation/providers/generation_policy_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_view_model.g.dart';

@riverpod
class CreateViewModel extends _$CreateViewModel {
  late GenerationJobManager _jobManager;

  bool get isGenerating => isJobActive(state);

  /// Whether the given [AsyncValue] represents an active generation job.
  ///
  /// Shared with the UI so the screen can watch with `.select()` without
  /// duplicating the status check logic.
  static bool isJobActive(AsyncValue<GenerationJobModel?> value) =>
      value.isLoading ||
      value.valueOrNull?.status == JobStatus.pending ||
      value.valueOrNull?.status == JobStatus.generating ||
      value.valueOrNull?.status == JobStatus.processing;

  @override
  AsyncValue<GenerationJobModel?> build() {
    _jobManager = GenerationJobManager();
    ref.onDispose(_jobManager.cancel);
    return const AsyncData(null);
  }

  Future<void> generate({
    required CreateFormState formState,
    required String userId,
    required bool isPremiumUser,
  }) async {
    if (isGenerating) {
      return;
    }

    try {
      validateGenerationPrompt(formState.prompt);
    } on AppException catch (e, st) {
      state = AsyncError(e, st);
      return;
    }

    final selectedModel = AiModels.getById(formState.modelId);
    if (selectedModel == null) {
      state = AsyncError(
        const AppException.generation(
          message: 'Selected model is not supported',
        ),
        StackTrace.current,
      );
      return;
    }

    if (!selectedModel.supportedAspectRatios.contains(formState.aspectRatio)) {
      state = AsyncError(
        const AppException.generation(
          message: 'Selected aspect ratio is not supported by this model',
        ),
        StackTrace.current,
      );
      return;
    }

    if (selectedModel.isPremium && !isPremiumUser) {
      state = AsyncError(
        const AppException.generation(
          message: 'This model requires a premium subscription',
        ),
        StackTrace.current,
      );
      return;
    }

    // Optimistic credit check — only block if we have confirmed balance data.
    // If the stream is still loading or errored, let the Edge Function enforce.
    final creditState = ref.read(creditBalanceNotifierProvider);
    final confirmedBalance = creditState.valueOrNull?.balance;
    if (confirmedBalance != null &&
        confirmedBalance < selectedModel.creditCost) {
      state = AsyncError(
        const AppException.payment(
          message: 'Insufficient credits',
          code: 'insufficient_credits',
        ),
        StackTrace.current,
      );
      return;
    }

    state = const AsyncLoading();

    try {
      _jobManager.resetErrorDedup();

      final policy = ref.read(generationPolicyProvider);
      final eligibility = await policy.canGenerate(
        userId: userId,
        templateId: kFreeTextTemplateId,
      );

      if (eligibility.isDenied) {
        state = AsyncError(
          AppException.generation(
            message: eligibility.denialReason ?? 'Generation not allowed',
          ),
          StackTrace.current,
        );
        return;
      }

      final params = formState.toGenerationParams();
      final repo = ref.read(generationRepositoryProvider);
      final jobId = await repo.startGeneration(
        userId: userId,
        templateId: params.templateId,
        prompt: params.prompt,
        aspectRatio: params.aspectRatio,
        imageCount: params.imageCount,
        outputFormat: params.outputFormat,
        modelId: params.modelId,
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
          const AppException.generation(
            message:
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
