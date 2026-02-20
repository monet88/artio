import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/core/design_system/app_typography.dart';
import 'package:artio/features/template_engine/presentation/providers/template_provider.dart';
import 'package:artio/features/template_engine/presentation/widgets/home_screen_widgets.dart';
import 'package:artio/features/template_engine/presentation/widgets/template_grid.dart';
import 'package:artio/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Home Screen with greeting header, category filter chips, and pull-to-refresh.
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
            await Future<void>.delayed(const Duration(milliseconds: 500));
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
                                  'Discover Templates',
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
                          const TemplateCountBadge(),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Category chips
                      const CategoryChips(),

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
                      const Icon(
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
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}
