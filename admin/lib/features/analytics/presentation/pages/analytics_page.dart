import 'package:artio_admin/core/theme/admin_colors.dart';
import 'package:artio_admin/features/analytics/domain/entities/analytics_stats.dart';
import 'package:artio_admin/features/analytics/providers/analytics_stats_provider.dart';
import 'package:artio_admin/shared/widgets/error_state_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

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
          // ── Header ──────────────────────────────────────
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
              color: isDark
                  ? AdminColors.textSecondary
                  : Colors.grey.shade600,
            ),
          ),
          const Gap(24),

          // ── KPI Cards ────────────────────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 900 ? 4 : 2;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2.2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _KpiCard(
                    label: 'Total Users',
                    value: NumberFormat.compact().format(stats.totalUsers),
                    icon: Icons.people_rounded,
                    tint: AdminColors.statBlue,
                    isDark: isDark,
                  ),
                  _KpiCard(
                    label: 'Total Jobs',
                    value: NumberFormat.compact().format(stats.totalJobs),
                    icon: Icons.work_history_rounded,
                    tint: AdminColors.statGreen,
                    isDark: isDark,
                  ),
                  _KpiCard(
                    label: 'Premium Users',
                    value: NumberFormat.compact().format(stats.premiumUsers),
                    icon: Icons.workspace_premium_rounded,
                    tint: AdminColors.statAmber,
                    isDark: isDark,
                  ),
                  _KpiCard(
                    label: 'Jobs Today',
                    value: NumberFormat.compact().format(stats.jobsToday),
                    icon: Icons.today_rounded,
                    tint: AdminColors.statPurple,
                    isDark: isDark,
                  ),
                ],
              );
            },
          ),
          const Gap(32),

          // ── Daily Jobs Chart ──────────────────────────────
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
                child: _DailyJobsChart(dailyJobs: stats.dailyJobs),
              ),
            ),
          ),
          const Gap(24),

          // ── Bottom row: Models + Tier ─────────────────────
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _ChartCard(
                        title: 'Top Models (7 days)',
                        child: _TopModelsChart(topModels: stats.topModels),
                      ),
                    ),
                    const Gap(24),
                    Expanded(
                      child: _ChartCard(
                        title: 'Tier Distribution',
                        child: _TierPieChart(stats: stats),
                      ),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  _ChartCard(
                    title: 'Top Models (7 days)',
                    child: _TopModelsChart(topModels: stats.topModels),
                  ),
                  const Gap(16),
                  _ChartCard(
                    title: 'Tier Distribution',
                    child: _TierPieChart(stats: stats),
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

// ── KPI Card ──────────────────────────────────────────────────────────────────

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.tint,
    required this.isDark,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color tint;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: tint, size: 24),
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style:
                        theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AdminColors.textSecondary
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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

// ── Daily Jobs LineChart ──────────────────────────────────────────────────────

class _DailyJobsChart extends StatelessWidget {
  const _DailyJobsChart({required this.dailyJobs});

  final List<DailyCount> dailyJobs;

  @override
  Widget build(BuildContext context) {
    if (dailyJobs.isEmpty) {
      return const Center(child: Text('No data'));
    }

    return LineChart(
      LineChartData(
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= dailyJobs.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    DateFormat.Md().format(dailyJobs[idx].date),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < dailyJobs.length; i++)
                FlSpot(i.toDouble(), dailyJobs[i].count.toDouble()),
            ],
            isCurved: true,
            color: AdminColors.primary,
            belowBarData: BarAreaData(
              show: true,
              color: AdminColors.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Top Models BarChart ───────────────────────────────────────────────────────

class _TopModelsChart extends StatelessWidget {
  const _TopModelsChart({required this.topModels});

  final List<ModelCount> topModels;

  @override
  Widget build(BuildContext context) {
    if (topModels.isEmpty) {
      return const Center(child: Text('No data'));
    }

    return BarChart(
      BarChartData(
        gridData: const FlGridData(),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= topModels.length) {
                  return const SizedBox.shrink();
                }
                // Show last segment of model name (after last '/')
                final name = topModels[idx].model.split('/').last;
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    name,
                    style: const TextStyle(fontSize: 9),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < topModels.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: topModels[i].count.toDouble(),
                  color: AdminColors.accent,
                  width: 24,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ── Tier PieChart ─────────────────────────────────────────────────────────────

class _TierPieChart extends StatelessWidget {
  const _TierPieChart({required this.stats});

  final AnalyticsStats stats;

  @override
  Widget build(BuildContext context) {
    if (stats.totalUsers == 0) {
      return const Center(child: Text('No data'));
    }

    return PieChart(
      PieChartData(
        sectionsSpace: 3,
        centerSpaceRadius: 48,
        sections: [
          PieChartSectionData(
            value: stats.premiumUsers.toDouble(),
            title: 'Pro\n${stats.premiumUsers}',
            color: AdminColors.statAmber,
            radius: 56,
            titleStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            value: stats.freeUsers.toDouble(),
            title: 'Free\n${stats.freeUsers}',
            color: AdminColors.statBlue,
            radius: 56,
            titleStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
