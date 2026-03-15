import 'dart:async';

import 'package:artio/core/providers/supabase_provider.dart';
import 'package:artio/core/state/credit_balance_state_provider.dart';
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
      // Non-blocking: sync runs in background so success state shows immediately.
      // User has already been charged — don't make them wait for edge function.
      unawaited(_syncToSupabase());
      return result;
    });
    // Schedule a credit balance refresh — actual new credits will appear once
    // _syncToSupabase() completes. This preemptive invalidation handles any
    // Realtime delay.
    if (state.hasValue) {
      ref.invalidate(creditBalanceNotifierProvider);
    }
  }

  /// Restore previous purchases, sync to Supabase, and update state.
  Future<void> restore() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(subscriptionRepositoryProvider);
      final result = await repo.restore();
      unawaited(_syncToSupabase());
      return result;
    });
    if (state.hasValue) {
      ref.invalidate(creditBalanceNotifierProvider);
    }
  }

  /// Call sync-subscription edge function then refresh auth state.
  /// Non-blocking: errors are logged but never surface to user.
  Future<void> _syncToSupabase() async {
    try {
      final supabase = ref.read(supabaseClientProvider);
      final response = await supabase.functions.invoke('sync-subscription');
      final body = response.data as Map<String, dynamic>?;
      if (body?['synced'] == false) {
        Log.w(
          '[Subscription] sync skipped: ${body?['reason']} — ${body?['message']}',
        );
      } else {
        Log.i(
          '[Subscription] sync OK: tier=${body?['tier']}, is_premium=${body?['is_premium']}',
        );
      }
    } on Object catch (e) {
      Log.w('[Subscription] sync-subscription failed (non-blocking): $e');
    } finally {
      // Refresh auth + credit balance after sync so UI reflects new tier and credits.
      ref
        ..invalidate(authViewModelProvider)
        ..invalidate(creditBalanceNotifierProvider);
    }
  }
}

/// Provider for available subscription offerings.
@riverpod
Future<List<SubscriptionPackage>> offerings(Ref ref) async {
  final repo = ref.watch(subscriptionRepositoryProvider);
  return repo.getOfferings();
}
