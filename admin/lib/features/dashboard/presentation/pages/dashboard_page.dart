import 'package:artio_admin/core/theme/admin_colors.dart';
import 'package:artio_admin/features/dashboard/providers/dashboard_stats_provider.dart';
import 'package:artio_admin/shared/widgets/error_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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
              // ── Welcome ─────────────────────────────────
              Text(
                'Welcome back 👋',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(4),
              Text(
                'Here\'s an overview of your templates',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AdminColors.textSecondary
                      : Colors.grey.shade600,
                ),
              ),
              const Gap(24),

              // ── Stat Cards ──────────────────────────────
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
              ),
              const Gap(32),

              // ── Recent Templates ────────────────────────
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
                      for (
                        int i = 0;
                        i < stats.recentTemplates.length;
                        i++
                      ) ...[
                        _RecentTemplateRow(
                          data: stats.recentTemplates[i],
                          isDark: isDark,
                          onTap: () {
                            final id = stats.recentTemplates[i]['id'];
                            context.go('/templates/$id');
                          },
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

// ── Stat Card ───────────────────────────────────────────────────────────

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
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

// ── Recent Template Row ─────────────────────────────────────────────────

class _RecentTemplateRow extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isDark;
  final VoidCallback onTap;

  const _RecentTemplateRow({
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
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
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
