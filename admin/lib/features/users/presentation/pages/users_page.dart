import 'package:artio_admin/core/theme/admin_colors.dart';
import 'package:artio_admin/features/users/domain/entities/admin_user_model.dart';
import 'package:artio_admin/features/users/presentation/widgets/user_list_tile.dart';
import 'package:artio_admin/features/users/presentation/widgets/user_search_bar.dart';
import 'package:artio_admin/shared/widgets/error_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  UserFilter _filter = UserFilter.all;

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
      UserFilter.all => result,
      UserFilter.premium => result.where((u) => u.isPremium).toList(),
      UserFilter.free => result.where((u) => !u.isPremium).toList(),
      UserFilter.banned => result.where((u) => u.isBanned).toList(),
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
          UserSearchBar(
            searchQuery: _searchQuery,
            activeFilter: _filter,
            onSearchChanged: (v) => setState(() => _searchQuery = v),
            onFilterChanged: (f) => setState(() => _filter = f),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: usersAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
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
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final user = filtered[index];
                    return UserListTile(
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
