import 'package:artio/features/credits/domain/entities/credit_balance.dart';
import 'package:artio/features/credits/domain/providers/credit_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'credit_balance_provider.g.dart';

@riverpod
class CreditBalanceNotifier extends _$CreditBalanceNotifier {
  @override
  Stream<CreditBalance> build() {
    final repo = ref.watch(creditRepositoryProvider);
    return repo.watchBalance();
  }

  /// Convenience getter for the current balance value.
  int? get currentBalance => state.valueOrNull?.balance;
}
