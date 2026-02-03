import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/view_models/auth_view_model.dart';
import '../../../../core/config/sentry_config.dart';
import '../../../../core/utils/app_exception_mapper.dart';
import '../../../../shared/widgets/aspect_ratio_selector.dart';
import '../../../../shared/widgets/image_count_dropdown.dart';
import '../../../../shared/widgets/model_selector.dart';
import '../../../../shared/widgets/output_format_toggle.dart';
import '../../domain/entities/generation_job_model.dart';
import '../../domain/entities/input_field_model.dart';
import '../../domain/entities/template_model.dart';
import '../providers/generation_options_provider.dart';
import '../providers/template_provider.dart';
import '../view_models/generation_view_model.dart';
import '../widgets/generation_progress.dart';
import '../widgets/input_field_builder.dart';

class TemplateDetailScreen extends ConsumerStatefulWidget {
  final String templateId;

  const TemplateDetailScreen({super.key, required this.templateId});

  @override
  ConsumerState<TemplateDetailScreen> createState() => _TemplateDetailScreenState();
}

class _TemplateDetailScreenState extends ConsumerState<TemplateDetailScreen> {
  final Map<String, String> _inputValues = {};
  final Set<String> _reportedErrors = <String>{};
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
    
    ref.read(generationViewModelProvider.notifier).generate(
          templateId: template.id,
          prompt: prompt,
          userId: userId,
          aspectRatio: options.aspectRatio,
          imageCount: options.imageCount,
        );
  }

  void _captureOnce(Object error, StackTrace? stackTrace) {
    final signature = '${error.runtimeType}:${error.toString()}';
    if (_reportedErrors.add(signature)) {
      SentryConfig.captureException(error, stackTrace: stackTrace);
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(AppExceptionMapper.toUserMessage(e))),
        data: (template) {
          if (template == null) {
            return const Center(child: Text('Template not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Template thumbnail
                if (template.thumbnailUrl.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      template.thumbnailUrl,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox(height: 200, child: Icon(Icons.broken_image, size: 50)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Template info
                Text(template.name, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(template.description),
                const SizedBox(height: 24),

                // Template input fields
                for (final field in template.inputFields) ...[
                  InputFieldBuilder(
                    field: field,
                    onChanged: (value) => _inputValues[field.name] = value,
                  ),
                  const SizedBox(height: 16),
                ],

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
                const SizedBox(height: 24),

                // Generation Options Section
                Text(
                  'Generation Options',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Aspect Ratio Selector
                AspectRatioSelector(
                  selectedRatio: options.aspectRatio,
                  selectedModelId: options.modelId,
                  onChanged: (ratio) => ref.read(generationOptionsProvider.notifier).updateAspectRatio(ratio),
                ),
                const SizedBox(height: 16),

                // Image Count Dropdown
                ImageCountDropdown(
                  value: options.imageCount,
                  onChanged: (count) => ref.read(generationOptionsProvider.notifier).updateImageCount(count),
                ),
                const SizedBox(height: 16),

                // Output Format Toggle
                OutputFormatToggle(
                  value: options.outputFormat,
                  isPremium: _isPremium,
                  onChanged: (format) => ref.read(generationOptionsProvider.notifier).updateOutputFormat(format),
                ),
                const SizedBox(height: 16),

                // Model Selector
                ModelSelector(
                  selectedModelId: options.modelId,
                  isPremium: _isPremium,
                  onChanged: (modelId) => ref.read(generationOptionsProvider.notifier).updateModel(modelId),
                  filterByType: 'text-to-image',
                ),
                const SizedBox(height: 24),

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
    return jobAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
       error: (error, _) => Column(
         children: [
           Text(
             AppExceptionMapper.toUserMessage(error),
             style: TextStyle(color: Theme.of(context).colorScheme.error),
           ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () {
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
            onPressed: () => _handleGenerate(template),
            child: const Text('Generate'),
          );
        }

        return Column(
          children: [
            GenerationProgress(job: job),
            const SizedBox(height: 16),
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
