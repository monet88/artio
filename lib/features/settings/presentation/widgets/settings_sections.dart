import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/core/design_system/app_typography.dart';
import 'package:artio/features/settings/data/notifications_provider.dart';
import 'package:artio/features/settings/presentation/widgets/theme_switcher.dart';
import 'package:artio/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_helpers.dart';

/// All grouped settings sections rendered inside the settings screen ListView.
class SettingsSections extends ConsumerWidget {
  const SettingsSections({
    super.key,
    required this.email,
    required this.isDark,
    required this.version,
    required this.onResetPassword,
    required this.onSignOut,
  });

  final String email;
  final bool isDark;
  final String? version;
  final VoidCallback onResetPassword;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Account Settings ──────────────────────────────────
        SettingsSectionLabel(label: 'Account'),
        const SizedBox(height: AppSpacing.sm),
        SettingsCard(
          isDark: isDark,
          children: [
            SettingsTile(
              icon: Icons.email_outlined,
              iconBgColor: AppColors.info,
              title: 'Email',
              subtitle: email,
              isDark: isDark,
            ),
            SettingsDivider(isDark: isDark),
            SettingsTile(
              icon: Icons.lock_reset_rounded,
              iconBgColor: AppColors.warning,
              title: 'Change Password',
              trailing: SettingsChevronArrow(isDark: isDark),
              onTap: onResetPassword,
              isDark: isDark,
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),

        // ── Appearance ─────────────────────────────────────────
        SettingsSectionLabel(label: 'Appearance'),
        const SizedBox(height: AppSpacing.sm),
        SettingsCard(
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
                      SettingsIconBg(
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

        // ── Notifications ──────────────────────────────────────
        SettingsSectionLabel(label: 'Notifications'),
        const SizedBox(height: AppSpacing.sm),
        SettingsCard(
          isDark: isDark,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: SwitchListTile(
                secondary: SettingsIconBg(
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

        // ── About ───────────────────────────────────────────────
        SettingsSectionLabel(label: 'About'),
        const SizedBox(height: AppSpacing.sm),
        SettingsCard(
          isDark: isDark,
          children: [
            SettingsTile(
              icon: Icons.info_outline_rounded,
              iconBgColor: AppColors.textMuted,
              title: 'Version',
              trailing: Text(
                version ?? 'Loading...',
                style: AppTypography.captionMuted(context),
              ),
              isDark: isDark,
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),

        // ── Logout Button ────────────────────────────────────
        OutlinedButton.icon(
          onPressed: onSignOut,
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
      ],
    );
  }
}
