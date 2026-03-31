import 'package:artio_admin/core/theme/admin_colors.dart';
import 'package:artio_admin/shared/widgets/error_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:artio_admin/features/users/presentation/pages/user_detail_page.dart'
    show userRecentJobsProvider;

class RecentJobsList extends ConsumerWidget {
  final String userId;

  const RecentJobsList({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final jobsAsync = ref.watch(userRecentJobsProvider(userId));

    return jobsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => ErrorStateWidget.fromError(
        error: e,
        message: 'Failed to load recent jobs',
        onRetry: () => ref.invalidate(userRecentJobsProvider(userId)),
      ),
      data: (jobs) => jobs.isEmpty
          ? Text(
              'No generations yet',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? AdminColors.textMuted : Colors.grey,
              ),
            )
          : Column(
              children: jobs.map((j) => _JobRow(job: j)).toList(),
            ),
    );
  }
}

class _JobRow extends StatelessWidget {
  const _JobRow({required this.job});

  final Map<String, dynamic> job;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final status = job['status'] as String? ?? 'unknown';
    final statusColor = switch (status) {
      'done' => AdminColors.success,
      'failed' => AdminColors.error,
      'generating' => AdminColors.info,
      _ => AdminColors.textMuted,
    };
    final createdAt = job['created_at'] as String?;
    final dateText = createdAt != null
        ? DateFormat.yMMMd().add_Hm().format(DateTime.parse(createdAt))
        : '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              job['model_id'] as String? ?? '—',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            dateText,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isDark ? AdminColors.textMuted : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
