import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../domain/entities/template_model.dart';
import '../../domain/repositories/i_template_repository.dart';

part 'template_repository.g.dart';

@riverpod
TemplateRepository templateRepository(Ref ref) {
  return TemplateRepository(ref.watch(supabaseClientProvider));
}

class TemplateRepository implements ITemplateRepository {
  final SupabaseClient _supabase;

  const TemplateRepository(this._supabase);

  @override
  Future<List<TemplateModel>> fetchTemplates() async {
    try {
      final response = await _supabase
          .from('templates')
          .select()
          .eq('is_active', true)
          .order('order', ascending: true);

      return response.map((json) => TemplateModel.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw AppException.network(message: e.message, statusCode: int.tryParse(e.code ?? ''));
    } catch (e) {
      throw AppException.unknown(message: e.toString(), originalError: e);
    }
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
      throw AppException.network(message: e.message, statusCode: int.tryParse(e.code ?? ''));
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

      return response.map((json) => TemplateModel.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      throw AppException.network(message: e.message, statusCode: int.tryParse(e.code ?? ''));
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
        .map((data) => data.map((e) => TemplateModel.fromJson(e)).toList());
  }
}
