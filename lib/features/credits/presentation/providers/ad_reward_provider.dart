import 'package:artio/core/exceptions/app_exception.dart';
import 'package:artio/core/services/rewarded_ad_service.dart';
import 'package:artio/features/credits/domain/providers/credit_repository_provider.dart';
import 'package:artio/features/credits/presentation/providers/credit_balance_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ad_reward_provider.g.dart';

/// Manages the ad-watch → server-reward → UI-refresh flow.
///
/// State is the number of ads remaining today (0–10).
@riverpod
class AdRewardNotifier extends _$AdRewardNotifier {
  @override
  Future<int> build() async {
    final repo = ref.watch(creditRepositoryProvider);
    return repo.fetchAdsRemainingToday();
  }

  /// Shows a rewarded ad and awards credits on completion.
  ///
  /// Returns the reward result on success, or throws on failure.
  Future<({int creditsAwarded, int newBalance, int adsRemaining})>
      watchAdAndReward() async {
    final adService = ref.read(rewardedAdServiceProvider);

    if (!adService.isAdLoaded) {
      throw const AppException.network(
        message: 'No ad loaded. Please wait and try again.',
      );
    }

    // Show the ad — returns true only if user earned the reward
    final earned = await adService.showAd();
    if (!earned) {
      throw const AppException.network(
        message: 'Ad was dismissed before earning reward.',
      );
    }

    // Call server to award credits
    final repo = ref.read(creditRepositoryProvider);
    final result = await repo.rewardAdCredits();

    // Refresh ads remaining + credit balance
    ref.invalidateSelf();
    ref.invalidate(creditBalanceNotifierProvider);

    return result;
  }
}
