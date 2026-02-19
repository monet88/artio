import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/core/state/credit_balance_state_provider.dart';
import 'package:artio/core/state/subscription_state_provider.dart';
import 'package:artio/routing/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Card showing user's subscription status and credit balance.
///
/// Displays:
/// - Free plan: upgrade CTA + credit balance
/// - Active plan: tier, renewal date + credit balance + manage button
class SubscriptionCard extends ConsumerWidget {
  const SubscriptionCard({required this.isDark, super.key});

  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subAsync = ref.watch(subscriptionNotifierProvider);
    final creditBalance = ref.watch(creditBalanceNotifierProvider).valueOrNull;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2342) : const Color(0xFFF3F4F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: subAsync.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (_, __) => const SizedBox.shrink(),
        data: (status) {
          if (status.isFree) {
            return Row(
              children: [
                Icon(
                  Icons.workspace_premium_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Free Plan', style: theme.textTheme.titleSmall),
                      Text(
                        'Upgrade for more credits & features',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (creditBalance != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${creditBalance.balance} credits',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                FilledButton.tonal(
                  onPressed: () => const PaywallRoute().push<void>(context),
                  child: const Text('Upgrade'),
                ),
              ],
            );
          }

          final tierLabel = status.tier?.toUpperCase() ?? 'PREMIUM';
          final expiryText = status.expiresAt != null
              ? DateFormat.yMMMd().format(status.expiresAt!)
              : 'Never';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '$tierLabel Plan',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                status.willRenew
                    ? 'Renews $expiryText'
                    : 'Expires $expiryText',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (creditBalance != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${creditBalance.balance} credits remaining · ${status.monthlyCredits}/mo',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () => const PaywallRoute().push<void>(context),
                    child: const Text('Manage'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Card prompting unauthenticated users to sign in.
class SignInPromptCard extends StatelessWidget {
  const SignInPromptCard({required this.isDark, super.key});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [Color(0xFF1E2342), Color(0xFF282E55)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFFF3F4F8), Color(0xFFFFFFFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.person_outline,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Sign in to access your account',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => context.go('/login'),
              child: const Text('Sign In'),
            ),
          ),
        ],
      ),
    );
  }
}
