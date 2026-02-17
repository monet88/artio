import 'package:flutter/material.dart';

import '../../../../core/design_system/app_typography.dart';
import '../../../../theme/app_colors.dart';

/// Section label for settings groups.
class SettingsSectionLabel extends StatelessWidget {
  const SettingsSectionLabel({super.key, required this.label});
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

/// Card container for a group of settings tiles.
class SettingsCard extends StatelessWidget {
  const SettingsCard({super.key, required this.children, required this.isDark});
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

/// Individual settings row with icon, title, and optional trailing widget.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
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
      leading: SettingsIconBg(icon: icon, color: iconBgColor),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}

/// Divider between settings tiles.
class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key, required this.isDark});
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

/// Rounded icon background for settings tiles.
class SettingsIconBg extends StatelessWidget {
  const SettingsIconBg({super.key, required this.icon, required this.color});
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

/// Chevron arrow trailing icon for settings tiles.
class SettingsChevronArrow extends StatelessWidget {
  const SettingsChevronArrow({super.key, required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.chevron_right_rounded,
      color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
    );
  }
}
