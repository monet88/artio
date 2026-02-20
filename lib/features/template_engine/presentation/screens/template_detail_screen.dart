import 'dart:async';

import 'package:artio/core/config/sentry_config.dart';
import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/core/state/auth_view_model_provider.dart';
import 'package:artio/core/utils/app_exception_mapper.dart';
import 'package:artio/features/auth/presentation/state/auth_state.dart';
import 'package:artio/features/template_engine/domain/entities/generation_job_model.dart';
import 'package:artio/features/template_engine/domain/entities/input_field_model.dart';
import 'package:artio/features/template_engine/domain/entities/template_model.dart';
import 'package:artio/features/template_engine/presentation/providers/generation_options_provider.dart';
import 'package:artio/features/template_engine/presentation/providers/template_provider.dart';
import 'package:artio/features/template_engine/presentation/view_models/generation_view_model.dart';
import 'package:artio/features/template_engine/presentation/widgets/input_field_builder.dart';
import 'package:artio/features/template_engine/presentation/widgets/template_detail_widgets.dart';
import 'package:artio/shared/widgets/aspect_ratio_selector.dart';
import 'package:artio/shared/widgets/image_count_dropdown.dart';
import 'package:artio/shared/widgets/loading_state_widget.dart';
import 'package:artio/shared/widgets/model_selector.dart';
import 'package:artio/shared/widgets/output_format_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class TemplateDetailScreen extends ConsumerStatefulWidget {
  const TemplateDetailScreen({required this.templateId, super.key});
  final String templateId;

  @override
  ConsumerState<TemplateDetailScreen> createState() =>
      _TemplateDetailScreenState();
}

class _TemplateDetailScreenState extends ConsumerState<TemplateDetailScreen> {
  final Map<String, String> _inputValues = {};
  final Set<String> _reportedErrors = <String>{};
  final _formKey = GlobalKey<FormState>();
  ProviderSubscription<AsyncValue<TemplateModel?>>? _templateErrorSub;
  ProviderSubscription<AsyncValue<GenerationJobModel?>>? _jobErrorSub;
  ProviderSubscription? _premiumSub;

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
    final userId = ref
        .read(authViewModelProvider)
        .maybeMap(authenticated: (s) => s.user.id, orElse: () => null);

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

    ref
        .read(generationViewModelProvider.notifier)
        .generate(
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

    // Tag Sentry events with premium status (fires only on change)
    _premiumSub = ref.listenManual<AuthState>(
      authViewModelProvider,
      (_, AuthState next) {
        final isPremium = next.maybeMap(
          authenticated: (s) => s.user.isPremium,
          orElse: () => false,
        );
        Sentry.configureScope(
          (scope) => scope.setTag('isPremium', isPremium.toString()),
        );
      },
    );
  }

  @override
  void dispose() {
    _templateErrorSub?.close();
    _jobErrorSub?.close();
    _premiumSub?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final templateAsync = ref.watch(templateByIdProvider(widget.templateId));
    final jobAsync = ref.watch(generationViewModelProvider);
    final options = ref.watch(generationOptionsProvider);
    final isPremium = ref
        .watch(authViewModelProvider)
        .maybeMap(
          authenticated: (state) => state.user.isPremium,
          orElse: () => false,
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Generate')),
      body: templateAsync.when(
        loading: () => const LoadingStateWidget(),
        error: (e, _) =>
            Center(child: Text(AppExceptionMapper.toUserMessage(e))),
        data: (template) {
          if (template == null) {
            return const Center(child: Text('Template not found'));
          }

          return SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TemplateDetailHeader(template: template),
                // Template input fields
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      for (final field in template.inputFields) ...[
                        InputFieldBuilder(
                          field: field,
                          onChanged: (value) =>
                              _inputValues[field.name] = value,
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    ],
                  ),
                ),
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
                Text(
                  'Generation Options',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AspectRatioSelector(
                  selectedRatio: options.aspectRatio,
                  selectedModelId: options.modelId,
                  onChanged: (ratio) => ref
                      .read(generationOptionsProvider.notifier)
                      .updateAspectRatio(ratio),
                ),
                const SizedBox(height: AppSpacing.md),
                ImageCountDropdown(
                  value: options.imageCount,
                  onChanged: (count) => ref
                      .read(generationOptionsProvider.notifier)
                      .updateImageCount(count),
                ),
                const SizedBox(height: AppSpacing.md),
                OutputFormatToggle(
                  value: options.outputFormat,
                  isPremium: isPremium,
                  onChanged: (format) => ref
                      .read(generationOptionsProvider.notifier)
                      .updateOutputFormat(format),
                ),
                const SizedBox(height: AppSpacing.md),
                ModelSelector(
                  selectedModelId: options.modelId,
                  isPremium: isPremium,
                  onChanged: (modelId) => ref
                      .read(generationOptionsProvider.notifier)
                      .updateModel(modelId),
                  filterByType: 'text-to-image',
                ),
                const SizedBox(height: AppSpacing.lg),
                GenerationStateSection(
                  jobAsync: jobAsync,
                  isGenerating: ref
                      .read(generationViewModelProvider.notifier)
                      .isGenerating,
                  onGenerate: () => _handleGenerate(template),
                  onReset: () =>
                      ref.read(generationViewModelProvider.notifier).reset(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
