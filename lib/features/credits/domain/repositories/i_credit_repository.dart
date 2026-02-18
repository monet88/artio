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
}
