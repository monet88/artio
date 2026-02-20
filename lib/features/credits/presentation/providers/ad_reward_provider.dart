import 'package:artio/core/exceptions/app_exception.dart';
import 'package:artio/core/providers/supabase_provider.dart';
import 'package:artio/core/services/rewarded_ad_service.dart';
import 'package:artio/features/credits/domain/providers/credit_repository_provider.dart';
import 'package:artio/features/credits/presentation/providers/credit_balance_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ad_reward_provider.g.dart';

/// Manages the nonce-verified ad-watch → server-reward → UI-refresh flow.
///
/// State is the number of ads remaining today (0–10).
///
/// Flow:
/// 1. Request one-time nonce from server (validates daily limit)
/// 2. Set SSV options on ad with nonce as custom_data
/// 3. Show the ad — user must complete it
/// 4. Claim reward with nonce — server validates nonce is valid + unexpired
@riverpod
class AdRewardNotifier extends _$AdRewardNotifier {
  @override
  Future<int> build() async {
    final repo = ref.watch(creditRepositoryProvider);
    return repo.fetchAdsRemainingToday();
  }

  /// Shows a rewarded ad and awards credits on completion.
  ///
  /// Uses 2-step nonce flow for server-side validation.
  /// Returns the reward result on success, or throws on failure.
  Future<({int creditsAwarded, int newBalance, int adsRemaining})>
      watchAdAndReward() async {
    final adService = ref.read(rewardedAdServiceProvider);
    final repo = ref.read(creditRepositoryProvider);

    if (!adService.isAdLoaded) {
      throw const AppException.network(
        message: 'No ad loaded. Please wait and try again.',
      );
    }

    // Step 1: Request nonce from server BEFORE showing ad
    final nonce = await repo.requestAdNonce();

    // Step 2: Set SSV options with nonce as custom_data
    final user = ref.read(supabaseClientProvider).auth.currentUser;
    if (user != null) {
      await adService.setServerSideVerification(
        userId: user.id,
        customData: nonce,
      );
    }

    // Step 3: Show the ad — returns true only if user earned the reward
    final earned = await adService.showAd();
    if (!earned) {
      throw const AppException.network(
        message: 'Ad was dismissed before earning reward.',
      );
    }

    // Step 4: Claim reward with nonce — server validates nonce
    final result = await repo.rewardAdCredits(nonce: nonce);

    // Refresh ads remaining + credit balance
    ref
      ..invalidateSelf()
      ..invalidate(creditBalanceNotifierProvider);

    return result;
  }
}
