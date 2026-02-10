import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:artio/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:artio/features/settings/presentation/widgets/theme_switcher.dart';
import 'package:artio/features/settings/data/notifications_provider.dart';
import 'package:artio/utils/logger_service.dart';
import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/shared/widgets/section_header.dart';
import 'package:artio/shared/widgets/loading_state_widget.dart';

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
    } catch (error, stackTrace) {
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
    } catch (e) {
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
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending reset email: $e')),
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
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await ref.read(authViewModelProvider.notifier).signOut();
        // Router will handle redirection via auth guard
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error signing out: $e')),
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
    final email = authState.maybeMap(
      authenticated: (s) => s.user.email,
      orElse: () => 'Unknown',
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _isLoading
          ? const LoadingStateWidget()
          : ListView(
              children: [
                const SectionHeader(title: 'Account'),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Email'),
                  subtitle: Text(email),
                ),
                ListTile(
                  leading: const Icon(Icons.lock_reset),
                  title: const Text('Change Password'),
                  onTap: () => _resetPassword(context, email),
                ),
                ListTile(
                  leading: Icon(
                    Icons.logout,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    'Logout',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  onTap: () => _signOut(context),
                ),
                const Divider(),
                const SectionHeader(title: 'Appearance'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Theme', style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: AppSpacing.sm),
                      ThemeSwitcher(),
                    ],
                  ),
                ),
                const Divider(),
                const SectionHeader(title: 'Notifications'),
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined),
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Receive updates about your generations'),
                  value: ref.watch(notificationsNotifierProvider),
                  onChanged: (value) => ref.read(notificationsNotifierProvider.notifier).setState(value),
                ),
                const Divider(),
                const SectionHeader(title: 'About'),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Version'),
                  trailing: Text(_version ?? 'Loading...'),
                ),
              ],
            ),
    );
  }
}
