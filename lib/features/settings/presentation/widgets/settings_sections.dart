import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/core/design_system/app_typography.dart';
import 'package:artio/core/utils/url_launcher_utils.dart';
import 'package:artio/features/settings/domain/providers/notifications_provider.dart';
import 'package:artio/features/settings/presentation/widgets/settings_helpers.dart';
import 'package:artio/features/settings/presentation/widgets/theme_switcher.dart';
import 'package:artio/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// All grouped settings sections rendered inside the settings screen ListView.
class SettingsSections extends ConsumerWidget {
  const SettingsSections({
    required this.email,
    required this.isDark,
    required this.version,
    required this.isLoggedIn,
    required this.onResetPassword,
    required this.onSignOut,
    super.key,
  });

  final String email;
  final bool isDark;
  final String? version;
  final bool isLoggedIn;
  final VoidCallback onResetPassword;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Account Settings ──────────────────────────────────
        if (isLoggedIn) ...[
          const SettingsSectionLabel(label: 'Account'),
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
        ],

        // ── Appearance ─────────────────────────────────────────
        const SettingsSectionLabel(label: 'Appearance'),
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
                      const SettingsIconBg(
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
                  const ThemeSwitcher(),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),

        // ── Notifications ──────────────────────────────────────
        const SettingsSectionLabel(label: 'Notifications'),
        const SizedBox(height: AppSpacing.sm),
        SettingsCard(
          isDark: isDark,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: SwitchListTile(
                secondary: const SettingsIconBg(
                  icon: Icons.notifications_outlined,
                  color: AppColors.primaryCta,
                ),
                title: const Text('Push Notifications'),
                subtitle: const Text('Receive updates about your generations'),
                value: ref.watch(notificationsNotifierProvider),
                onChanged: (value) => ref
                    .read(notificationsNotifierProvider.notifier)
                    .setState(value: value),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),

        // ── About ───────────────────────────────────────────────
        const SettingsSectionLabel(label: 'About'),
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

        // ── Legal ────────────────────────────────────────────────
        // REQUIRED by Apple App Store — reviewers verify these links exist.
        const SettingsSectionLabel(label: 'Legal'),
        const SizedBox(height: AppSpacing.sm),
        SettingsCard(
          isDark: isDark,
          children: [
            SettingsTile(
              icon: Icons.privacy_tip_outlined,
              iconBgColor: const Color(0xFF5B8BF0),
              title: 'Privacy Policy',
              trailing: SettingsChevronArrow(isDark: isDark),
              isDark: isDark,
              onTap: () => launchUrlSafely(
                context,
                // TODO(legal): Replace with your hosted Privacy Policy URL
                'https://artio.app/privacy',
              ),
            ),
            SettingsDivider(isDark: isDark),
            SettingsTile(
              icon: Icons.gavel_outlined,
              iconBgColor: const Color(0xFF7B61FF),
              title: 'Terms of Service',
              trailing: SettingsChevronArrow(isDark: isDark),
              isDark: isDark,
              onTap: () => launchUrlSafely(
                context,
                // TODO(legal): Replace with your hosted Terms of Service URL
                'https://artio.app/terms',
              ),
            ),
            SettingsDivider(isDark: isDark),
            SettingsTile(
              icon: Icons.code_outlined,
              iconBgColor: AppColors.textMuted,
              title: 'Open Source Licenses',
              trailing: SettingsChevronArrow(isDark: isDark),
              isDark: isDark,
              onTap: () => showLicensePage(
                context: context,
                applicationName: 'Artio',
                applicationLegalese: '© 2026 Artio. All rights reserved.',
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),

        // ── Support ──────────────────────────────────────────────
        const SettingsSectionLabel(label: 'Support'),
        const SizedBox(height: AppSpacing.sm),
        SettingsCard(
          isDark: isDark,
          children: [
            SettingsTile(
              icon: Icons.help_outline_rounded,
              iconBgColor: const Color(0xFF34C759),
              title: 'Help & FAQ',
              trailing: SettingsChevronArrow(isDark: isDark),
              isDark: isDark,
              onTap: () => launchUrlSafely(
                context,
                // TODO(support): Replace with your help centre URL
                'https://artio.app/help',
              ),
            ),
            SettingsDivider(isDark: isDark),
            SettingsTile(
              icon: Icons.bug_report_outlined,
              iconBgColor: AppColors.warning,
              title: 'Report a Problem',
              trailing: SettingsChevronArrow(isDark: isDark),
              isDark: isDark,
              onTap: () => launchEmailSafely(
                context,
                to: 'support@artio.app',
                subject: 'Problem Report — Artio App',
                body:
                    'Describe the problem you encountered:\n\n'
                    'App version: ${version ?? 'Unknown'}\n',
              ),
            ),
          ],
        ),

        if (isLoggedIn) ...[
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
      ],
    );
  }
}
