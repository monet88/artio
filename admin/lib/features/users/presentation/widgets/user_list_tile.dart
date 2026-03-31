import 'package:artio_admin/core/theme/admin_colors.dart';
import 'package:artio_admin/features/users/domain/entities/admin_user_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String userAvatarLetter(String? displayName, String email) {
  final name = displayName?.isNotEmpty == true ? displayName! : email;
  return name.isEmpty ? '?' : name[0].toUpperCase();
}

class UserListTile extends StatelessWidget {
  const UserListTile({super.key, required this.user, required this.onTap});

  final AdminUserModel user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: AdminColors.accent.withValues(alpha: 0.2),
        child: Text(
          userAvatarLetter(user.displayName, user.email),
          style: const TextStyle(
            color: AdminColors.accent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              user.displayName ?? user.email,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (user.isBanned)
            const _TierBadge(label: 'BANNED', color: AdminColors.error),
          if (user.isPremium && !user.isBanned)
            _TierBadge(label: user.tierBadgeLabel, color: AdminColors.accent),
        ],
      ),
      subtitle: Text(
        user.displayName != null ? user.email : '',
        style: theme.textTheme.bodySmall?.copyWith(
          color: isDark ? AdminColors.textMuted : Colors.grey,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${user.creditBalance} credits',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AdminColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (user.createdAt != null)
            Text(
              DateFormat.yMMMd().format(user.createdAt!),
              style: theme.textTheme.labelSmall?.copyWith(
                color: isDark ? AdminColors.textMuted : Colors.grey,
              ),
            ),
        ],
      ),
    );
  }
}

class _TierBadge extends StatelessWidget {
  const _TierBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
