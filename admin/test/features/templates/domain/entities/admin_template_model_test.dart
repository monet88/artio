import 'package:artio_admin/features/templates/domain/entities/admin_template_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdminTemplateModel', () {
    group('fromJson', () {
      test('parses sort_order key into order field', () {
        final json = _minimalJson(sortOrder: 7);
        final model = AdminTemplateModel.fromJson(json);
        expect(model.order, 7);
      });

      test('defaults order to 0 when sort_order absent', () {
        final json = _minimalJson();
        json.remove('sort_order');
        final model = AdminTemplateModel.fromJson(json);
        expect(model.order, 0);
      });

      test('parses all required fields', () {
        final json = _fullJson();
        final model = AdminTemplateModel.fromJson(json);

        expect(model.id, 'test-id');
        expect(model.name, 'Test Template');
        expect(model.description, 'A test template');
        expect(model.category, 'Portrait & Face Effects');
        expect(model.promptTemplate, 'Generate {prompt}');
        expect(model.order, 3);
        expect(model.isPremium, true);
        expect(model.isActive, false);
        expect(model.thumbnailUrl, 'https://example.com/thumb.png');
        expect(model.defaultAspectRatio, '16:9');
        expect(model.inputFields, hasLength(1));
      });
    });

    group('toJson', () {
      test('emits sort_order key', () {
        final model = _model(order: 5);
        final json = model.toJson();
        expect(
          json.containsKey('sort_order'),
          isTrue,
          reason: 'toJson must emit sort_order key',
        );
        expect(json['sort_order'], 5);
      });

      test('does NOT emit order key', () {
        final model = _model();
        final json = model.toJson();
        expect(
          json.containsKey('order'),
          isFalse,
          reason: 'toJson must NOT emit order key',
        );
      });
    });

    group('defaults', () {
      test('isPremium defaults to false', () {
        final json = _minimalJson();
        json.remove('is_premium');
        expect(AdminTemplateModel.fromJson(json).isPremium, false);
      });

      test('isActive defaults to true', () {
        final json = _minimalJson();
        json.remove('is_active');
        expect(AdminTemplateModel.fromJson(json).isActive, true);
      });

      test('defaultAspectRatio defaults to 1:1', () {
        final json = _minimalJson();
        json.remove('default_aspect_ratio');
        expect(AdminTemplateModel.fromJson(json).defaultAspectRatio, '1:1');
      });

      test('inputFields defaults to empty list', () {
        final json = _minimalJson();
        json.remove('input_fields');
        expect(AdminTemplateModel.fromJson(json).inputFields, isEmpty);
      });
    });
  });
}

// -- Helpers --

Map<String, dynamic> _minimalJson({int sortOrder = 0}) => {
  'id': 'test-id',
  'name': 'Test',
  'description': 'Desc',
  'category': 'Test',
  'prompt_template': 'Generate {prompt}',
  'sort_order': sortOrder,
};

Map<String, dynamic> _fullJson() => {
  'id': 'test-id',
  'name': 'Test Template',
  'description': 'A test template',
  'category': 'Portrait & Face Effects',
  'prompt_template': 'Generate {prompt}',
  'sort_order': 3,
  'is_premium': true,
  'is_active': false,
  'thumbnail_url': 'https://example.com/thumb.png',
  'default_aspect_ratio': '16:9',
  'input_fields': [
    {'type': 'text', 'name': 'prompt'},
  ],
};

AdminTemplateModel _model({int order = 0}) => AdminTemplateModel(
  id: 'test-id',
  name: 'Test',
  description: 'Desc',
  category: 'Test',
  promptTemplate: 'Generate {prompt}',
  order: order,
);
