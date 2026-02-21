import 'package:artio/core/design_system/app_typography.dart';
import 'package:artio/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Section label for settings groups.
class SettingsSectionLabel extends StatelessWidget {
  const SettingsSectionLabel({required this.label, super.key});
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
          letterSpacing: 1,
        ),
      ),
    );
  }
}

/// Card container for a group of settings tiles.
class SettingsCard extends StatelessWidget {
  const SettingsCard({required this.children, required this.isDark, super.key});
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
      child: Column(children: children),
    );
  }
}

/// Individual settings row with icon, title, and optional trailing widget.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    required this.icon,
    required this.iconBgColor,
    required this.title,
    required this.isDark,
    super.key,
    this.subtitle,
    this.trailing,
    this.onTap,
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
  const SettingsDivider({required this.isDark, super.key});
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
  const SettingsIconBg({required this.icon, required this.color, super.key});
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
  const SettingsChevronArrow({required this.isDark, super.key});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.chevron_right_rounded,
      color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
    );
  }
}
