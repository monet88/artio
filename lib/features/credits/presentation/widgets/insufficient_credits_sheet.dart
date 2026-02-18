import 'package:artio/core/constants/app_constants.dart';
import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/core/exceptions/app_exception.dart';
import 'package:artio/core/services/rewarded_ad_service.dart';
import 'package:artio/features/credits/presentation/providers/ad_reward_provider.dart';
import 'package:artio/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:artio/routing/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Bottom sheet displayed when user has insufficient credits
/// to generate with the selected model.
class InsufficientCreditsSheet extends ConsumerStatefulWidget {
  const InsufficientCreditsSheet({
    required this.currentBalance,
    required this.requiredCredits,
    super.key,
  });

  final int currentBalance;
  final int requiredCredits;

  @override
  ConsumerState<InsufficientCreditsSheet> createState() =>
      _InsufficientCreditsSheetState();
}

class _InsufficientCreditsSheetState
    extends ConsumerState<InsufficientCreditsSheet> {
  bool _isRewarding = false;

  Future<void> _onWatchAd() async {
    if (_isRewarding) return;
    setState(() => _isRewarding = true);

    try {
      final result =
          await ref.read(adRewardNotifierProvider.notifier).watchAdAndReward();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Earned ${result.creditsAwarded} credits! '
            'Balance: ${result.newBalance}',
          ),
        ),
      );
      Navigator.pop(context);
    } on AppException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to earn credits. Try again.')),
      );
    } finally {
      if (mounted) setState(() => _isRewarding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final adsRemainingAsync = ref.watch(adRewardNotifierProvider);
    final adService = ref.watch(rewardedAdServiceProvider);
    final isSubscriber = _isSubscriber;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('💎', style: TextStyle(fontSize: 48)),
          const SizedBox(height: AppSpacing.md),
          Text('Not enough credits', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'This model costs ${widget.requiredCredits} credits, '
            'but you only have ${widget.currentBalance}.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),

          if (isSubscriber) ...[
            // Subscriber: show renewal info + ad option + manage link
            _buildRenewalInfo(theme),
            const SizedBox(height: AppSpacing.sm),
            _buildAdButton(adsRemainingAsync, adService),
            const SizedBox(height: AppSpacing.sm),
            _buildManageSubscriptionButton(),
          ] else ...[
            // Free user: ad button + upgrade option
            _buildAdButton(adsRemainingAsync, adService),
            const SizedBox(height: AppSpacing.sm),
            _buildUpgradeButton(),
          ],

          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Dismiss'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }

  bool get _isSubscriber {
    final sub = ref.watch(subscriptionNotifierProvider).valueOrNull;
    return sub != null && sub.isActive;
  }

  Widget _buildRenewalInfo(ThemeData theme) {
    final sub = ref.watch(subscriptionNotifierProvider).valueOrNull;
    final expiresAt = sub?.expiresAt;
    final renewalText = expiresAt != null
        ? 'Your credits refresh on ${DateFormat.yMMMd().format(expiresAt)}'
        : 'Your credits refresh at next billing cycle';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              renewalText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManageSubscriptionButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.pop(context);
          const PaywallRoute().push<void>(context);
        },
        icon: const Icon(Icons.settings_outlined, size: 18),
        label: const Text('Manage Subscription'),
      ),
    );
  }

  Widget _buildUpgradeButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.pop(context);
          const PaywallRoute().push<void>(context);
        },
        icon: const Icon(Icons.star_outline, size: 18),
        label: const Text('Upgrade to Premium'),
      ),
    );
  }

  Widget _buildAdButton(
    AsyncValue<int> adsRemainingAsync,
    RewardedAdService adService,
  ) {
    return SizedBox(
      width: double.infinity,
      child: adsRemainingAsync.when(
        data: (adsRemaining) {
          final canWatch = adsRemaining > 0 && adService.isAdLoaded;
          return FilledButton.icon(
            onPressed:
                canWatch && !_isRewarding ? _onWatchAd : null,
            icon: _isRewarding
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_circle_outline),
            label: Text(
              adsRemaining > 0
                  ? 'Watch ad for +${AppConstants.adRewardCredits} credits ($adsRemaining left)'
                  : 'Daily ad limit reached',
            ),
          );
        },
        loading: () => FilledButton.icon(
          onPressed: null,
          icon: const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          label: const Text('Loading...'),
        ),
        error: (_, __) => FilledButton.icon(
          onPressed: () => ref.invalidate(adRewardNotifierProvider),
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      ),
    );
  }
}
