import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/template_model.dart';
import '../../data/repositories/template_repository.dart';

part 'template_provider.g.dart';

@riverpod
Future<TemplateModel?> templateById(Ref ref, String id) =>
    ref.watch(templateRepositoryProvider).fetchTemplate(id);

@riverpod
Future<List<TemplateModel>> templates(Ref ref) =>
    ref.watch(templateRepositoryProvider).fetchTemplates();

@riverpod
Future<List<TemplateModel>> templatesByCategory(Ref ref, String category) =>
    ref.watch(templateRepositoryProvider).fetchByCategory(category);
