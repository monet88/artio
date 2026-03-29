import 'package:artio_admin/core/theme/admin_colors.dart';
import 'package:artio_admin/features/jobs/domain/entities/admin_job_model.dart';
import 'package:artio_admin/shared/widgets/error_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'jobs_page.g.dart';

// ── Provider ─────────────────────────────────────────────────────────────────

@riverpod
class Jobs extends _$Jobs {
  @override
  Stream<List<AdminJobModel>> build() {
    return Supabase.instance.client
        .from('generation_jobs')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .limit(500)
        .map(
          (rows) => rows.map((r) => AdminJobModel.fromJson(r)).toList(),
        );
  }
}

// ── Page ─────────────────────────────────────────────────────────────────────

class JobsPage extends ConsumerStatefulWidget {
  const JobsPage({super.key});

  @override
  ConsumerState<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends ConsumerState<JobsPage> {
  _StatusFilter _filter = _StatusFilter.all;
  String _searchQuery = '';

  List<AdminJobModel> _applyFilters(List<AdminJobModel> jobs) {
    var result = jobs;

    result = switch (_filter) {
      _StatusFilter.all => result,
      _StatusFilter.pending => result.where((j) => j.isPending).toList(),
      _StatusFilter.generating => result.where((j) => j.isGenerating).toList(),
      _StatusFilter.done => result.where((j) => j.isDone).toList(),
      _StatusFilter.failed => result.where((j) => j.isFailed).toList(),
    };

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where(
            (j) =>
                j.userId.toLowerCase().contains(q) ||
                j.modelId.toLowerCase().contains(q),
          )
          .toList();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(jobsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Jobs')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by user ID or model...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () =>
                                setState(() => _searchQuery = ''),
                          )
                        : null,
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _StatusFilter.values.map((f) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(f.label),
                          selected: _filter == f,
                          onSelected: (_) => setState(() => _filter = f),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: jobsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, _) => ErrorStateWidget.fromError(
                error: err,
                message: err.toString(),
                onRetry: () => ref.invalidate(jobsProvider),
              ),
              data: (jobs) {
                final filtered = _applyFilters(jobs);

                if (jobs.isEmpty) {
                  return Center(
                    child: Text(
                      'No jobs yet',
                      style: theme.textTheme.titleMedium,
                    ),
                  );
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'No jobs match your filters',
                      style: theme.textTheme.bodyLarge,
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final job = filtered[index];
                    return _JobListTile(
                      job: job,
                      onTap: () => context.go('/jobs/${job.id}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter ────────────────────────────────────────────────────────────────────

enum _StatusFilter {
  all('All'),
  pending('Pending'),
  generating('Generating'),
  done('Done'),
  failed('Failed');

  const _StatusFilter(this.label);
  final String label;
}

// ── List Tile ─────────────────────────────────────────────────────────────────

class _JobListTile extends StatelessWidget {
  const _JobListTile({required this.job, required this.onTap});

  final AdminJobModel job;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statusColor = _statusColor(job.status);

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      leading: Container(
        width: 10,
        height: 10,
        margin: const EdgeInsets.only(top: 4),
        decoration: BoxDecoration(
          color: statusColor,
          shape: BoxShape.circle,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              job.modelId,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _StatusChip(status: job.status, color: statusColor),
        ],
      ),
      subtitle: Text(
        job.prompt ?? job.userId,
        style: theme.textTheme.bodySmall?.copyWith(
          color: isDark ? AdminColors.textMuted : Colors.grey,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      trailing: job.createdAt != null
          ? Text(
              DateFormat.MMMd().add_Hm().format(job.createdAt!),
              style: theme.textTheme.labelSmall?.copyWith(
                color: isDark ? AdminColors.textMuted : Colors.grey,
              ),
            )
          : null,
    );
  }

  static Color _statusColor(String status) => switch (status) {
    'done' => AdminColors.success,
    'failed' => AdminColors.error,
    'generating' => AdminColors.info,
    _ => AdminColors.textMuted,
  };
}

// ── Status Chip ───────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.color});

  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
