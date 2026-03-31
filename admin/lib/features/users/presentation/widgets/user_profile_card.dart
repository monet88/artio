import 'package:artio_admin/core/theme/admin_colors.dart';
import 'package:artio_admin/features/users/domain/entities/admin_user_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String avatarLetter(String? displayName, String email) {
  final name = displayName?.isNotEmpty == true ? displayName! : email;
  return name.isEmpty ? '?' : name[0].toUpperCase();
}

class UserProfileCard extends StatelessWidget {
  final AdminUserModel user;

  const UserProfileCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return UserDetailSectionCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AdminColors.accent.withValues(alpha: 0.2),
            child: Text(
              avatarLetter(user.displayName, user.email),
              style: const TextStyle(
                color: AdminColors.accent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (user.displayName != null)
                  Text(
                    user.displayName!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                Text(
                  user.email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? AdminColors.textMuted : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _StatusBadge(
                      label: user.tierBadgeLabel,
                      color: user.isPremium
                          ? AdminColors.accent
                          : AdminColors.textMuted,
                    ),
                    if (user.isBanned) ...[
                      const SizedBox(width: 8),
                      const _StatusBadge(
                        label: 'BANNED',
                        color: AdminColors.error,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UserStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const UserStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AdminColors.surfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AdminColors.borderSubtle : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

/// Shared card container for user detail sections.
class UserDetailSectionCard extends StatelessWidget {
  final Widget child;

  const UserDetailSectionCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AdminColors.surfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AdminColors.borderSubtle : Colors.grey.shade200,
        ),
      ),
      child: child,
    );
  }
}

String formatJoinDate(DateTime? date) =>
    date != null ? DateFormat.yMMMd().format(date) : '—';

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
