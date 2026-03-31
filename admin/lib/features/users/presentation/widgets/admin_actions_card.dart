import 'package:artio_admin/core/theme/admin_colors.dart';
import 'package:artio_admin/features/users/domain/entities/admin_user_model.dart';
import 'package:artio_admin/features/users/presentation/widgets/user_profile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Provider import for invalidation — defined in user_detail_page.dart
import 'package:artio_admin/features/users/presentation/pages/user_detail_page.dart'
    show userDetailProvider;

class AdminActionsCard extends ConsumerStatefulWidget {
  const AdminActionsCard({
    super.key,
    required this.user,
    required this.userId,
  });

  final AdminUserModel user;
  final String userId;

  @override
  ConsumerState<AdminActionsCard> createState() => _AdminActionsCardState();
}

class _AdminActionsCardState extends ConsumerState<AdminActionsCard> {
  late final TextEditingController _creditsController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _creditsController =
        TextEditingController(text: '${widget.user.creditBalance}');
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
    return UserDetailSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                        final amount = int.tryParse(_creditsController.text);
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
                        color:
                            widget.user.isBanned ? AdminColors.error : null,
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
