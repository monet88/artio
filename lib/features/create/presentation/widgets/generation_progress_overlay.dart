import 'package:flutter/material.dart';
import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/features/template_engine/domain/entities/generation_job_model.dart';

class GenerationProgressOverlay extends StatelessWidget {
  const GenerationProgressOverlay({super.key, required this.job});

  final GenerationJobModel job;

  String _statusLabel(JobStatus status) {
    return switch (status) {
      JobStatus.pending => 'Queued',
      JobStatus.generating => 'Generating',
      JobStatus.processing => 'Processing',
      JobStatus.completed => 'Completed',
      JobStatus.failed => 'Failed',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned.fill(
      child: Container(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        child: Center(
          child: Card(
            child: Padding(
              padding: AppSpacing.cardPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Show spinner for active states, error icon for failed
                  if (job.status == JobStatus.failed)
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: theme.colorScheme.error,
                    )
                  else
                    const CircularProgressIndicator(),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    _statusLabel(job.status),
                    style: theme.textTheme.titleMedium,
                  ),
                  if (job.status == JobStatus.failed &&
                      job.errorMessage != null) ...[
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      job.errorMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
