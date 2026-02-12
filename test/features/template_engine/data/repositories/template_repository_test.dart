import 'package:flutter_test/flutter_test.dart';

import 'package:artio/features/template_engine/domain/entities/template_model.dart';

void main() {
  group('TemplateRepository', () {
    // Note: TemplateRepository uses Supabase Postgrest APIs with complex
    // generic type constraints that are difficult to mock with mocktail.
    // The PostgrestBuilder chain (select -> eq -> order) returns types
    // that cannot be easily stubbed without breaking mocktail's type system.
    //
    // Recommended testing approach:
    // 1. Integration tests against a real Supabase instance (preferred)
    // 2. Use a test Supabase project with known test data
    // 3. Test the actual TemplateModel parsing separately

    group('TemplateModel.fromJson', () {
      test('parses valid JSON correctly', () {
        final json = {
          'id': 'template-1',
          'name': 'Anime Style',
          'description': 'Generate anime art',
          'thumbnail_url': 'https://example.com/thumb.png',
          'category': 'portrait',
          'prompt_template': 'Generate {prompt} in anime style',
          'input_fields': <Map<String, dynamic>>[],
          'default_aspect_ratio': '1:1',
          'is_premium': false,
          'order': 1,
        };

        final template = TemplateModel.fromJson(json);

        expect(template.id, equals('template-1'));
        expect(template.name, equals('Anime Style'));
        expect(template.description, equals('Generate anime art'));
        expect(template.category, equals('portrait'));
        expect(template.isPremium, isFalse);
        expect(template.order, equals(1));
      });

      test('uses default values for optional fields', () {
        final json = {
          'id': 'template-2',
          'name': 'Basic',
          'description': 'Basic template',
          'thumbnail_url': 'https://example.com/basic.png',
          'category': 'general',
          'prompt_template': '{prompt}',
          'input_fields': <Map<String, dynamic>>[],
        };

        final template = TemplateModel.fromJson(json);

        expect(template.defaultAspectRatio, equals('1:1'));
        expect(template.isPremium, isFalse);
        expect(template.order, equals(0));
      });

      test('parses input fields correctly', () {
        final json = {
          'id': 'template-3',
          'name': 'With Fields',
          'description': 'Template with inputs',
          'thumbnail_url': 'https://example.com/fields.png',
          'category': 'art',
          'prompt_template': '{prompt} in {style}',
          'input_fields': [
            {
              'name': 'style',
              'label': 'Style',
              'type': 'select',
              'options': ['Anime', 'Realistic'],
              'required': true,
            },
          ],
          'default_aspect_ratio': '16:9',
          'is_premium': true,
          'order': 5,
        };

        final template = TemplateModel.fromJson(json);

        expect(template.inputFields, hasLength(1));
        expect(template.inputFields[0].name, equals('style'));
        expect(template.inputFields[0].type, equals('select'));
        expect(template.inputFields[0].options, contains('Anime'));
        expect(template.isPremium, isTrue);
      });
    });
  });
}
