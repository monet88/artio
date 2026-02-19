import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:artio/features/credits/presentation/providers/credit_balance_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Displays the user's remaining credit balance as a compact chip.
///
/// Only renders for authenticated users; returns [SizedBox.shrink] otherwise.
class CreditBalanceChip extends ConsumerWidget {
  const CreditBalanceChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authViewModelProvider).maybeMap(
          authenticated: (_) => true,
          orElse: () => false,
        );
    if (!isLoggedIn) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ref.watch(creditBalanceNotifierProvider).maybeWhen(
        data: (balance) => Align(
          alignment: Alignment.centerLeft,
          child: Chip(
            avatar: const Text('💎', style: TextStyle(fontSize: 14)),
            label: Text('${balance.balance} credits'),
            visualDensity: VisualDensity.compact,
          ),
        ),
        loading: () => const Align(
          alignment: Alignment.centerLeft,
          child: Chip(
            avatar: Text('💎', style: TextStyle(fontSize: 14)),
            label: Text('...'),
            visualDensity: VisualDensity.compact,
          ),
        ),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }
}
