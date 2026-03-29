import 'package:artio_admin/core/theme/admin_colors.dart';
import 'package:artio_admin/core/utils/retry.dart';
import 'package:artio_admin/features/users/domain/entities/admin_user_model.dart';
import 'package:artio_admin/shared/widgets/error_state_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
    final isDark = theme.brightness == Brightness.dark;
    final countAsync = ref.watch(userGenerationCountProvider(userId));
    final jobsAsync = ref.watch(userRecentJobsProvider(userId));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Profile Card ────────────────────────────────────────
              _SectionCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor:
                          AdminColors.accent.withValues(alpha: 0.2),
                      child: Text(
                        (user.displayName ?? user.email)
                            .substring(0, 1)
                            .toUpperCase(),
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
                              color: isDark
                                  ? AdminColors.textMuted
                                  : Colors.grey,
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
              ),
              const SizedBox(height: 16),

              // ── Stats Row ───────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Credits',
                      value: '${user.creditBalance}',
                      icon: Icons.stars_rounded,
                      color: AdminColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Generations',
                      value: countAsync.when(
                        data: (n) => '$n',
                        loading: () => '...',
                        error: (e, st) => '—',
                      ),
                      icon: Icons.image_outlined,
                      color: AdminColors.info,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Joined',
                      value: user.createdAt != null
                          ? DateFormat.yMMMd().format(user.createdAt!)
                          : '—',
                      icon: Icons.calendar_today_outlined,
                      color: AdminColors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Admin Actions ───────────────────────────────────────
              Text(
                'Admin Actions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _AdminActionsCard(user: user, userId: userId),
              const SizedBox(height: 24),

              // ── Recent Jobs ─────────────────────────────────────────
              Text(
                'Recent Generations',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              jobsAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, st) => ErrorStateWidget.fromError(
                  error: e,
                  message: 'Failed to load recent jobs',
                  onRetry: () => ref.invalidate(userRecentJobsProvider(userId)),
                ),
                data: (jobs) => jobs.isEmpty
                    ? Text(
                        'No generations yet',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AdminColors.textMuted
                              : Colors.grey,
                        ),
                      )
                    : Column(
                        children: jobs
                            .map((j) => _JobRow(job: j))
                            .toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Admin Actions Card ────────────────────────────────────────────────────────

class _AdminActionsCard extends ConsumerStatefulWidget {
  const _AdminActionsCard({required this.user, required this.userId});

  final AdminUserModel user;
  final String userId;

  @override
  ConsumerState<_AdminActionsCard> createState() => _AdminActionsCardState();
}

class _AdminActionsCardState extends ConsumerState<_AdminActionsCard> {
  final _creditsController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _creditsController.text = '${widget.user.creditBalance}';
  }

  @override
  void dispose() {
    _creditsController.dispose();
    super.dispose();
  }

  Future<void> _callRpc(String rpcName, Map<String, dynamic> params) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      await Supabase.instance.client.rpc(rpcName, params: params);
      if (!mounted) return;
      // Refresh user detail
      ref.invalidate(userDetailProvider(widget.userId));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Updated successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reset Credits
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _creditsController,
                  decoration: const InputDecoration(
                    labelText: 'Set Credits',
                    hintText: 'Enter exact amount',
                    suffixText: 'credits',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.tonal(
                onPressed: _isSaving
                    ? null
                    : () {
                        final amount =
                            int.tryParse(_creditsController.text);
                        if (amount == null || amount < 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Enter a valid number ≥ 0'),
                            ),
                          );
                          return;
                        }
                        _callRpc('admin_set_credits', {
                          'p_user_id': widget.userId,
                          'p_amount': amount,
                        });
                      },
                child: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Set'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Toggle Premium
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Premium Access',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      widget.user.isPremium
                          ? 'Currently: ${widget.user.tierBadgeLabel}'
                          : 'Currently: Free',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Switch(
                value: widget.user.isPremium,
                onChanged: _isSaving
                    ? null
                    : (v) => _callRpc('admin_set_premium', {
                          'p_user_id': widget.userId,
                          'p_is_premium': v,
                        }),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Ban / Unban
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Banned',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: widget.user.isBanned
                            ? AdminColors.error
                            : null,
                      ),
                    ),
                    Text(
                      widget.user.isBanned
                          ? 'User is banned'
                          : 'User is active',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Switch(
                value: widget.user.isBanned,
                activeThumbColor: AdminColors.error,
                onChanged: _isSaving
                    ? null
                    : (v) => _callRpc('admin_set_banned', {
                          'p_user_id': widget.userId,
                          'p_is_banned': v,
                        }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Shared Widgets ────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AdminColors.surfaceContainer
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AdminColors.borderSubtle : Colors.grey.shade200,
        ),
      ),
      child: child,
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

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
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

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

class _JobRow extends StatelessWidget {
  const _JobRow({required this.job});

  final Map<String, dynamic> job;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final status = job['status'] as String? ?? 'unknown';
    final statusColor = switch (status) {
      'done' => AdminColors.success,
      'failed' => AdminColors.error,
      'generating' => AdminColors.info,
      _ => AdminColors.textMuted,
    };
    final createdAt = job['created_at'] as String?;
    final dateText = createdAt != null
        ? DateFormat.yMMMd().add_Hm().format(DateTime.parse(createdAt))
        : '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              job['model_id'] as String? ?? '—',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            dateText,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isDark ? AdminColors.textMuted : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
