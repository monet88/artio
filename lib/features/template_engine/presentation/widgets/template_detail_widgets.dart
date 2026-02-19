import 'package:artio/core/design_system/app_dimensions.dart';
import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/core/utils/app_exception_mapper.dart';
import 'package:artio/features/template_engine/domain/entities/generation_job_model.dart';
import 'package:artio/features/template_engine/domain/entities/template_model.dart';
import 'package:artio/features/template_engine/presentation/widgets/generation_progress.dart';
import 'package:artio/shared/widgets/loading_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Template thumbnail + name + description header.
class TemplateDetailHeader extends StatelessWidget {
  const TemplateDetailHeader({required this.template, super.key});

  final TemplateModel template;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (template.thumbnailUrl.isNotEmpty) ...[
          ClipRRect(
            borderRadius: AppDimensions.buttonRadius,
            child: Image.network(
              template.thumbnailUrl,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const SizedBox(
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
          const SizedBox(height: AppSpacing.md),
        ],
        Text(template.name, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.sm),
        Text(template.description),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

/// Generate / progress / error / completed state for a template job.
class GenerationStateSection extends StatelessWidget {
  const GenerationStateSection({
    required this.jobAsync,
    required this.isGenerating,
    required this.onGenerate,
    required this.onReset,
    super.key,
  });

  final AsyncValue<GenerationJobModel?> jobAsync;
  final bool isGenerating;
  final VoidCallback onGenerate;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
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
                    onReset();
                    onGenerate();
                  },
            child: const Text('Retry'),
          ),
        ],
      ),
      data: (job) {
        if (job == null) {
          return FilledButton(
            onPressed: isGenerating ? null : onGenerate,
            child: const Text('Generate'),
          );
        }

        return Column(
          children: [
            GenerationProgress(job: job),
            const SizedBox(height: AppSpacing.md),
            if (job.status == JobStatus.completed)
              FilledButton(
                onPressed: onReset,
                child: const Text('Generate Another'),
              ),
          ],
        );
      },
    );
  }
}
