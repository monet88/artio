import 'package:artio/core/exceptions/app_exception.dart';
import 'package:artio/core/providers/supabase_provider.dart';
import 'package:artio/core/utils/retry.dart';
import 'package:artio/features/template_engine/domain/entities/template_model.dart';
import 'package:artio/features/template_engine/domain/repositories/i_template_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'template_repository.g.dart';

@riverpod
TemplateRepository templateRepository(Ref ref) {
  return TemplateRepository(ref.watch(supabaseClientProvider));
}

class TemplateRepository implements ITemplateRepository {

  const TemplateRepository(this._supabase);
  final SupabaseClient _supabase;

  @override
  Future<List<TemplateModel>> fetchTemplates() async {
    return retry(() async {
      try {
        final response = await _supabase
            .from('templates')
            .select()
            .eq('is_active', true)
            .order('order', ascending: true);

        return response.map(TemplateModel.fromJson).toList();
      } on PostgrestException catch (e) {
        throw AppException.network(message: e.message);
      } catch (e) {
        throw AppException.unknown(message: e.toString(), originalError: e);
      }
    });
  }

  @override
  Future<TemplateModel?> fetchTemplate(String id) async {
    try {
      final response = await _supabase
          .from('templates')
          .select()
          .eq('id', id)
          .maybeSingle();

      return response != null ? TemplateModel.fromJson(response) : null;
    } on PostgrestException catch (e) {
      throw AppException.network(message: e.message);
    } catch (e) {
      throw AppException.unknown(message: e.toString(), originalError: e);
    }
  }

  @override
  Future<List<TemplateModel>> fetchByCategory(String category) async {
    try {
      final response = await _supabase
          .from('templates')
          .select()
          .eq('category', category)
          .eq('is_active', true)
          .order('order', ascending: true);

      return response.map(TemplateModel.fromJson).toList();
    } on PostgrestException catch (e) {
      throw AppException.network(message: e.message);
    } catch (e) {
      throw AppException.unknown(message: e.toString(), originalError: e);
    }
  }

  @override
  Stream<List<TemplateModel>> watchTemplates() {
    return _supabase
        .from('templates')
        .stream(primaryKey: ['id'])
        .order('order', ascending: true)
        .map((data) => data.map(TemplateModel.fromJson).toList());
  }
}
