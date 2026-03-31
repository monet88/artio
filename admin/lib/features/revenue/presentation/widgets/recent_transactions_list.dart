import 'package:artio_admin/core/theme/admin_colors.dart';
import 'package:artio_admin/features/revenue/domain/entities/revenue_stats.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecentTransactionsList extends StatelessWidget {
  final List<RevenueTransaction> transactions;

  const RecentTransactionsList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: isDark ? AdminColors.textHint : Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              'No revenue transactions yet',
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          for (int i = 0; i < transactions.length; i++) ...[
            _TransactionRow(
              transaction: transactions[i],
              isDark: isDark,
            ),
            if (i < transactions.length - 1)
              Divider(
                height: 1,
                color:
                    isDark ? AdminColors.borderSubtle : Colors.grey.shade200,
              ),
          ],
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final RevenueTransaction transaction;
  final bool isDark;

  const _TransactionRow({
    required this.transaction,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSubscription = transaction.type == 'subscription';
    final typeColor =
        isSubscription ? AdminColors.statAmber : AdminColors.statBlue;
    final email = transaction.userEmail ??
        '${transaction.userId.substring(0, 8)}... (deleted)';

    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: typeColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          isSubscription
              ? Icons.workspace_premium_rounded
              : Icons.shopping_cart_rounded,
          color: typeColor,
          size: 18,
        ),
      ),
      title: Text(
        email,
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        DateFormat.yMMMd().add_Hm().format(transaction.createdAt.toLocal()),
        style: theme.textTheme.labelSmall?.copyWith(
          color: isDark ? AdminColors.textMuted : Colors.grey,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              isSubscription ? 'SUB' : 'BUY',
              style: TextStyle(
                color: typeColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '+${transaction.amount} cr',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AdminColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
