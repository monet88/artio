import 'package:artio_admin/core/theme/admin_colors.dart';
import 'package:artio_admin/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

/// 4-card KPI grid for the dashboard.
class StatsGrid extends StatelessWidget {
  final DashboardStats stats;
  final bool isDark;

  const StatsGrid({super.key, required this.stats, required this.isDark});

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
            _StatCard(
              label: 'Total Templates',
              value: '${stats.totalTemplates}',
              icon: Icons.style_rounded,
              tint: AdminColors.statBlue,
              isDark: isDark,
            ),
            _StatCard(
              label: 'Active',
              value: '${stats.activeTemplates}',
              icon: Icons.check_circle_rounded,
              tint: AdminColors.statGreen,
              isDark: isDark,
            ),
            _StatCard(
              label: 'Premium',
              value: '${stats.premiumTemplates}',
              icon: Icons.workspace_premium_rounded,
              tint: AdminColors.statAmber,
              isDark: isDark,
            ),
            _StatCard(
              label: 'Categories',
              value: '${stats.categoriesCount}',
              icon: Icons.category_rounded,
              tint: AdminColors.statPurple,
              isDark: isDark,
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color tint;
  final bool isDark;

  const _StatCard({
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

/// A single row in the "Recently Updated" card on the dashboard.
class RecentTemplateRow extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isDark;
  final VoidCallback onTap;

  const RecentTemplateRow({
    super.key,
    required this.data,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = data['name'] ?? 'Untitled';
    final category = data['category'] ?? '';
    final isActive = data['is_active'] == true;
    final isPremium = data['is_premium'] == true;
    final updatedAt = data['updated_at'] != null
        ? DateFormat.yMMMd().format(DateTime.parse(data['updated_at']))
        : '';

    return ListTile(
      onTap: onTap,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 40,
          height: 40,
          child: data['thumbnail_url'] != null
              ? Image.network(
                  data['thumbnail_url'],
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: isDark
                        ? AdminColors.surfaceElevated
                        : Colors.grey.shade200,
                    child: const Icon(Icons.image, size: 18),
                  ),
                )
              : Container(
                  color: isDark
                      ? AdminColors.surfaceElevated
                      : Colors.grey.shade200,
                  child: const Icon(Icons.image, size: 18),
                ),
        ),
      ),
      title: Text(
        name,
        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '$category · $updatedAt',
        style: theme.textTheme.bodySmall?.copyWith(
          color: isDark ? AdminColors.textMuted : Colors.grey,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPremium)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AdminColors.statAmber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'PRO',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AdminColors.statAmber,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const Gap(8),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? AdminColors.success : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
