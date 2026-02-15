import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/core/utils/app_exception_mapper.dart';
import 'package:artio/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:artio/features/create/domain/entities/create_form_state.dart';
import 'package:artio/features/create/presentation/providers/create_form_provider.dart';
import 'package:artio/features/create/presentation/view_models/create_view_model.dart';
import 'package:artio/features/create/presentation/widgets/aspect_ratio_selector.dart';
import 'package:artio/features/create/presentation/widgets/generation_progress_overlay.dart';
import 'package:artio/features/create/presentation/widgets/model_selector.dart';
import 'package:artio/features/create/presentation/widgets/prompt_input_field.dart';
import 'package:artio/features/template_engine/domain/entities/generation_job_model.dart';

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
      (previous, next) {
        next.whenOrNull(
          error: (error, _) {
            final message = AppExceptionMapper.toUserMessage(error);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
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

  void _handleGenerate(CreateFormState formState) {
    final userId = ref.read(authViewModelProvider).maybeMap(
          authenticated: (state) => state.user.id,
          orElse: () => null,
        );
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please log in to generate images'),
          action: SnackBarAction(
            label: 'Login',
            onPressed: () => context.go('/login'),
          ),
        ),
      );
      return;
    }

    ref.read(createViewModelProvider.notifier).generate(
          formState: formState,
          userId: userId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(createFormNotifierProvider);
    final formNotifier = ref.read(createFormNotifierProvider.notifier);
    final jobState = ref.watch(createViewModelProvider);
    final isGenerating = jobState.isLoading ||
        jobState.valueOrNull?.status == JobStatus.pending ||
        jobState.valueOrNull?.status == JobStatus.generating ||
        jobState.valueOrNull?.status == JobStatus.processing;

    // Wire isPremium from user's actual subscription status
    final isPremium = ref.watch(authViewModelProvider).maybeMap(
          authenticated: (state) => state.user.isPremium,
          orElse: () => false,
        );

    // Only show prompt error after user has interacted with the field
    final showPromptError =
        !formState.isValid && formNotifier.hasInteracted;

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
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Create high quality images from your prompt',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: AppSpacing.lg),
                PromptInputField(
                  label: 'Prompt',
                  hintText: 'Describe the image you want...',
                  value: formState.prompt,
                  onChanged: (value) => formNotifier.setPrompt(value),
                  errorText: showPromptError
                      ? 'Prompt must be at least 3 characters'
                      : null,
                ),
                SizedBox(height: AppSpacing.md),
                PromptInputField(
                  label: 'Negative prompt (optional)',
                  hintText: 'Describe what to avoid...',
                  value: formState.negativePrompt,
                  onChanged: (value) => formNotifier.setNegativePrompt(value),
                ),
                SizedBox(height: AppSpacing.lg),
                AspectRatioSelector(
                  selectedRatio: formState.aspectRatio,
                  selectedModelId: formState.modelId,
                  onChanged: (ratio) => formNotifier.setAspectRatio(ratio),
                ),
                SizedBox(height: AppSpacing.md),
                ModelSelector(
                  selectedModelId: formState.modelId,
                  isPremium: isPremium,
                  onChanged: (modelId) => formNotifier.setModel(modelId),
                ),
                SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: formState.isValid
                      ? () => _handleGenerate(formState)
                      : null,
                  child: const Text('Generate'),
                ),
                SizedBox(height: AppSpacing.lg),
                if (jobState.valueOrNull?.status == JobStatus.completed) ...[
                  Text(
                    'Generation completed. Check Gallery for results.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: AppSpacing.sm),
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
                child: Container(
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
                            SizedBox(height: AppSpacing.md),
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
