import 'package:artio/features/template_engine/domain/entities/input_field_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../core/fixtures/fixtures.dart';

void main() {
  group('InputFieldModel', () {
    group('field types', () {
      test('supports text field with placeholder and default value', () {
        final base = TemplateFixtures.basicInputField();
        final field = base.copyWith(defaultValue: base.name);

        expect(field.type, 'text');
        expect(field.placeholder, isNotEmpty);
        expect(field.defaultValue, base.name);
      });

      test('supports image field without options', () {
        final field = TemplateFixtures.basicInputField(type: 'image');

        expect(field.type, 'image');
        expect(field.options, isNull);
        expect(field.min, isNull);
        expect(field.max, isNull);
      });

      test('supports slider field with bounds', () {
        final base = TemplateFixtures.basicInputField(type: 'slider');
        final min = base.name.length.toDouble();
        final max = (base.label.length + base.name.length).toDouble();
        final field = base.copyWith(min: min, max: max);

        expect(field.type, 'slider');
        expect(field.min, min);
        expect(field.max, max);
        expect(field.min, lessThan(field.max!));
      });

      test('supports toggle field', () {
        final field = TemplateFixtures.basicInputField(type: 'toggle');

        expect(field.type, 'toggle');
        expect(field.required, isTrue);
      });

      test('supports select dropdown default value', () {
        final select = TemplateFixtures.selectInputField();
        final field = select.copyWith(defaultValue: select.options!.first);

        expect(field.type, 'select');
        expect(field.options, isNotEmpty);
        expect(field.options, contains(field.defaultValue));
      });
    });

    group('validation rules', () {
      test('required fields are marked required', () {
        final field = TemplateFixtures.basicInputField();

        expect(field.required, isTrue);
      });

      test('optional select fields are not required', () {
        final field = TemplateFixtures.selectInputField();

        expect(field.required, isFalse);
      });

      test('slider bounds remain consistent', () {
        final base = TemplateFixtures.basicInputField(type: 'slider');
        final min = base.name.length.toDouble();
        final max = (base.label.length + base.name.length).toDouble();
        final field = base.copyWith(min: min, max: max);

        expect(field.min, lessThan(field.max!));
      });
    });

    group('JSON serialization', () {
      test('roundtrip preserves image fields', () {
        final base = TemplateFixtures.basicInputField(type: 'image');
        final original = base.copyWith(defaultValue: base.label);

        final json = original.toJson();
        final restored = InputFieldModel.fromJson(json);

        expect(restored, equals(original));
      });

      test('roundtrip preserves slider fields', () {
        final base = TemplateFixtures.basicInputField(type: 'slider');
        final min = base.name.length.toDouble();
        final max = (base.label.length + base.name.length).toDouble();
        final original = base.copyWith(
          min: min,
          max: max,
          defaultValue: base.name,
        );

        final json = original.toJson();
        final restored = InputFieldModel.fromJson(json);

        expect(restored, equals(original));
      });

      test('roundtrip preserves select options', () {
        final select = TemplateFixtures.selectInputField();
        final original = select.copyWith(defaultValue: select.options!.last);

        final json = original.toJson();
        final restored = InputFieldModel.fromJson(json);

        expect(restored, equals(original));
      });
    });

    group('copyWith', () {
      test('updates fields without mutating base', () {
        final base = TemplateFixtures.basicInputField();
        final updated = base.copyWith(
          label: base.label.toUpperCase(),
          placeholder: base.label,
        );

        expect(updated.label, base.label.toUpperCase());
        expect(updated.placeholder, base.label);
        expect(base.label, isNot(updated.label));
      });
    });

    group('equality', () {
      test('equal instances are equal', () {
        final field1 = TemplateFixtures.basicInputField();
        final field2 = TemplateFixtures.basicInputField();

        expect(field1, equals(field2));
      });

      test('different instances are not equal', () {
        final field1 = TemplateFixtures.basicInputField();
        final field2 = TemplateFixtures.basicInputField(type: 'toggle');

        expect(field1, isNot(equals(field2)));
      });
    });
  });
}
