import 'package:flutter/material.dart';
import '../../model/generation_job_model.dart';

class GenerationProgress extends StatelessWidget {
  final GenerationJobModel job;

  const GenerationProgress({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (job.status == JobStatus.pending ||
                job.status == JobStatus.generating ||
                job.status == JobStatus.processing) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                _getStatusText(job.status),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ] else if (job.status == JobStatus.completed) ...[
              const Icon(Icons.check_circle, color: Colors.green, size: 48),
              const SizedBox(height: 16),
              if (job.resultUrls != null && job.resultUrls!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    job.resultUrls!.first,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
            ] else if (job.status == JobStatus.failed) ...[
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
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
