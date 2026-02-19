import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/core/utils/app_exception_mapper.dart';
import 'package:artio/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:artio/features/settings/domain/providers/notifications_provider.dart';
import 'package:artio/features/settings/presentation/widgets/settings_sections.dart';
import 'package:artio/features/settings/presentation/widgets/subscription_card.dart';
import 'package:artio/features/settings/presentation/widgets/user_profile_card.dart';
import 'package:artio/shared/widgets/loading_state_widget.dart';
import 'package:artio/theme/app_colors.dart';
import 'package:artio/utils/logger_service.dart';
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
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    try {
      await ref.read(notificationsNotifierProvider.notifier).init();
    } on Exception catch (error, stackTrace) {
      Log.e('Failed to load notification settings', error, stackTrace);
    }
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
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
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
    final isLoggedIn = authState.maybeMap(
      authenticated: (_) => true,
      orElse: () => false,
    );
    final email = authState.maybeMap(
      authenticated: (s) => s.user.email,
      orElse: () => '',
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _isLoading
          ? const LoadingStateWidget()
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                if (isLoggedIn)
                  UserProfileCard(email: email, isDark: isDark)
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
                  onResetPassword: () => _resetPassword(context, email),
                  onSignOut: () => _signOut(context),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
    );
  }
}
