import 'dart:async';

import 'package:artio/core/config/sentry_config.dart';
import 'package:artio/core/design_system/app_dimensions.dart';
import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/core/utils/app_exception_mapper.dart';
import 'package:artio/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:artio/features/template_engine/domain/entities/generation_job_model.dart';
import 'package:artio/features/template_engine/domain/entities/input_field_model.dart';
import 'package:artio/features/template_engine/domain/entities/template_model.dart';
import 'package:artio/features/template_engine/presentation/providers/generation_options_provider.dart';
import 'package:artio/features/template_engine/presentation/providers/template_provider.dart';
import 'package:artio/features/template_engine/presentation/view_models/generation_view_model.dart';
import 'package:artio/features/template_engine/presentation/widgets/generation_progress.dart';
import 'package:artio/features/template_engine/presentation/widgets/input_field_builder.dart';
import 'package:artio/shared/widgets/aspect_ratio_selector.dart';
import 'package:artio/shared/widgets/image_count_dropdown.dart';
import 'package:artio/shared/widgets/loading_state_widget.dart';
import 'package:artio/shared/widgets/model_selector.dart';
import 'package:artio/shared/widgets/output_format_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TemplateDetailScreen extends ConsumerStatefulWidget {

  const TemplateDetailScreen({required this.templateId, super.key});
  final String templateId;

  @override
  ConsumerState<TemplateDetailScreen> createState() => _TemplateDetailScreenState();
}

class _TemplateDetailScreenState extends ConsumerState<TemplateDetailScreen> {
  final Map<String, String> _inputValues = {};
  final Set<String> _reportedErrors = <String>{};
  final _formKey = GlobalKey<FormState>();
  ProviderSubscription<AsyncValue<TemplateModel?>>? _templateErrorSub;
  ProviderSubscription<AsyncValue<GenerationJobModel?>>? _jobErrorSub;

  // Placeholder for premium status - will be integrated with subscription later
  bool get _isPremium => false;

  String _buildPrompt(TemplateModel template) {
    var prompt = template.promptTemplate;
    for (final entry in _inputValues.entries) {
      prompt = prompt.replaceAll('{${entry.key}}', entry.value);
    }
    
    // Append otherIdeas if non-empty
    final otherIdeas = _inputValues['otherIdeas']?.trim() ?? '';
    if (otherIdeas.isNotEmpty) {
      prompt += '\n\nAdditional details: $otherIdeas';
    }
    
    return prompt;
  }

  void _handleGenerate(TemplateModel template) {
    final userId = ref.read(authViewModelProvider).maybeMap(
          authenticated: (s) => s.user.id,
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

    final options = ref.read(generationOptionsProvider);
    final prompt = _buildPrompt(template);

    // Validate form inputs
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Check for unreplaced placeholders
    final unresolved = RegExp(r'\{[a-zA-Z_]+\}').allMatches(prompt);
    if (unresolved.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }
    
    ref.read(generationViewModelProvider.notifier).generate(
          templateId: template.id,
          prompt: prompt,
          userId: userId,
          aspectRatio: options.aspectRatio,
          imageCount: options.imageCount,
        );
  }

  void _captureOnce(Object error, StackTrace? stackTrace) {
    final signature = '${error.runtimeType}:$error';
    if (_reportedErrors.add(signature)) {
      unawaited(SentryConfig.captureException(error, stackTrace: stackTrace));
    }
  }

  @override
  void initState() {
    super.initState();
    _templateErrorSub = ref.listenManual<AsyncValue<TemplateModel?>>(
      templateByIdProvider(widget.templateId),
      (previous, next) {
        next.whenOrNull(
          error: (error, stackTrace) {
            _captureOnce(error, stackTrace);
          },
        );
      },
    );

    _jobErrorSub = ref.listenManual<AsyncValue<GenerationJobModel?>>(
      generationViewModelProvider,
      (previous, next) {
        next.whenOrNull(
          error: (error, stackTrace) {
            _captureOnce(error, stackTrace);
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _templateErrorSub?.close();
    _jobErrorSub?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final templateAsync = ref.watch(templateByIdProvider(widget.templateId));
    final jobAsync = ref.watch(generationViewModelProvider);
    final options = ref.watch(generationOptionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Generate')),
      body: templateAsync.when(
        loading: () => const LoadingStateWidget(),
        error: (e, _) => Center(child: Text(AppExceptionMapper.toUserMessage(e))),
        data: (template) {
          if (template == null) {
            return const Center(child: Text('Template not found'));
          }

          return SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Template thumbnail
                if (template.thumbnailUrl.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: AppDimensions.buttonRadius,
                    child: Image.network(
                      template.thumbnailUrl,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => GestureDetector(
                        onTap: () => setState(() {}), // Force rebuild to retry
                        child: const SizedBox(
                          height: 200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image, size: AppDimensions.iconXl),
                              SizedBox(height: 8),
                              Text('Tap to retry', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                // Template info
                Text(template.name, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.sm),
                Text(template.description),
                const SizedBox(height: AppSpacing.lg),

                // Template input fields
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      for (final field in template.inputFields) ...[
                        InputFieldBuilder(
                          field: field,
                          onChanged: (value) => _inputValues[field.name] = value,
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    ],
                  ),
                ),

                // Other Ideas input (optional)
                InputFieldBuilder(
                  field: const InputFieldModel(
                    name: 'otherIdeas',
                    label: 'Other Ideas (Optional)',
                    type: 'otherIdeas',
                    placeholder: 'Share any additional ideas...',
                  ),
                  onChanged: (value) => _inputValues['otherIdeas'] = value,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Generation Options Section
                Text(
                  'Generation Options',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Aspect Ratio Selector
                AspectRatioSelector(
                  selectedRatio: options.aspectRatio,
                  selectedModelId: options.modelId,
                  onChanged: (ratio) => ref.read(generationOptionsProvider.notifier).updateAspectRatio(ratio),
                ),
                const SizedBox(height: AppSpacing.md),

                // Image Count Dropdown
                ImageCountDropdown(
                  value: options.imageCount,
                  onChanged: (count) => ref.read(generationOptionsProvider.notifier).updateImageCount(count),
                ),
                const SizedBox(height: AppSpacing.md),

                // Output Format Toggle
                OutputFormatToggle(
                  value: options.outputFormat,
                  isPremium: _isPremium,
                  onChanged: (format) => ref.read(generationOptionsProvider.notifier).updateOutputFormat(format),
                ),
                const SizedBox(height: AppSpacing.md),

                // Model Selector
                ModelSelector(
                  selectedModelId: options.modelId,
                  isPremium: _isPremium,
                  onChanged: (modelId) => ref.read(generationOptionsProvider.notifier).updateModel(modelId),
                  filterByType: 'text-to-image',
                ),
                const SizedBox(height: AppSpacing.lg),

                // Generation State (button/progress)
                _buildGenerationState(jobAsync, template),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGenerationState(AsyncValue<GenerationJobModel?> jobAsync, TemplateModel template) {
    final isGenerating = ref.read(generationViewModelProvider.notifier).isGenerating;

    return jobAsync.when(
      loading: () => const LoadingStateWidget(),
       error: (error, _) => Column(
         children: [
           Text(
             AppExceptionMapper.toUserMessage(error),
             style: TextStyle(color: Theme.of(context).colorScheme.error),
           ),
          const SizedBox(height: AppSpacing.sm),
          FilledButton(
            onPressed: isGenerating
                ? null
                : () {
                    ref.read(generationViewModelProvider.notifier).reset();
                    _handleGenerate(template);
                  },
            child: const Text('Retry'),
          ),
        ],
      ),
      data: (job) {
        if (job == null) {
          return FilledButton(
            onPressed: isGenerating ? null : () => _handleGenerate(template),
            child: const Text('Generate'),
          );
        }

        return Column(
          children: [
            GenerationProgress(job: job),
            const SizedBox(height: AppSpacing.md),
            if (job.status == JobStatus.completed)
              FilledButton(
                onPressed: () => ref.read(generationViewModelProvider.notifier).reset(),
                child: const Text('Generate Another'),
              ),
          ],
        );
      },
    );
  }
}
