import 'dart:convert';

import 'package:artio/core/config/sentry_config.dart';

import 'package:artio/core/constants/app_constants.dart';
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
      final data = await _supabase.from('user_credits').select().single();
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
            return CreditBalance(
              userId: '',
              balance: 0,
              updatedAt: DateTime.now(),
            );
          }
          return CreditBalance.fromJson(rows.first);
        })
        .handleError((Object error, StackTrace stackTrace) {
          SentryConfig.captureException(error, stackTrace: stackTrace);
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

  @override
  Future<String> requestAdNonce() async {
    try {
      final response = await _supabase.functions.invoke(
        'reward-ad',
        queryParameters: {'action': 'request-nonce'},
      );

      if (response.status == 429) {
        throw const AppException.payment(
          message:
              'Daily ad limit reached '
              '(${AppConstants.dailyAdLimit}/day)',
          code: 'daily_limit_reached',
        );
      }

      final data = response.data is String
          ? jsonDecode(response.data as String) as Map<String, dynamic>
          : response.data as Map<String, dynamic>;

      if (data['success'] != true) {
        throw AppException.network(
          message: data['message'] as String? ?? 'Failed to get nonce',
          statusCode: response.status,
        );
      }

      return data['nonce'] as String;
    } on FunctionException catch (e) {
      if (e.status == 429) {
        throw const AppException.payment(
          message:
              'Daily ad limit reached '
              '(${AppConstants.dailyAdLimit}/day)',
          code: 'daily_limit_reached',
        );
      }
      throw AppException.network(
        message: e.reasonPhrase ?? 'Failed to get nonce',
        statusCode: e.status,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException.unknown(message: e.toString(), originalError: e);
    }
  }

  @override
  Future<({int creditsAwarded, int newBalance, int adsRemaining})>
  rewardAdCredits({required String nonce}) async {
    try {
      final response = await _supabase.functions.invoke(
        'reward-ad',
        queryParameters: {'action': 'claim'},
        body: {'nonce': nonce},
      );

      // Check status codes before parsing body
      if (response.status == 429) {
        throw const AppException.payment(
          message:
              'Daily ad limit reached '
              '(${AppConstants.dailyAdLimit}/day)',
          code: 'daily_limit_reached',
        );
      }

      final data = response.data is String
          ? jsonDecode(response.data as String) as Map<String, dynamic>
          : response.data as Map<String, dynamic>;

      if (data['success'] != true) {
        throw AppException.network(
          message: data['message'] as String? ?? 'Ad reward failed',
          statusCode: response.status,
        );
      }

      return (
        creditsAwarded: data['credits_awarded'] as int,
        newBalance: data['new_balance'] as int,
        adsRemaining: data['ads_remaining'] as int,
      );
    } on FunctionException catch (e) {
      if (e.status == 429) {
        throw const AppException.payment(
          message:
              'Daily ad limit reached '
              '(${AppConstants.dailyAdLimit}/day)',
          code: 'daily_limit_reached',
        );
      }
      throw AppException.network(
        message: e.reasonPhrase ?? 'Ad reward failed',
        statusCode: e.status,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException.unknown(message: e.toString(), originalError: e);
    }
  }

  @override
  Future<int> fetchAdsRemainingToday() async {
    try {
      final today = DateTime.now().toUtc().toIso8601String().substring(0, 10);
      final data = await _supabase
          .from('ad_views')
          .select('view_count')
          .eq('view_date', today)
          .maybeSingle();

      if (data == null) return AppConstants.dailyAdLimit;
      return AppConstants.dailyAdLimit - (data['view_count'] as int);
    } on PostgrestException catch (e) {
      throw AppException.network(message: e.message);
    } catch (e) {
      throw AppException.unknown(message: e.toString(), originalError: e);
    }
  }
}
