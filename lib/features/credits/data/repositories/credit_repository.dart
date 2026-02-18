import 'package:artio/core/exceptions/app_exception.dart';
import 'package:artio/core/providers/supabase_provider.dart';
import 'package:artio/features/credits/domain/entities/credit_balance.dart';
import 'package:artio/features/credits/domain/entities/credit_transaction.dart';
import 'package:artio/features/credits/domain/repositories/i_credit_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'credit_repository.g.dart';

@riverpod
CreditRepository creditRepository(Ref ref) =>
    CreditRepository(ref.watch(supabaseClientProvider));

class CreditRepository implements ICreditRepository {
  const CreditRepository(this._supabase);
  final SupabaseClient _supabase;

  @override
  Future<CreditBalance> fetchBalance() async {
    try {
      final data = await _supabase
          .from('user_credits')
          .select()
          .single();
      return CreditBalance.fromJson(data);
    } on PostgrestException catch (e) {
      throw AppException.network(message: e.message);
    } catch (e) {
      throw AppException.unknown(message: e.toString(), originalError: e);
    }
  }

  @override
  Stream<CreditBalance> watchBalance() {
    return _supabase
        .from('user_credits')
        .stream(primaryKey: ['user_id'])
        .map((rows) {
      if (rows.isEmpty) {
        throw const AppException.network(message: 'No credit balance found');
      }
      return CreditBalance.fromJson(rows.first);
    });
  }

  @override
  Future<List<CreditTransaction>> fetchTransactions({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final data = await _supabase
          .from('credit_transactions')
          .select()
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      return data.map(CreditTransaction.fromJson).toList();
    } on PostgrestException catch (e) {
      throw AppException.network(message: e.message);
    } catch (e) {
      throw AppException.unknown(message: e.toString(), originalError: e);
    }
  }
}
