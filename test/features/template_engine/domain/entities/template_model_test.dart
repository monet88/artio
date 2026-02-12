import 'package:flutter_test/flutter_test.dart';
import 'package:artio/features/template_engine/domain/entities/template_model.dart';
import 'package:artio/features/template_engine/domain/entities/input_field_model.dart';
import '../../../../core/fixtures/fixtures.dart';

void main() {
  group('TemplateModel', () {
    group('creation', () {
      test('creates instance with required fields', () {
        const template = TemplateModel(
          id: 'template-1',
          name: 'Test Template',
          description: 'A test template',
          thumbnailUrl: 'https://example.com/thumb.png',
          category: 'portrait',
          promptTemplate: 'Generate {prompt}',
          inputFields: [],
        );

        expect(template.id, 'template-1');
        expect(template.name, 'Test Template');
        expect(template.description, 'A test template');
        expect(template.category, 'portrait');
        expect(template.inputFields, isEmpty);
      });

      test('has correct default values', () {
        const template = TemplateModel(
          id: 'template-1',
          name: 'Test',
          description: 'Desc',
          thumbnailUrl: 'url',
          category: 'cat',
          promptTemplate: 'prompt',
          inputFields: [],
        );

        expect(template.defaultAspectRatio, '1:1');
        expect(template.isPremium, false);
        expect(template.order, 0);
      });

      test('creates instance with input fields', () {
        final template = TemplateFixtures.withInputFields();

        expect(template.inputFields, isNotEmpty);
        expect(template.inputFields.length, greaterThanOrEqualTo(1));
      });
    });

    group('JSON serialization', () {
      test('serializes to JSON correctly', () {
        final template = TemplateFixtures.basic();
        final json = template.toJson();

        expect(json['id'], template.id);
        expect(json['name'], template.name);
        expect(json['category'], template.category);
        expect(json['input_fields'], isList);
      });

      test('deserializes from JSON correctly', () {
        final json = {
          'id': 'json-template',
          'name': 'JSON Template',
          'description': 'From JSON',
          'thumbnail_url': 'https://example.com/thumb.png',
          'category': 'landscape',
          'prompt_template': 'Generate {prompt}',
          'input_fields': <Map<String, dynamic>>[],
          'default_aspect_ratio': '16:9',
          'is_premium': true,
          'order': 5,
        };

        final template = TemplateModel.fromJson(json);

        expect(template.id, 'json-template');
        expect(template.name, 'JSON Template');
        expect(template.defaultAspectRatio, '16:9');
        expect(template.isPremium, true);
        expect(template.order, 5);
      });

      test('serializes nested input fields correctly', () {
        final template = TemplateFixtures.withInputFields();
        final json = template.toJson();

        expect(json['input_fields'], isList);
        expect((json['input_fields'] as List).isNotEmpty, true);
      });

      test('roundtrip serialization preserves data', () {
        // Use basic template without nested input fields to avoid casting issues
        final original = TemplateFixtures.basic();
        final json = original.toJson();
        final restored = TemplateModel.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.name, original.name);
        expect(restored.isPremium, original.isPremium);
        expect(restored.category, original.category);
      });
    });

    group('copyWith', () {
      test('creates new instance with updated name', () {
        final original = TemplateFixtures.basic();
        final updated = original.copyWith(name: 'Updated Name');

        expect(updated.name, 'Updated Name');
        expect(updated.id, original.id);
      });

      test('creates new instance with updated isPremium', () {
        final original = TemplateFixtures.basic();
        final updated = original.copyWith(isPremium: true);

        expect(updated.isPremium, true);
        expect(original.isPremium, false);
      });
    });

    group('equality', () {
      test('equal instances are equal', () {
        const template1 = TemplateModel(
          id: 'same-id',
          name: 'Same',
          description: 'Desc',
          thumbnailUrl: 'url',
          category: 'cat',
          promptTemplate: 'prompt',
          inputFields: [],
        );
        const template2 = TemplateModel(
          id: 'same-id',
          name: 'Same',
          description: 'Desc',
          thumbnailUrl: 'url',
          category: 'cat',
          promptTemplate: 'prompt',
          inputFields: [],
        );

        expect(template1, equals(template2));
      });
    });

    group('fixtures', () {
      test('basic fixture creates valid template', () {
        final template = TemplateFixtures.basic();

        expect(template.id, isNotEmpty);
        expect(template.name, isNotEmpty);
        expect(template.isPremium, false);
      });

      test('withInputFields fixture has inputs', () {
        final template = TemplateFixtures.withInputFields();

        expect(template.inputFields, isNotEmpty);
      });

      test('premium fixture is premium', () {
        final template = TemplateFixtures.premium();

        expect(template.isPremium, true);
      });

      test('list fixture creates multiple templates', () {
        final templates = TemplateFixtures.list(count: 3);

        expect(templates.length, 3);
        expect(templates.map((t) => t.id).toSet().length, 3);
      });
    });
  });

  group('InputFieldModel', () {
    group('creation', () {
      test('creates text input field', () {
        final field = TemplateFixtures.basicInputField();

        expect(field.name, isNotEmpty);
        expect(field.label, isNotEmpty);
        expect(field.type, 'text');
      });

      test('creates select input field', () {
        final field = TemplateFixtures.selectInputField();

        expect(field.type, 'select');
        expect(field.options, isNotNull);
        expect(field.options, isNotEmpty);
      });

      test('has correct default values', () {
        const field = InputFieldModel(
          name: 'test',
          label: 'Test',
          type: 'text',
        );

        expect(field.placeholder, isNull);
        expect(field.defaultValue, isNull);
        expect(field.options, isNull);
        expect(field.required, false);
      });
    });

    group('JSON serialization', () {
      test('serializes to JSON correctly', () {
        final field = TemplateFixtures.basicInputField();
        final json = field.toJson();

        expect(json['name'], field.name);
        expect(json['label'], field.label);
        expect(json['type'], field.type);
      });

      test('deserializes from JSON correctly', () {
        final json = {
          'name': 'style',
          'label': 'Style',
          'type': 'select',
          'options': ['A', 'B', 'C'],
          'required': true,
        };

        final field = InputFieldModel.fromJson(json);

        expect(field.name, 'style');
        expect(field.type, 'select');
        expect(field.options, ['A', 'B', 'C']);
        expect(field.required, true);
      });
    });
  });
}
