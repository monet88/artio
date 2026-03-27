import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/core/state/auth_view_model_provider.dart';
import 'package:artio/core/state/subscription_state_provider.dart';
import 'package:artio/core/utils/app_exception_mapper.dart';
import 'package:artio/features/settings/presentation/widgets/settings_sections.dart';
import 'package:artio/features/settings/presentation/widgets/subscription_card.dart';
import 'package:artio/features/settings/presentation/widgets/user_profile_card.dart';
import 'package:artio/shared/widgets/loading_state_widget.dart';
import 'package:artio/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Redesigned Settings screen with card-based layout, user profile card,
/// grouped settings, icon backgrounds, chevron arrows, and styled logout.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String? _version;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _version = '${packageInfo.version} (${packageInfo.buildNumber})';
        });
      }
    } on Exception {
      if (mounted) {
        setState(() {
          _version = 'Unknown';
        });
      }
    }
  }

  Future<void> _resetPassword(BuildContext context, String email) async {
    try {
      await ref.read(authViewModelProvider.notifier).resetPassword(email);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password reset email sent to $email')),
        );
      }
    } on Exception catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppExceptionMapper.toUserMessage(e))),
        );
      }
    }
  }

  Future<void> _restorePurchases(BuildContext context) async {
    try {
      await ref.read(subscriptionNotifierProvider.notifier).restore();
      if (!context.mounted) return;
      // restore() uses AsyncValue.guard — failures are stored in state, not thrown.
      // Check state.hasError first, then isActive to show the correct message.
      final subState = ref.read(subscriptionNotifierProvider);
      final String message;
      if (subState.hasError) {
        message = 'Restore failed. Please try again.';
      } else if (subState.valueOrNull?.isActive ?? false) {
        message = '✅ Purchases restored!';
      } else {
        message = 'No active subscription found.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restore failed. Please try again.')),
        );
      }
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This will permanently delete your account and all generated images. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      setState(() => _isLoading = true);
      try {
        await ref.read(authViewModelProvider.notifier).deleteAccount();
      } on Object catch (e) {
        // `on Object` (not `on Exception`) catches AppException and any
        // non-Exception throwables from Riverpod or platform code.
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppExceptionMapper.toUserMessage(e))),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      setState(() => _isLoading = true);
      try {
        await ref.read(authViewModelProvider.notifier).signOut();
      } on Exception catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppExceptionMapper.toUserMessage(e))),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final subStatus = ref.watch(subscriptionNotifierProvider);
    final isLoggedIn = authState.maybeMap(
      authenticated: (_) => true,
      orElse: () => false,
    );
    final email = authState.maybeMap(
      authenticated: (s) => s.user.email,
      orElse: () => '',
    );
    // Prefer RevenueCat SDK data (immediate) over DB value (webhook-dependent).
    // Falls back to DB if RevenueCat hasn't loaded yet.
    final isPremium = subStatus.valueOrNull?.isActive ??
        authState.maybeMap(
          authenticated: (s) => s.user.isPremium,
          orElse: () => false,
        ) ??
        false;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _isLoading
          ? const LoadingStateWidget()
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                if (isLoggedIn)
                  UserProfileCard(
                    email: email,
                    isDark: isDark,
                    isPremium: isPremium,
                  )
                else
                  SignInPromptCard(isDark: isDark),
                if (isLoggedIn) ...[
                  const SizedBox(height: AppSpacing.md),
                  SubscriptionCard(isDark: isDark),
                ],
                const SizedBox(height: AppSpacing.lg),
                SettingsSections(
                  email: email,
                  isDark: isDark,
                  version: _version,
                  isLoggedIn: isLoggedIn,
                  isPremium: isPremium,
                  onResetPassword: () => _resetPassword(context, email),
                  onSignOut: () => _signOut(context),
                  onRestore: () => _restorePurchases(context),
                  onDeleteAccount: () => _deleteAccount(context),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
    );
  }
}
