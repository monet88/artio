import 'package:artio_admin/core/theme/admin_colors.dart';
import 'package:artio_admin/features/dashboard/presentation/widgets/stats_grid.dart';
import 'package:artio_admin/features/dashboard/providers/dashboard_stats_provider.dart';
import 'package:artio_admin/shared/widgets/error_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorStateWidget.fromError(
          error: err,
          message: 'Failed to load dashboard stats',
          onRetry: () => ref.invalidate(dashboardStatsProvider),
        ),
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back 👋',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(4),
              Text(
                "Here's an overview of your templates",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AdminColors.textSecondary
                      : Colors.grey.shade600,
                ),
              ),
              const Gap(24),
              StatsGrid(stats: stats, isDark: isDark),
              const Gap(32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recently Updated',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => context.go('/templates'),
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('View All'),
                  ),
                ],
              ),
              const Gap(12),
              if (stats.recentTemplates.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'No templates yet',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? AdminColors.textMuted : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                )
              else
                Card(
                  child: Column(
                    children: [
                      for (int i = 0; i < stats.recentTemplates.length; i++) ...[
                        RecentTemplateRow(
                          data: stats.recentTemplates[i],
                          isDark: isDark,
                          onTap: () =>
                              context.go('/templates/${stats.recentTemplates[i]['id']}'),
                        ),
                        if (i < stats.recentTemplates.length - 1)
                          Divider(
                            height: 1,
                            color: isDark
                                ? AdminColors.borderSubtle
                                : Colors.grey.shade200,
                          ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
