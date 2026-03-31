import 'package:artio_admin/core/theme/admin_colors.dart';
import 'package:artio_admin/core/utils/retry.dart';
import 'package:artio_admin/features/users/domain/entities/admin_user_model.dart';
import 'package:artio_admin/features/users/presentation/widgets/admin_actions_card.dart';
import 'package:artio_admin/features/users/presentation/widgets/recent_jobs_list.dart';
import 'package:artio_admin/features/users/presentation/widgets/user_profile_card.dart';
import 'package:artio_admin/shared/widgets/error_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'user_detail_page.g.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

@riverpod
Future<AdminUserModel> userDetail(Ref ref, String userId) async {
  final data = await retry(
    () => Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single(),
  );
  return AdminUserModel.fromJson(data);
}

@riverpod
Future<int> userGenerationCount(Ref ref, String userId) async {
  final result = await retry(
    () => Supabase.instance.client
        .from('generation_jobs')
        .select('id')
        .eq('user_id', userId),
  ) as List;
  return result.length;
}

@riverpod
Future<List<Map<String, dynamic>>> userRecentJobs(
  Ref ref,
  String userId,
) async {
  final data = await retry(
    () => Supabase.instance.client
        .from('generation_jobs')
        .select('id, status, model_id, created_at, error_message')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(10),
  ) as List;
  return List<Map<String, dynamic>>.from(data);
}

// ── Page ─────────────────────────────────────────────────────────────────────

class UserDetailPage extends ConsumerWidget {
  const UserDetailPage({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userDetailProvider(userId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/users'),
        ),
        title: const Text('User Detail'),
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorStateWidget.fromError(
          error: err,
          message: err.toString(),
          onRetry: () => ref.invalidate(userDetailProvider(userId)),
        ),
        data: (user) => _UserDetailBody(user: user, userId: userId),
      ),
    );
  }
}

// ── Body ─────────────────────────────────────────────────────────────────────

class _UserDetailBody extends ConsumerWidget {
  const _UserDetailBody({required this.user, required this.userId});

  final AdminUserModel user;
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final countAsync = ref.watch(userGenerationCountProvider(userId));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserProfileCard(user: user),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: UserStatCard(
                      label: 'Credits',
                      value: '${user.creditBalance}',
                      icon: Icons.stars_rounded,
                      color: AdminColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: UserStatCard(
                      label: 'Generations',
                      value: countAsync.when(
                        data: (n) => '$n',
                        loading: () => '...',
                        error: (e, _) => '—',
                      ),
                      icon: Icons.image_outlined,
                      color: AdminColors.info,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: UserStatCard(
                      label: 'Joined',
                      value: formatJoinDate(user.createdAt),
                      icon: Icons.calendar_today_outlined,
                      color: AdminColors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Admin Actions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              AdminActionsCard(user: user, userId: userId),
              const SizedBox(height: 24),
              Text(
                'Recent Generations',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              RecentJobsList(userId: userId),
            ],
          ),
        ),
      ),
    );
  }
}
