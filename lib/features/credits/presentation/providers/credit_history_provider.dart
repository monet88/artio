import 'package:artio/features/credits/domain/entities/credit_transaction.dart';
import 'package:artio/features/credits/domain/providers/credit_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'credit_history_provider.g.dart';

const _pageSize = 30;

/// Loads the last [_pageSize] credit transactions.
/// Paginated via [offset].
@riverpod
Future<List<CreditTransaction>> creditHistory(Ref ref, {int offset = 0}) async {
  final repo = ref.watch(creditRepositoryProvider);
  return repo.fetchTransactions(limit: _pageSize, offset: offset);
}
