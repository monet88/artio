import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/features/subscription/domain/entities/subscription_status.dart';
import 'package:artio/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:artio/features/subscription/presentation/widgets/tier_comparison_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  Package? _selectedPackage;
  bool _isPurchasing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final offerings = ref.watch(offeringsProvider);
    final subscription = ref.watch(subscriptionNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade to Premium'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: offerings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Unable to load subscription options',
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () => ref.invalidate(offeringsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (packages) => _buildContent(context, packages, subscription),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<Package> packages,
    AsyncValue<SubscriptionStatus> subscription,
  ) {

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Free tier
                  TierComparisonCard(
                    tierName: 'Free',
                    price: 'Free',
                    credits: '10 welcome credits',
                    features: const [
                      'Basic AI models',
                      'Watch ads for credits',
                      'Standard quality',
                    ],
                    isCurrentPlan: subscription.valueOrNull?.isFree ?? true,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Build cards from available packages
                  ...packages.map((pkg) {
                    final isPro = pkg.storeProduct.identifier
                        .startsWith('artio_pro_');
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: TierComparisonCard(
                        tierName: isPro ? 'Pro' : 'Ultra',
                        price: pkg.storeProduct.priceString,
                        credits: isPro ? '200 credits/month' : '500 credits/month',
                        features: isPro
                            ? const [
                                'All AI models',
                                'No ads',
                                'High quality',
                                '200 monthly credits',
                              ]
                            : const [
                                'All AI models',
                                'No ads',
                                'Ultra quality',
                                '500 monthly credits',
                                'Priority generation',
                              ],
                        isCurrentPlan: subscription.valueOrNull?.tier ==
                            (isPro ? 'pro' : 'ultra'),
                        isSelected: _selectedPackage == pkg,
                        isRecommended: !isPro,
                        onTap: () => setState(() => _selectedPackage = pkg),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Purchase / Restore buttons
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton(
                  onPressed:
                      _selectedPackage != null && !_isPurchasing
                          ? _handlePurchase
                          : null,
                  child: _isPurchasing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Subscribe'),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: _isPurchasing ? null : _handleRestore,
                  child: const Text('Restore Purchases'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePurchase() async {
    final pkg = _selectedPackage;
    if (pkg == null) return;

    setState(() => _isPurchasing = true);
    try {
      await ref.read(subscriptionNotifierProvider.notifier).purchase(pkg);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subscription activated!')),
        );
        context.pop();
      }
    } on Object catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase failed. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  Future<void> _handleRestore() async {
    setState(() => _isPurchasing = true);
    try {
      await ref.read(subscriptionNotifierProvider.notifier).restore();
      if (mounted) {
        final status = ref.read(subscriptionNotifierProvider).valueOrNull;
        if (status != null && status.isActive) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Purchases restored!')),
          );
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No previous purchases found.')),
          );
        }
      }
    } on Object catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restore failed. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }
}
