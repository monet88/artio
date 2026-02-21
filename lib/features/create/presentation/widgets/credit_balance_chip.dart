import 'dart:math' as math;
import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/core/state/auth_view_model_provider.dart';
import 'package:artio/core/state/credit_balance_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Displays the user's remaining credit balance as a compact chip.
///
/// Only renders for authenticated users; returns [SizedBox.shrink] otherwise.
class CreditBalanceChip extends ConsumerWidget {
  const CreditBalanceChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref
        .watch(authViewModelProvider)
        .maybeMap(authenticated: (_) => true, orElse: () => false);
    if (!isLoggedIn) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ref
          .watch(creditBalanceNotifierProvider)
          .maybeWhen(
            data: (balance) => Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                avatar: const Text('💎', style: TextStyle(fontSize: 14)),
                label: Text('${math.max(0, balance.balance)} credits'),
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
