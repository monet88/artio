import 'package:flutter/material.dart';
import '../../../../core/design_system/app_spacing.dart';
import '../../../../core/design_system/app_dimensions.dart';
import '../../../../shared/widgets/loading_state_widget.dart';
import '../../domain/entities/generation_job_model.dart';

class GenerationProgress extends StatelessWidget {
  final GenerationJobModel job;

  const GenerationProgress({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (job.status == JobStatus.pending ||
                job.status == JobStatus.generating ||
                job.status == JobStatus.processing) ...[
              const LinearProgressIndicator(),
              SizedBox(height: AppSpacing.md),
              Text(
                _getStatusText(job.status),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ] else if (job.status == JobStatus.completed) ...[
              Icon(Icons.check_circle, color: Colors.green, size: AppDimensions.iconXl),
              SizedBox(height: AppSpacing.md),
              if (job.resultUrls != null && job.resultUrls!.isNotEmpty)
                ClipRRect(
                  borderRadius: AppDimensions.buttonRadius,
                  child: Image.network(
                    job.resultUrls!.first,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const LoadingStateWidget();
                    },
                  ),
                ),
            ] else if (job.status == JobStatus.failed) ...[
              Icon(Icons.error, color: Colors.red, size: AppDimensions.iconXl),
              SizedBox(height: AppSpacing.md),
              Text(
                job.errorMessage ?? 'Generation failed',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getStatusText(JobStatus status) {
    switch (status) {
      case JobStatus.pending:
        return 'Queued...';
      case JobStatus.generating:
        return 'Generating...';
      case JobStatus.processing:
        return 'Processing...';
      case JobStatus.completed:
        return 'Completed';
      case JobStatus.failed:
        return 'Failed';
    }
  }
}
