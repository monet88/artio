@Tags(['integration'])
library;

import 'package:artio/features/template_engine/domain/entities/template_model.dart';
import 'package:flutter_test/flutter_test.dart';

import 'supabase_test_setup.dart';

/// Integration test to verify 25 seed templates in Supabase.
/// Run: flutter test test/integration/template_seed_test.dart
///
/// Requires .env.test or environment variables with SUPABASE_URL + SUPABASE_ANON_KEY.
void main() {
  late List<TemplateModel> templates;
  final deserializationErrors = <String>[];

  const expectedCategories = [
    'Art Style Transfer',
    'Creative & Fun',
    'Photo Enhancement',
    'Portrait & Face Effects',
    'Removal & Editing',
  ];
  // Minimum count from seed migration. DB may have more templates added via admin.
  const minSeedCount = 25;

  setUpAll(() async {
    await SupabaseTestSetup.init();

    final response = await SupabaseTestSetup.client
        .from('templates')
        .select()
        .eq('is_active', true)
        .order('order', ascending: true);

    templates = [];
    for (final raw in response as List) {
      final json = raw as Map<String, dynamic>;
      try {
        templates.add(TemplateModel.fromJson(json));
      } on Object catch (e) {
        final name = json['name'] ?? json['id'] ?? 'unknown';
        deserializationErrors.add('Template "$name": $e');
      }
    }
  });

  group('Seed templates count', () {
    test('all templates deserialize successfully', () {
      expect(
        deserializationErrors,
        isEmpty,
        reason:
            'Failed to deserialize ${deserializationErrors.length} template(s):\n'
            '  ${deserializationErrors.join('\n  ')}',
      );
    });

    test('has at least $minSeedCount active templates', () {
      final totalFetched = templates.length + deserializationErrors.length;
      expect(
        totalFetched,
        greaterThanOrEqualTo(minSeedCount),
        reason:
            'Expected at least $minSeedCount seed templates, '
            'got $totalFetched ($minSeedCount seeded + admin additions).',
      );
    });

    test('has exactly ${expectedCategories.length} categories', () {
      final categories = templates.map((t) => t.category).toSet();
      // Debug: print actual categories if mismatch
      if (!expectedCategories.every(categories.contains)) {
        fail(
          'Category mismatch.\n'
          '  Expected: $expectedCategories\n'
          '  Actual:   ${categories.toList()..sort()}',
        );
      }
      expect(categories, hasLength(expectedCategories.length));
    });

    test('each category has at least 1 template', () {
      for (final category in expectedCategories) {
        final count = templates.where((t) => t.category == category).length;
        expect(
          count,
          greaterThan(0),
          reason: '$category should have at least 1 template, got $count',
        );
      }
    });
  });

  group('Seed templates data integrity', () {
    test('all templates have non-empty required fields', () {
      for (final t in templates) {
        expect(t.id, isNotEmpty, reason: 'id empty for ${t.name}');
        expect(t.name, isNotEmpty, reason: 'name empty for ${t.id}');
        expect(
          t.description,
          isNotEmpty,
          reason: 'description empty for ${t.name}',
        );
        expect(t.category, isNotEmpty, reason: 'category empty for ${t.name}');
        expect(
          t.promptTemplate,
          isNotEmpty,
          reason: 'promptTemplate empty for ${t.name}',
        );
      }
    });

    test('all templates have valid thumbnailUrl', () {
      for (final t in templates) {
        expect(
          t.thumbnailUrl,
          isNotEmpty,
          reason: 'thumbnailUrl empty for ${t.name}',
        );
        expect(
          Uri.tryParse(t.thumbnailUrl)?.hasScheme ?? false,
          isTrue,
          reason: 'thumbnailUrl invalid for ${t.name}: ${t.thumbnailUrl}',
        );
      }
    });

    test('all templates have at least one input field', () {
      for (final t in templates) {
        expect(
          t.inputFields,
          isNotEmpty,
          reason: '${t.name} has no input fields',
        );
      }
    });

    test('all input fields have valid name, label, and type', () {
      const validTypes = [
        'text',
        'select',
        'slider',
        'toggle',
        'otherIdeas',
        'image',
      ];
      for (final t in templates) {
        for (final field in t.inputFields) {
          expect(
            field.name,
            isNotEmpty,
            reason: 'input field name empty in ${t.name}',
          );
          expect(
            field.label,
            isNotEmpty,
            reason: 'input field label empty in ${t.name}',
          );
          expect(
            validTypes,
            contains(field.type),
            reason:
                'invalid type "${field.type}" for field "${field.name}" in ${t.name}',
          );
        }
      }
    });

    test('promptTemplate contains placeholders matching input fields', () {
      for (final t in templates) {
        final placeholders = RegExp(
          r'\{(\w+)\}',
        ).allMatches(t.promptTemplate).map((m) => m.group(1)).toSet();

        final fieldNames = t.inputFields.map((f) => f.name).toSet();

        for (final placeholder in placeholders) {
          expect(
            fieldNames,
            contains(placeholder),
            reason:
                '${t.name}: placeholder {$placeholder} has no matching input field',
          );
        }
      }
    });

    test('all template IDs are unique', () {
      final ids = templates.map((t) => t.id).toList();
      expect(
        ids.toSet(),
        hasLength(ids.length),
        reason: 'duplicate template IDs found',
      );
    });

    test('order values are non-negative', () {
      for (final t in templates) {
        expect(
          t.order,
          greaterThanOrEqualTo(0),
          reason: '${t.name} has negative order: ${t.order}',
        );
      }
    });
  });
}
