import 'package:artio_admin/core/theme/admin_colors.dart';
import 'package:artio_admin/features/revenue/domain/entities/revenue_stats.dart';
import 'package:artio_admin/features/revenue/presentation/widgets/daily_revenue_chart.dart';
import 'package:artio_admin/features/revenue/presentation/widgets/recent_transactions_list.dart';
import 'package:artio_admin/features/revenue/providers/revenue_stats_provider.dart';
import 'package:artio_admin/shared/widgets/error_state_widget.dart';
import 'package:artio_admin/shared/widgets/tier_pie_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class RevenuePage extends ConsumerWidget {
  const RevenuePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(revenueStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Revenue'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(revenueStatsProvider),
          ),
        ],
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorStateWidget.fromError(
          error: err,
          message: 'Failed to load revenue data',
          onRetry: () => ref.invalidate(revenueStatsProvider),
        ),
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── KPI Row ────────────────────────────────────────────────
              _RevenueKpiRow(stats: stats),
              const Gap(32),

              // ── Recent Transactions ────────────────────────────────────
              Text(
                'Recent Transactions (last 50)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Gap(12),
              RecentTransactionsList(
                transactions: stats.recentTransactions,
              ),
              const Gap(32),

              // ── Daily Chart ────────────────────────────────────────────
              Text(
                'Daily Transactions (last 7 days)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Gap(12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 24, 12),
                  child: SizedBox(
                    height: 200,
                    child: DailyRevenueChart(dailyRevenue: stats.dailyRevenue),
                  ),
                ),
              ),
              const Gap(32),

              // ── Tier Distribution ──────────────────────────────────────
              Text(
                'Tier Distribution',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Gap(12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 220,
                    child: TierPieChart(
                      sections: stats.tierBreakdown.map((t) {
                        final color = switch (t.tier) {
                          'free' => AdminColors.statBlue,
                          'basic' => AdminColors.statGreen,
                          _ => AdminColors.statAmber, // premium, pro, etc.
                        };
                        return TierPieSection(
                          label: t.tier[0].toUpperCase() + t.tier.substring(1),
                          count: t.count,
                          color: color,
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── KPI Row ────────────────────────────────────────────────────────────────────

class _RevenueKpiRow extends StatelessWidget {
  final RevenueStats stats;

  const _RevenueKpiRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 1;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: crossAxisCount == 3 ? 2.5 : 4.0,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _KpiCard(
              label: 'Subscriptions Today',
              value: '${stats.subscriptionsToday}',
              icon: Icons.today_rounded,
              tint: AdminColors.statAmber,
              isDark: isDark,
            ),
            _KpiCard(
              label: 'This Week',
              value: '${stats.subscriptionsThisWeek}',
              icon: Icons.date_range_rounded,
              tint: AdminColors.statGreen,
              isDark: isDark,
            ),
            _KpiCard(
              label: 'Total Premium Users',
              value: NumberFormat.compact().format(stats.totalPremiumUsers),
              icon: Icons.workspace_premium_rounded,
              tint: AdminColors.primary,
              isDark: isDark,
            ),
          ],
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color tint;
  final bool isDark;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.tint,
    required this.isDark,
  });

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
                    style: theme.textTheme.headlineMedium?.copyWith(
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
