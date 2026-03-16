import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/core/exceptions/app_exception.dart';
import 'package:artio/core/utils/app_exception_mapper.dart';
import 'package:artio/core/utils/url_launcher_utils.dart';
import 'package:artio/features/subscription/domain/entities/subscription_package.dart';
import 'package:artio/features/subscription/domain/entities/subscription_status.dart';
import 'package:artio/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:artio/shared/widgets/error_state_widget.dart';
import 'package:artio/shared/widgets/loading_state_widget.dart';
import 'package:artio/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  SubscriptionPackage? _selectedPackage;
  bool _isPurchasing = false;

  @override
  Widget build(BuildContext context) {
    final offerings = ref.watch(offeringsProvider);
    final subscription = ref.watch(subscriptionNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: offerings.when(
        loading: () => const LoadingStateWidget(compact: true),
        error: (e, _) => ErrorStateWidget.fromError(
          error: e,
          message: 'Unable to load subscription options',
          onRetry: () => ref.invalidate(offeringsProvider),
        ),
        data: (packages) => _buildContent(context, packages, subscription),
      ),
    );
  }

  void _initSelectedPackage(List<SubscriptionPackage> packages) {
    if (_selectedPackage != null || packages.isEmpty) return;
    final recommended = packages.firstWhere(
      (p) => !p.identifier.startsWith('artio_pro_'),
      orElse: () => packages.first,
    );
    setState(() => _selectedPackage = recommended);
  }

  Widget _buildContent(
    BuildContext context,
    List<SubscriptionPackage> packages,
    AsyncValue<SubscriptionStatus> subscription,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _initSelectedPackage(packages);

    return Stack(
      children: [
        // ── Gradient Background ─────────────────────────────────────────
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0D1025), Color(0xFF1A0D35), Color(0xFF0D1025)],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),

        SafeArea(
          child: Column(
            children: [
              // ── Header ───────────────────────────────────────────────
              _buildHeader(context),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppSpacing.sm),

                      // ── Hero section ────────────────────────────────
                      _buildHero(),
                      const SizedBox(height: AppSpacing.xl),

                      // ── Benefits grid ───────────────────────────────
                      _buildBenefits(),
                      const SizedBox(height: AppSpacing.xl),

                      // ── Plan cards ──────────────────────────────────
                      ...packages.map(
                        (pkg) => _buildPlanCard(pkg, subscription),
                      ),

                      // ── Free tier reminder ──────────────────────────
                      const SizedBox(height: AppSpacing.md),
                      _buildFreeTierNote(isDark),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),

              // ── Bottom CTA ───────────────────────────────────────────
              _buildBottomCTA(isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.close_rounded,
              color: AppColors.textSecondary,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          TextButton(
            onPressed: _isPurchasing ? null : _handleRestore,
            child: const Text(
              'Restore',
              style: TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Column(
      children: [
        // Glowing diamond icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.4),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(
            Icons.diamond_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text(
          'Unlock Premium',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        const Text(
          'Generate unlimited AI art with no limits',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.white60, fontSize: 15, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildBenefits() {
    const benefits = [
      (icon: Icons.all_inclusive, label: 'Unlimited Credits'),
      (icon: Icons.block, label: 'No Ads'),
      (icon: Icons.auto_awesome, label: 'All AI Models'),
      (icon: Icons.high_quality, label: 'Max Quality'),
      (icon: Icons.flash_on_rounded, label: 'Priority Queue'),
      (icon: Icons.lock_open_rounded, label: 'Early Access'),
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      alignment: WrapAlignment.center,
      children: benefits
          .map(
            (b) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white05,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.white10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(b.icon, size: 14, color: AppColors.primaryCta),
                  const SizedBox(width: 6),
                  Text(
                    b.label,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildPlanCard(
    SubscriptionPackage pkg,
    AsyncValue<SubscriptionStatus> subscription,
  ) {
    final isPro = pkg.identifier.startsWith('artio_pro_');
    final isSelected = _selectedPackage == pkg;
    final isCurrentPlan =
        subscription.valueOrNull?.tier == (isPro ? 'pro' : 'ultra');
    final isRecommended = !isPro;

    return GestureDetector(
      onTap: isCurrentPlan
          ? null
          : () => setState(() => _selectedPackage = pkg),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.gradientStart.withValues(alpha: 0.1),
                    AppColors.gradientEnd.withValues(alpha: 0.1),
                  ],
                )
              : null,
          color: isSelected ? null : AppColors.darkSurface2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryCta
                : isRecommended
                ? AppColors.accent.withValues(alpha: 0.4)
                : AppColors.white10,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  isPro ? 'Pro' : 'Ultra',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (isRecommended) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.gradientStart,
                          AppColors.gradientEnd,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'POPULAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
                if (isCurrentPlan) ...[
                  const SizedBox(width: 8),
                  const Text(
                    'Current',
                    style: TextStyle(
                      color: AppColors.primaryCta,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      pkg.priceString,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      pkg.identifier.contains('yearly')
                          ? 'per year'
                          : 'per month',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              isPro
                  ? '200 credits/month • All AI models • No ads'
                  : '500 credits/month • Priority queue • Early access',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFreeTierNote(bool isDark) {
    return const Text(
      'Free plan: 10 welcome credits + earn more by watching ads',
      textAlign: TextAlign.center,
      style: TextStyle(color: AppColors.white40, fontSize: 12, height: 1.5),
    );
  }

  Widget _buildComplianceText(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          height: 1.5,
        ),
        children: [
          const TextSpan(text: 'By subscribing you agree to our '),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: GestureDetector(
              onTap: () => launchInAppUrl(context, 'https://artio.app/terms'),
              child: const Text(
                'Terms of Service',
                style: TextStyle(
                  color: AppColors.primaryCta,
                  fontSize: 11,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primaryCta,
                ),
              ),
            ),
          ),
          const TextSpan(text: ' and '),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: GestureDetector(
              onTap: () => launchInAppUrl(context, 'https://artio.app/privacy'),
              child: const Text(
                'Privacy Policy',
                style: TextStyle(
                  color: AppColors.primaryCta,
                  fontSize: 11,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primaryCta,
                ),
              ),
            ),
          ),
          const TextSpan(
            text: '. Subscription auto-renews unless cancelled at least '
                '24 hours before the end of the current period. '
                'Manage or cancel anytime in your account settings.',
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildBottomCTA(bool isDark) {
    // Bottom inset is handled by the SafeArea wrapping the entire screen content.
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkBackground.withValues(alpha: 0.95),
        border: const Border(top: BorderSide(color: AppColors.white10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Subscribe button
          SizedBox(
            height: 54,
            child: _selectedPackage == null
                ? ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkSurface3,
                      foregroundColor: AppColors.textMuted,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Select a plan above'),
                  )
                : DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.gradientStart,
                          AppColors.gradientEnd,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryCta.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isPurchasing ? null : _handlePurchase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isPurchasing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Subscribe Now',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildComplianceText(context),
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
      if (!mounted) return;

      // AsyncValue.guard never throws — check state explicitly for errors.
      final purchaseState = ref.read(subscriptionNotifierProvider);
      if (purchaseState.hasError) {
        final err = purchaseState.error!;
        final isCancelled = err is PaymentException && err.code == 'user_cancelled';
        if (isCancelled) return; // user dismissed — silent, no snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppExceptionMapper.toUserMessage(err)),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // Verify subscription is actually active before claiming success.
      final status = purchaseState.valueOrNull;
      if (status == null || !status.isActive) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Purchase processed. If credits are missing, tap Restore.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Subscription activated! Welcome to Premium.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppExceptionMapper.toUserMessage(e)),
            behavior: SnackBarBehavior.floating,
          ),
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
      if (!mounted) return;
      final subscriptionState = ref.read(subscriptionNotifierProvider);
      if (subscriptionState.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Restore failed. Please try again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        final status = subscriptionState.valueOrNull;
        if (status != null && status.isActive) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Purchases restored!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No previous purchases found for this account.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }
}
