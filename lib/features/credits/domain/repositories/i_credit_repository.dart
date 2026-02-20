import 'package:artio/core/constants/app_constants.dart' show AppConstants;
import 'package:artio/features/credits/domain/entities/credit_balance.dart';
import 'package:artio/features/credits/domain/entities/credit_transaction.dart';

abstract class ICreditRepository {
  /// Fetch current user's credit balance
  Future<CreditBalance> fetchBalance();

  /// Realtime stream of user_credits changes
  Stream<CreditBalance> watchBalance();

  /// Transaction history with pagination
  Future<List<CreditTransaction>> fetchTransactions({
    int limit = 20,
    int offset = 0,
  });

  /// Request a one-time nonce for ad reward claim.
  /// Must be called BEFORE showing the ad.
  Future<String> requestAdNonce();

  /// Claim ad reward using a previously requested nonce.
  /// The nonce must be valid, unexpired (5 min), and unused.
  Future<({int creditsAwarded, int newBalance, int adsRemaining})>
      rewardAdCredits({required String nonce});

  /// Fetch how many ads the user can still watch today.
  /// See [AppConstants.dailyAdLimit] for the maximum.
  Future<int> fetchAdsRemainingToday();
}
