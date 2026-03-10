import 'package:artio/core/providers/supabase_provider.dart';
import 'package:artio/features/auth/presentation/state/auth_state.dart';
import 'package:artio/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:artio/features/subscription/domain/entities/subscription_package.dart';
import 'package:artio/features/subscription/domain/entities/subscription_status.dart';
import 'package:artio/features/subscription/domain/providers/subscription_repository_provider.dart';
import 'package:artio/utils/logger_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'subscription_provider.g.dart';

@riverpod
class SubscriptionNotifier extends _$SubscriptionNotifier {
  @override
  Future<SubscriptionStatus> build() async {
    // Admin/DB-premium users bypass RevenueCat and get Ultra status.
    final authState = ref.watch(authViewModelProvider);
    final isDbPremium = switch (authState) {
      AuthStateAuthenticated(user: final u) => u.isPremium,
      _ => false,
    };
    if (isDbPremium) {
      return const SubscriptionStatus(
        tier: SubscriptionTiers.ultra,
        isActive: true,
        willRenew: true,
      );
    }

    final repo = ref.watch(subscriptionRepositoryProvider);
    return repo.getStatus();
  }

  /// Purchase a subscription package, sync to Supabase, and update state.
  Future<void> purchase(SubscriptionPackage package) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(subscriptionRepositoryProvider);
      final result = await repo.purchase(package);
      await _syncToSupabase();
      return result;
    });
  }

  /// Restore previous purchases, sync to Supabase, and update state.
  Future<void> restore() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(subscriptionRepositoryProvider);
      final result = await repo.restore();
      await _syncToSupabase();
      return result;
    });
  }

  /// Call sync-subscription edge function then refresh auth state.
  /// Non-blocking: errors are logged but never surface to user.
  Future<void> _syncToSupabase() async {
    try {
      final supabase = ref.read(supabaseClientProvider);
      await supabase.functions.invoke('sync-subscription');
      // Refresh auth state so UserProfileCard picks up new is_premium from DB.
      ref.invalidate(authViewModelProvider);
    } on Object catch (e) {
      Log.w('sync-subscription failed (non-blocking): $e');
    }
  }
}

/// Provider for available subscription offerings.
@riverpod
Future<List<SubscriptionPackage>> offerings(Ref ref) async {
  final repo = ref.watch(subscriptionRepositoryProvider);
  return repo.getOfferings();
}
