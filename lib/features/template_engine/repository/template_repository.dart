import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../exceptions/app_exception.dart';
import '../model/template_model.dart';

part 'template_repository.g.dart';

@riverpod
TemplateRepository templateRepository(Ref ref) => TemplateRepository();

class TemplateRepository {
  final _supabase = Supabase.instance.client;

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

  Stream<List<TemplateModel>> watchTemplates() {
    return _supabase
        .from('templates')
        .stream(primaryKey: ['id'])
        .order('order', ascending: true)
        .map((data) => data.map((e) => TemplateModel.fromJson(e)).toList());
  }
}
