import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/core/design_system/app_typography.dart';
import 'package:artio/core/utils/app_exception_mapper.dart';
import 'package:artio/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:artio/features/settings/data/notifications_provider.dart';
import 'package:artio/features/settings/presentation/widgets/theme_switcher.dart';
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

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await ref.read(authViewModelProvider.notifier).signOut();
      } catch (e) {
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
    final email = authState.maybeMap(
      authenticated: (s) => s.user.email,
      orElse: () => 'Unknown',
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _isLoading
          ? const LoadingStateWidget()
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                // ── User Profile Card ───────────────────────────────
                _UserProfileCard(email: email, isDark: isDark),

                const SizedBox(height: AppSpacing.lg),

                // ── Account Settings ────────────────────────────────
                _SectionLabel(label: 'Account'),
                const SizedBox(height: AppSpacing.sm),
                _SettingsCard(
                  isDark: isDark,
                  children: [
                    _SettingsTile(
                      icon: Icons.email_outlined,
                      iconBgColor: AppColors.info,
                      title: 'Email',
                      subtitle: email,
                      isDark: isDark,
                    ),
                    _SettingsDivider(isDark: isDark),
                    _SettingsTile(
                      icon: Icons.lock_reset_rounded,
                      iconBgColor: AppColors.warning,
                      title: 'Change Password',
                      trailing: _ChevronArrow(isDark: isDark),
                      onTap: () => _resetPassword(context, email),
                      isDark: isDark,
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // ── Appearance ───────────────────────────────────────
                _SectionLabel(label: 'Appearance'),
                const SizedBox(height: AppSpacing.sm),
                _SettingsCard(
                  isDark: isDark,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _IconBg(
                                icon: Icons.palette_outlined,
                                color: AppColors.accent,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Theme',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          ThemeSwitcher(),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // ── Notifications ────────────────────────────────────
                _SectionLabel(label: 'Notifications'),
                const SizedBox(height: AppSpacing.sm),
                _SettingsCard(
                  isDark: isDark,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: SwitchListTile(
                        secondary: _IconBg(
                          icon: Icons.notifications_outlined,
                          color: AppColors.primaryCta,
                        ),
                        title: const Text('Push Notifications'),
                        subtitle: const Text(
                          'Receive updates about your generations',
                        ),
                        value: ref.watch(notificationsNotifierProvider),
                        onChanged: (value) => ref
                            .read(notificationsNotifierProvider.notifier)
                            .setState(value),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // ── About ───────────────────────────────────────────
                _SectionLabel(label: 'About'),
                const SizedBox(height: AppSpacing.sm),
                _SettingsCard(
                  isDark: isDark,
                  children: [
                    _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      iconBgColor: AppColors.textMuted,
                      title: 'Version',
                      trailing: Text(
                        _version ?? 'Loading...',
                        style: AppTypography.captionMuted(context),
                      ),
                      isDark: isDark,
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // ── Logout Button ────────────────────────────────────
                OutlinedButton.icon(
                  onPressed: () => _signOut(context),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Logout'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error, width: 1.5),
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
    );
  }
}

// ── Helper Widgets ────────────────────────────────────────────────────────

class _UserProfileCard extends StatelessWidget {
  const _UserProfileCard({required this.email, required this.isDark});

  final String email;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
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
        border: isDark
            ? Border.all(color: AppColors.white10, width: 0.5)
            : null,
      ),
      child: Row(
        children: [
          // Avatar placeholder
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryCta, AppColors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                email.isNotEmpty ? email[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryCta.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'FREE PLAN',
                    style: AppTypography.labelBadge.copyWith(
                      color: AppColors.primaryCta,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: AppTypography.captionEmphasis.copyWith(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.textMuted
              : AppColors.textMutedLight,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children, required this.isDark});
  final List<Widget> children;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface1,
        borderRadius: BorderRadius.circular(14),
        border: isDark
            ? Border.all(color: AppColors.white10, width: 0.5)
            : null,
        boxShadow: isDark
            ? null
            : const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconBgColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    required this.isDark,
  });

  final IconData icon;
  final Color iconBgColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _IconBg(icon: icon, color: iconBgColor),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 60,
      color: isDark ? AppColors.white10 : AppColors.lightSurface3,
    );
  }
}

class _IconBg extends StatelessWidget {
  const _IconBg({required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}

class _ChevronArrow extends StatelessWidget {
  const _ChevronArrow({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.chevron_right_rounded,
      color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
    );
  }
}
