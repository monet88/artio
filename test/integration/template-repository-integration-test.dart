import 'package:flutter_test/flutter_test.dart';
import 'package:aiart/features/template_engine/data/repositories/template_repository.dart';
import 'package:aiart/features/template_engine/domain/entities/template_model.dart';

import 'supabase_test_setup.dart';

void main() {
  late TemplateRepository repository;

  setUpAll(() async {
    await SupabaseTestSetup.init();
    await SupabaseTestSetup.signInTestUser();
    repository = TemplateRepository(SupabaseTestSetup.client);
  });

  tearDownAll(() async {
    await SupabaseTestSetup.cleanup();
  });

  group('TemplateRepository Integration', () {
    test('fetchTemplates returns active templates ordered by order field', () async {
      final templates = await repository.fetchTemplates();

      expect(templates, isA<List<TemplateModel>>());
      expect(templates, isNotEmpty);

      for (final t in templates) {
        expect(t.isActive, isTrue);
      }

      // Verify ordering
      for (var i = 1; i < templates.length; i++) {
        expect(templates[i].order, greaterThanOrEqualTo(templates[i - 1].order));
      }
    });

    test('fetchTemplate returns single template by id', () async {
      final templates = await repository.fetchTemplates();
      if (templates.isEmpty) return;

      final firstId = templates.first.id;
      final template = await repository.fetchTemplate(firstId);

      expect(template, isNotNull);
      expect(template!.id, equals(firstId));
    });

    test('fetchTemplate returns null for non-existent id', () async {
      final template = await repository.fetchTemplate('non-existent-uuid');

      expect(template, isNull);
    });

    test('fetchByCategory filters by category', () async {
      final allTemplates = await repository.fetchTemplates();
      if (allTemplates.isEmpty) return;

      final category = allTemplates.first.category;
      final filtered = await repository.fetchByCategory(category);

      expect(filtered, isNotEmpty);
      for (final t in filtered) {
        expect(t.category, equals(category));
        expect(t.isActive, isTrue);
      }
    });

    test('watchTemplates emits template list stream', () async {
      final stream = repository.watchTemplates();
      final first = await stream.first;

      expect(first, isA<List<TemplateModel>>());
    });
  });
}
