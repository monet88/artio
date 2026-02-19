import 'package:artio/features/template_engine/domain/entities/template_model.dart';

abstract class ITemplateRepository {
  Future<List<TemplateModel>> fetchTemplates();
  Future<List<TemplateModel>> refreshTemplates();
  Future<TemplateModel?> fetchTemplate(String id);
  Future<List<TemplateModel>> fetchByCategory(String category);
  Stream<List<TemplateModel>> watchTemplates();
}
