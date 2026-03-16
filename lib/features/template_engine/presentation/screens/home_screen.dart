import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/core/design_system/app_typography.dart';
import 'package:artio/core/state/subscription_state_provider.dart';
import 'package:artio/features/credits/presentation/providers/credit_balance_provider.dart';
import 'package:artio/features/template_engine/presentation/providers/template_provider.dart';
import 'package:artio/features/template_engine/presentation/widgets/home_screen_widgets.dart';
import 'package:artio/features/template_engine/presentation/widgets/template_grid.dart';
import 'package:artio/routing/routes/app_routes.dart';
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
                          // Credit balance chip
                          const _CreditChip(),
                          const SizedBox(width: AppSpacing.sm),
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

              // ── Low Credit Warning Banner ───────────────────────────
              const SliverToBoxAdapter(child: _LowCreditBanner()),

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

class _LowCreditBanner extends ConsumerWidget {
  const _LowCreditBanner();

  static const _threshold = 20;
  static const _warningColor = Color(0xFFFF6B35);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance =
        ref.watch(creditBalanceNotifierProvider).valueOrNull?.balance;
    final isSubscriber =
        ref.watch(subscriptionNotifierProvider).valueOrNull?.isActive ?? false;

    if (isSubscriber || balance == null || balance >= _threshold) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: _warningColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _warningColor.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          const Text('⚡', style: TextStyle(fontSize: 16)),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              'Only $balance credits left. Watch an ad or upgrade to keep creating.',
              style: const TextStyle(
                color: _warningColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => const PaywallRoute().push<void>(context),
            child: const Text(
              'Upgrade',
              style: TextStyle(
                color: _warningColor,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
                decorationColor: _warningColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreditChip extends ConsumerWidget {
  const _CreditChip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(creditBalanceNotifierProvider);
    return balanceAsync.whenOrNull(
          data: (creditBalance) => Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => const CreditHistoryRoute().push<void>(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white10,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.white20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('💎', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${creditBalance.balance}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ) ??
        const SizedBox.shrink();
  }
}
