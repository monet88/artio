import 'package:artio_admin/core/theme/admin_colors.dart';
import 'package:artio_admin/features/users/domain/entities/admin_user_model.dart';
import 'package:artio_admin/shared/widgets/error_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'users_page.g.dart';

// ── Provider ─────────────────────────────────────────────────────────────────

@riverpod
class Users extends _$Users {
  @override
  Stream<List<AdminUserModel>> build() {
    return Supabase.instance.client
        .from('profiles')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map(
          (rows) =>
              rows.map((row) => AdminUserModel.fromJson(row)).toList(),
        );
  }
}

// ── Page ─────────────────────────────────────────────────────────────────────

class UsersPage extends ConsumerStatefulWidget {
  const UsersPage({super.key});

  @override
  ConsumerState<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends ConsumerState<UsersPage> {
  String _searchQuery = '';
  _UserFilter _filter = _UserFilter.all;

  List<AdminUserModel> _applyFilters(List<AdminUserModel> users) {
    var result = users;

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where(
            (u) =>
                u.email.toLowerCase().contains(q) ||
                (u.displayName?.toLowerCase().contains(q) ?? false),
          )
          .toList();
    }

    result = switch (_filter) {
      _UserFilter.all => result,
      _UserFilter.premium => result.where((u) => u.isPremium).toList(),
      _UserFilter.free => result.where((u) => !u.isPremium).toList(),
      _UserFilter.banned => result.where((u) => u.isBanned).toList(),
    };

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: Column(
        children: [
          // ── Search + Filters ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by email or name...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () =>
                                setState(() => _searchQuery = ''),
                          )
                        : null,
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _UserFilter.values.map((f) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(f.label),
                          selected: _filter == f,
                          onSelected: (_) =>
                              setState(() => _filter = f),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── User List ─────────────────────────────────────────────────
          Expanded(
            child: usersAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, _) => ErrorStateWidget.fromError(
                error: err,
                message: err.toString(),
                onRetry: () => ref.invalidate(usersProvider),
              ),
              data: (users) {
                final filtered = _applyFilters(users);

                if (users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: isDark
                              ? AdminColors.textHint
                              : Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No users yet',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  );
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'No users match your filters',
                      style: theme.textTheme.bodyLarge,
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  itemCount: filtered.length,
                  separatorBuilder: (ctx, i) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final user = filtered[index];
                    return _UserListTile(
                      user: user,
                      onTap: () => context.go('/users/${user.id}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter Enum ───────────────────────────────────────────────────────────────

enum _UserFilter {
  all('All'),
  premium('Premium'),
  free('Free'),
  banned('Banned');

  const _UserFilter(this.label);
  final String label;
}

// ── Helpers ──────────────────────────────────────────────────────────────────

String _avatarLetter(String? displayName, String email) {
  final name = displayName?.isNotEmpty == true ? displayName! : email;
  return name.isEmpty ? '?' : name[0].toUpperCase();
}

// ── List Tile ─────────────────────────────────────────────────────────────────

class _UserListTile extends StatelessWidget {
  const _UserListTile({required this.user, required this.onTap});

  final AdminUserModel user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      leading: CircleAvatar(
        backgroundColor: AdminColors.accent.withValues(alpha: 0.2),
        child: Text(
          _avatarLetter(user.displayName, user.email),
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

// ── Tier Badge ────────────────────────────────────────────────────────────────

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
