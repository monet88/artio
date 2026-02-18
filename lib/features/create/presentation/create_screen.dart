import 'package:artio/core/constants/ai_models.dart';
import 'package:artio/core/constants/app_constants.dart';
import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/core/exceptions/app_exception.dart';
import 'package:artio/core/utils/app_exception_mapper.dart';
import 'package:artio/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:artio/features/create/domain/entities/create_form_state.dart';
import 'package:artio/features/create/presentation/providers/create_form_provider.dart';
import 'package:artio/features/create/presentation/view_models/create_view_model.dart';
import 'package:artio/features/create/presentation/widgets/aspect_ratio_selector.dart';
import 'package:artio/features/create/presentation/widgets/generation_progress_overlay.dart';
import 'package:artio/features/create/presentation/widgets/model_selector.dart';
import 'package:artio/features/create/presentation/widgets/prompt_input_field.dart';
import 'package:artio/features/credits/presentation/providers/credit_balance_provider.dart';
import 'package:artio/features/credits/presentation/widgets/insufficient_credits_sheet.dart';
import 'package:artio/features/credits/presentation/widgets/premium_model_sheet.dart';
import 'package:artio/features/template_engine/domain/entities/generation_job_model.dart';
import 'package:artio/routing/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateScreen extends ConsumerStatefulWidget {
  const CreateScreen({super.key});

  @override
  ConsumerState<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends ConsumerState<CreateScreen> {
  late final ProviderSubscription<AsyncValue<GenerationJobModel?>> _jobErrorSub;

  @override
  void initState() {
    super.initState();
    _jobErrorSub = ref.listenManual<AsyncValue<GenerationJobModel?>>(
      createViewModelProvider,
      fireImmediately: true,
      (previous, next) {
        final failedJob = next.valueOrNull;
        final previousFailedJob = previous?.valueOrNull;
        if (failedJob?.status == JobStatus.failed &&
            previousFailedJob?.status != JobStatus.failed) {
          final failedMessage =
              failedJob?.errorMessage?.trim().isNotEmpty ?? false
              ? failedJob!.errorMessage!.trim()
              : 'Generation failed. Please try again.';
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(failedMessage)),
            );
          });
        }

        next.whenOrNull(
          error: (error, _) {
            // Skip if we already showed a SnackBar for a failed job above
            if (next.valueOrNull?.status == JobStatus.failed) return;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;

              // Show bottom sheet for credit / premium errors
              if (error is PaymentException) {
                _showInsufficientCreditsSheet();
                return;
              }
              if (error is GenerationException &&
                  error.message == 'This model requires a premium subscription') {
                _showPremiumModelSheet();
                return;
              }

              final message = AppExceptionMapper.toUserMessage(error);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
            });
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _jobErrorSub.close();
    super.dispose();
  }

  void _handleGenerate(CreateFormState formState, {required bool isGenerating}) {
    if (isGenerating) {
      return;
    }

    final authState = ref.read(authViewModelProvider);
    final userId = authState.maybeMap(
          authenticated: (state) => state.user.id,
          orElse: () => null,
        );
    if (userId == null) {
      _showAuthGateBottomSheet();
      return;
    }

    final isPremiumUser = authState.maybeMap(
          authenticated: (state) => state.user.isPremium,
          orElse: () => false,
        );

    ref.read(createViewModelProvider.notifier).generate(
          formState: formState,
          userId: userId,
          isPremiumUser: isPremiumUser,
        );
  }

  void _showAuthGateBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Sign in to create',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Create an account or sign in to start generating AI art',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  const LoginRoute().go(this.context);
                },
                child: const Text('Sign In'),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  const RegisterRoute().go(this.context);
                },
                child: const Text('Create Account'),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  void _showInsufficientCreditsSheet() {
    final balance = ref.read(creditBalanceNotifierProvider).valueOrNull?.balance ?? 0;
    final formState = ref.read(createFormNotifierProvider);
    final model = AiModels.getById(formState.modelId);
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => InsufficientCreditsSheet(
        currentBalance: balance,
        requiredCredits: model?.creditCost ?? 0,
      ),
    );
  }

  void _showPremiumModelSheet() {
    final formState = ref.read(createFormNotifierProvider);
    final model = AiModels.getById(formState.modelId);
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => PremiumModelSheet(
        modelName: model?.displayName ?? 'This model',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(createFormNotifierProvider);
    final formNotifier = ref.read(createFormNotifierProvider.notifier);
    final jobState = ref.watch(createViewModelProvider);
    final isGenerating = ref.watch(
      createViewModelProvider.select(CreateViewModel.isJobActive),
    );

    // Wire isPremium from user's actual subscription status
    final isPremium = ref.watch(authViewModelProvider).maybeMap(
          authenticated: (state) => state.user.isPremium,
          orElse: () => false,
        );

    // Only show prompt error after user has interacted with the field
    final promptLength = formState.prompt.trim().length;
    final showPromptError = !formState.isValid && formNotifier.hasInteracted;
    final promptErrorText = !showPromptError
        ? null
        : promptLength < 3
        ? 'Prompt must be at least 3 characters'
        : 'Prompt must be at most ${AppConstants.maxPromptLength} characters';

    return Scaffold(
      appBar: AppBar(title: const Text('Create')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Text to Image',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Create high quality images from your prompt',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                // Credit balance chip (authenticated users only)
                if (ref.watch(authViewModelProvider).maybeMap(
                      authenticated: (_) => true,
                      orElse: () => false,
                    ))
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: ref.watch(creditBalanceNotifierProvider).maybeWhen(
                      data: (balance) => Align(
                        alignment: Alignment.centerLeft,
                        child: Chip(
                          avatar: const Text('💎', style: TextStyle(fontSize: 14)),
                          label: Text('${balance.balance} credits'),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      loading: () => const Align(
                        alignment: Alignment.centerLeft,
                        child: Chip(
                          avatar: Text('💎', style: TextStyle(fontSize: 14)),
                          label: Text('...'),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      orElse: () => const SizedBox.shrink(),
                    ),
                  ),
                PromptInputField(
                  label: 'Prompt',
                  hintText: 'Describe the image you want...',
                  value: formState.prompt,
                  onChanged: formNotifier.setPrompt,
                  errorText: promptErrorText,
                ),
                const SizedBox(height: AppSpacing.md),
                PromptInputField(
                  label: 'Negative prompt (optional)',
                  hintText: 'Describe what to avoid...',
                  value: formState.negativePrompt,
                  onChanged: formNotifier.setNegativePrompt,
                ),
                const SizedBox(height: AppSpacing.lg),
                AspectRatioSelector(
                  selectedRatio: formState.aspectRatio,
                  selectedModelId: formState.modelId,
                  onChanged: formNotifier.setAspectRatio,
                ),
                const SizedBox(height: AppSpacing.md),
                ModelSelector(
                  selectedModelId: formState.modelId,
                  isPremium: isPremium,
                  onChanged: formNotifier.setModel,
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: formState.isValid && !isGenerating
                      ? () => _handleGenerate(
                          formState,
                          isGenerating: isGenerating,
                        )
                      : null,
                  child: const Text('Generate'),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (jobState.valueOrNull?.status == JobStatus.completed) ...[
                  Text(
                    'Generation completed. Check Gallery for results.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  FilledButton(
                    onPressed: () => ref
                        .read(createViewModelProvider.notifier)
                        .reset(),
                    child: const Text('Generate another'),
                  ),
                ],
              ],
            ),
          ),
          if (isGenerating) ...[
            if (jobState.valueOrNull != null)
              GenerationProgressOverlay(job: jobState.valueOrNull!)
            else
              // Show a simple loading indicator before the first stream event
              Positioned.fill(
                child: ColoredBox(
                  color: Theme.of(context)
                      .colorScheme
                      .surface
                      .withValues(alpha: 0.9),
                  child: Center(
                    child: Card(
                      child: Padding(
                        padding: AppSpacing.cardPadding,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Starting generation...',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
