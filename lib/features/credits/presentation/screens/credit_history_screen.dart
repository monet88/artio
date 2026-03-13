import 'package:artio/core/state/credit_balance_state_provider.dart';
import 'package:artio/core/utils/app_exception_mapper.dart';
import 'package:artio/features/credits/domain/entities/credit_transaction.dart';
import 'package:artio/features/credits/presentation/providers/credit_history_provider.dart';
import 'package:artio/shared/widgets/error_state_widget.dart';
import 'package:artio/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Credit transaction history screen.
///
/// Shows earned and spent credits with type icons, amounts, and dates.
class CreditHistoryScreen extends ConsumerWidget {
  const CreditHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(creditHistoryProvider());
    final creditBalance = ref.watch(creditBalanceNotifierProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Credit History')),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorStateWidget.fromError(
          error: error,
          message: AppExceptionMapper.toUserMessage(error),
          onRetry: () => ref.invalidate(creditHistoryProvider),
        ),
        data: (transactions) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _BalanceHeader(balance: creditBalance?.balance),
              ),
              if (transactions.isEmpty)
                const SliverFillRemaining(child: _EmptyHistoryState())
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  sliver: SliverList.separated(
                    itemCount: transactions.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 56),
                    itemBuilder: (context, index) =>
                        _TransactionTile(transaction: transactions[index]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ── Balance header ────────────────────────────────────────────────────────────

class _BalanceHeader extends StatelessWidget {
  const _BalanceHeader({required this.balance});

  final int? balance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              Icons.toll_rounded,
              color: theme.colorScheme.onPrimaryContainer,
              size: 28,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Balance',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
                Text(
                  balance != null ? '$balance credits' : '—',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyHistoryState extends StatelessWidget {
  const _EmptyHistoryState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: AppColors.textMuted,
          ),
          SizedBox(height: 16),
          Text(
            'No Transactions Yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'Your credit history will appear here.',
            style: TextStyle(color: AppColors.white60),
          ),
        ],
      ),
    );
  }
}

// ── Transaction tile ─────────────────────────────────────────────────────────

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction});

  final CreditTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final isEarned = transaction.amount > 0;
    final config = _TransactionConfig.from(transaction.type);
    final dateStr = DateFormat(
      'MMM d, h:mm a',
    ).format(transaction.createdAt.toLocal());

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: config.color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(config.icon, size: 20, color: config.color),
      ),
      title: Text(
        config.label,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
      subtitle: Text(
        dateStr,
        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
      ),
      trailing: Text(
        isEarned ? '+${transaction.amount}' : '${transaction.amount}',
        style: TextStyle(
          color: isEarned ? AppColors.success : AppColors.error,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
    );
  }
}

// ── Config ────────────────────────────────────────────────────────────────────

class _TransactionConfig {
  const _TransactionConfig({
    required this.icon,
    required this.color,
    required this.label,
  });

  factory _TransactionConfig.from(String type) {
    return switch (type) {
      'welcome_bonus' => const _TransactionConfig(
        icon: Icons.celebration_rounded,
        color: AppColors.primaryCta,
        label: 'Welcome Bonus',
      ),
      'ad_reward' => const _TransactionConfig(
        icon: Icons.play_circle_outline_rounded,
        color: AppColors.info,
        label: 'Watched Ad',
      ),
      'subscription' => const _TransactionConfig(
        icon: Icons.diamond_rounded,
        color: AppColors.premium,
        label: 'Subscription Credits',
      ),
      'generation' => const _TransactionConfig(
        icon: Icons.auto_awesome_rounded,
        color: AppColors.accent,
        label: 'Image Generated',
      ),
      'refund' => const _TransactionConfig(
        icon: Icons.undo_rounded,
        color: AppColors.success,
        label: 'Generation Refund',
      ),
      'purchase' => const _TransactionConfig(
        icon: Icons.shopping_cart_rounded,
        color: AppColors.success,
        label: 'Credit Purchase',
      ),
      'daily_reset' => const _TransactionConfig(
        icon: Icons.refresh_rounded,
        color: AppColors.info,
        label: 'Daily Reset',
      ),
      'admin_grant' => const _TransactionConfig(
        icon: Icons.shield_rounded,
        color: AppColors.premium,
        label: 'Admin Grant',
      ),
      'manual' => const _TransactionConfig(
        icon: Icons.admin_panel_settings_outlined,
        color: AppColors.warning,
        label: 'Manual Adjustment',
      ),
      _ => const _TransactionConfig(
        icon: Icons.toll_rounded,
        color: AppColors.textMuted,
        label: 'Credit Transaction',
      ),
    };
  }

  final IconData icon;
  final Color color;
  final String label;
}
