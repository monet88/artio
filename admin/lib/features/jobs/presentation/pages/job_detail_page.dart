import 'package:artio_admin/core/theme/admin_colors.dart';
import 'package:artio_admin/features/jobs/domain/entities/admin_job_model.dart';
import 'package:artio_admin/shared/widgets/error_state_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'job_detail_page.g.dart';

// ── Provider ─────────────────────────────────────────────────────────────────

@riverpod
Future<AdminJobModel> jobDetail(Ref ref, String jobId) async {
  final data = await Supabase.instance.client
      .from('generation_jobs')
      .select()
      .eq('id', jobId)
      .single();
  return AdminJobModel.fromJson(data);
}

// ── Page ─────────────────────────────────────────────────────────────────────

class JobDetailPage extends ConsumerWidget {
  const JobDetailPage({required this.jobId, super.key});

  final String jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobAsync = ref.watch(jobDetailProvider(jobId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/jobs'),
        ),
        title: const Text('Job Detail'),
      ),
      body: jobAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorStateWidget.fromError(
          error: err,
          message: err.toString(),
          onRetry: () => ref.invalidate(jobDetailProvider(jobId)),
        ),
        data: (job) => _JobDetailBody(job: job),
      ),
    );
  }
}

// ── Body ─────────────────────────────────────────────────────────────────────

class _JobDetailBody extends StatelessWidget {
  const _JobDetailBody({required this.job});

  final AdminJobModel job;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statusColor = _statusColor(job.status);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Status Banner ──────────────────────────────────────
              _SectionCard(
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      job.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      icon: const Icon(Icons.person_outline, size: 16),
                      label: const Text('View User'),
                      style: ButtonStyle(
                        foregroundColor: WidgetStateProperty.all(
                          AdminColors.accent,
                        ),
                      ),
                      onPressed: () => context.go('/users/${job.userId}'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Details ───────────────────────────────────────────
              _SectionCard(
                child: Column(
                  children: [
                    _DetailRow(label: 'Job ID', value: job.id),
                    _DetailRow(label: 'User ID', value: job.userId),
                    _DetailRow(label: 'Model', value: job.modelId),
                    if (job.createdAt != null)
                      _DetailRow(
                        label: 'Created',
                        value: DateFormat.yMMMd()
                            .add_Hms()
                            .format(job.createdAt!),
                      ),
                    if (job.updatedAt != null)
                      _DetailRow(
                        label: 'Updated',
                        value: DateFormat.yMMMd()
                            .add_Hms()
                            .format(job.updatedAt!),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Prompt ────────────────────────────────────────────
              if (job.prompt != null) ...[
                Text(
                  'Prompt',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _SectionCard(
                  child: SelectableText(
                    job.prompt!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Error Message ─────────────────────────────────────
              if (job.isFailed && job.errorMessage != null) ...[
                Text(
                  'Error',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AdminColors.error,
                  ),
                ),
                const SizedBox(height: 8),
                _SectionCard(
                  child: SelectableText(
                    job.errorMessage!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AdminColors.error,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Image Preview ─────────────────────────────────────
              if (job.isDone && job.imageUrl != null) ...[
                Text(
                  'Output',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: job.imageUrl!,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => Container(
                      height: 200,
                      color: isDark
                          ? AdminColors.surfaceContainer
                          : Colors.grey.shade100,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 100,
                      color: isDark
                          ? AdminColors.surfaceContainer
                          : Colors.grey.shade100,
                      child: const Center(
                        child: Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static Color _statusColor(String status) => switch (status) {
    'done' => AdminColors.success,
    'failed' => AdminColors.error,
    'generating' => AdminColors.info,
    _ => AdminColors.textMuted,
  };
}

// ── Shared Widgets ────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AdminColors.surfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AdminColors.borderSubtle : Colors.grey.shade200,
        ),
      ),
      child: child,
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? AdminColors.textMuted : Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
