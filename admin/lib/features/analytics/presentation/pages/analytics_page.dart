import 'package:artio_admin/core/theme/admin_colors.dart';
import 'package:artio_admin/features/analytics/domain/entities/analytics_stats.dart';
import 'package:artio_admin/features/analytics/presentation/widgets/jobs_line_chart.dart';
import 'package:artio_admin/features/analytics/presentation/widgets/kpi_cards_row.dart';
import 'package:artio_admin/features/analytics/presentation/widgets/top_models_bar_chart.dart';
import 'package:artio_admin/features/analytics/providers/analytics_stats_provider.dart';
import 'package:artio_admin/shared/widgets/error_state_widget.dart';
import 'package:artio_admin/shared/widgets/tier_pie_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(analyticsStatsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(analyticsStatsProvider),
          ),
        ],
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorStateWidget.fromError(
          error: err,
          message: 'Failed to load analytics',
          onRetry: () => ref.invalidate(analyticsStatsProvider),
        ),
        data: (stats) => _AnalyticsBody(stats: stats, isDark: isDark),
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _AnalyticsBody extends StatelessWidget {
  const _AnalyticsBody({required this.stats, required this.isDark});

  final AnalyticsStats stats;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(4),
          Text(
            'Key metrics across users and generation jobs',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AdminColors.textSecondary : Colors.grey.shade600,
            ),
          ),
          const Gap(24),
          KpiCardsRow(stats: stats, isDark: isDark),
          const Gap(32),
          Text(
            'Daily Jobs (last 7 days)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(12),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 24, 12),
              child: SizedBox(
                height: 200,
                child: DailyJobsLineChart(dailyJobs: stats.dailyJobs),
              ),
            ),
          ),
          const Gap(24),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              final tierSections = [
                TierPieSection(
                  label: 'Pro',
                  count: stats.premiumUsers,
                  color: AdminColors.statAmber,
                ),
                TierPieSection(
                  label: 'Free',
                  count: stats.freeUsers,
                  color: AdminColors.statBlue,
                ),
              ];
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _ChartCard(
                        title: 'Top Models (7 days)',
                        child: TopModelsBarChart(topModels: stats.topModels),
                      ),
                    ),
                    const Gap(24),
                    Expanded(
                      child: _ChartCard(
                        title: 'Tier Distribution',
                        child: TierPieChart(sections: tierSections),
                      ),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  _ChartCard(
                    title: 'Top Models (7 days)',
                    child: TopModelsBarChart(topModels: stats.topModels),
                  ),
                  const Gap(16),
                  _ChartCard(
                    title: 'Tier Distribution',
                    child: TierPieChart(sections: tierSections),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Chart Card wrapper ────────────────────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Gap(16),
            SizedBox(height: 200, child: child),
          ],
        ),
      ),
    );
  }
}
