import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/core/design_system/app_typography.dart';
import 'package:artio/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/template_provider.dart';
import '../widgets/template_grid.dart';

/// Redesigned Home Screen with greeting header, search bar (UI),
/// category filter chips, and pull-to-refresh.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryCta,
          onRefresh: () async {
            ref.invalidate(templatesProvider);
            // Small delay for visual feedback
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: CustomScrollView(
            slivers: [
              // ── Header Section ──────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getGreeting(),
                                  style: AppTypography.bodySecondary(context),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Discover Templates ✨',
                                  style: AppTypography.displayMedium.copyWith(
                                    color: isDark
                                        ? AppColors.textPrimary
                                        : AppColors.textPrimaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Template count badge
                          _TemplateCountBadge(),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Search bar (UI only)
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurface2
                              : AppColors.lightSurface2,
                          borderRadius: BorderRadius.circular(14),
                          border: isDark
                              ? Border.all(
                                  color: AppColors.white10,
                                  width: 0.5,
                                )
                              : null,
                        ),
                        child: TextField(
                          enabled: false, // UI only for now
                          decoration: InputDecoration(
                            hintText: 'Search templates...',
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: isDark
                                  ? AppColors.textMuted
                                  : AppColors.textMutedLight,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Category chips
                      const _CategoryChips(),

                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ),
                ),
              ),

              // ── Featured section header ─────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 18,
                        color: AppColors.primaryCta,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Featured',
                        style: AppTypography.displaySmall.copyWith(
                          color: isDark
                              ? AppColors.textPrimary
                              : AppColors.textPrimaryLight,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Template Grid ───────────────────────────────────────
              const TemplateGrid(),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning, Artist 🌅';
    if (hour < 17) return 'Good afternoon, Artist 🎨';
    return 'Good evening, Artist 🌙';
  }
}

// ── Template Count Badge ─────────────────────────────────────────────────

class _TemplateCountBadge extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(templatesProvider);

    return templatesAsync.when(
      data: (templates) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryCta.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.dashboard_rounded,
              size: 14,
              color: AppColors.primaryCta,
            ),
            const SizedBox(width: 4),
            Text(
              '${templates.length}',
              style: AppTypography.captionEmphasis.copyWith(
                color: AppColors.primaryCta,
              ),
            ),
          ],
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

// ── Category Filter Chips ────────────────────────────────────────────────

class _CategoryChips extends StatefulWidget {
  const _CategoryChips();

  @override
  State<_CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<_CategoryChips> {
  int _selectedIndex = 0;

  static const _categories = [
    'All',
    'Portrait',
    'Landscape',
    'Abstract',
    'Anime',
    'Realistic',
    'Fantasy',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryCta
                    : isDark
                        ? AppColors.darkSurface2
                        : AppColors.lightSurface2,
                borderRadius: BorderRadius.circular(20),
                border: isSelected
                    ? null
                    : isDark
                        ? Border.all(color: AppColors.white10, width: 0.5)
                        : null,
              ),
              child: Text(
                _categories[index],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : isDark
                          ? AppColors.textSecondary
                          : AppColors.textSecondaryLight,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
