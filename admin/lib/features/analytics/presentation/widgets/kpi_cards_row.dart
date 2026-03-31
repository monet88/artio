import 'package:artio_admin/core/theme/admin_colors.dart';
import 'package:artio_admin/features/analytics/domain/entities/analytics_stats.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class KpiCardsRow extends StatelessWidget {
  final AnalyticsStats stats;
  final bool isDark;

  const KpiCardsRow({super.key, required this.stats, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
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
    );
  }
}

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
