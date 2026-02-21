import 'package:artio/features/auth/presentation/state/auth_state.dart';
import 'package:artio/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:artio/features/subscription/domain/entities/subscription_package.dart';
import 'package:artio/features/subscription/domain/entities/subscription_status.dart';
import 'package:artio/features/subscription/domain/providers/subscription_repository_provider.dart';
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

  /// Purchase a subscription package and update state.
  Future<void> purchase(SubscriptionPackage package) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(subscriptionRepositoryProvider);
      return repo.purchase(package);
    });
  }

  /// Restore previous purchases and update state.
  Future<void> restore() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(subscriptionRepositoryProvider);
      return repo.restore();
    });
  }
}

/// Provider for available subscription offerings.
@riverpod
Future<List<SubscriptionPackage>> offerings(Ref ref) async {
  final repo = ref.watch(subscriptionRepositoryProvider);
  return repo.getOfferings();
}
