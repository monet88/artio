import '../entities/template_model.dart';

abstract class ITemplateRepository {
  Future<List<TemplateModel>> fetchTemplates();
  Future<TemplateModel?> fetchTemplate(String id);
  Future<List<TemplateModel>> fetchByCategory(String category);
  Stream<List<TemplateModel>> watchTemplates();
}
