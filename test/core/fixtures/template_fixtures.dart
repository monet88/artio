import 'package:artio/features/template_engine/domain/entities/template_model.dart';
import 'package:artio/features/template_engine/domain/entities/input_field_model.dart';

/// Test data factories for [TemplateModel] and [InputFieldModel]
class TemplateFixtures {
  /// Creates a basic input field
  static InputFieldModel basicInputField({
    String? name,
    String? label,
    String? type,
  }) =>
      InputFieldModel(
        name: name ?? 'prompt',
        label: label ?? 'Prompt',
        type: type ?? 'text',
        placeholder: 'Enter your prompt...',
        required: true,
      );

  /// Creates a select input field
  static InputFieldModel selectInputField({
    String? name,
    String? label,
    List<String>? options,
  }) =>
      InputFieldModel(
        name: name ?? 'style',
        label: label ?? 'Style',
        type: 'select',
        options: options ?? const ['Realistic', 'Anime', 'Artistic'],
        required: false,
      );

  /// Creates a basic template without input fields
  static TemplateModel basic({
    String? id,
    String? name,
    String? category,
  }) =>
      TemplateModel(
        id: id ?? 'template-${DateTime.now().millisecondsSinceEpoch}',
        name: name ?? 'Basic Template',
        description: 'A basic template for testing',
        thumbnailUrl: 'https://example.com/thumb.png',
        category: category ?? 'general',
        promptTemplate: 'Generate {prompt}',
        inputFields: const [],
        defaultAspectRatio: '1:1',
        isPremium: false,
      );

  /// Creates a template with input fields
  static TemplateModel withInputFields({
    String? id,
    String? name,
    List<InputFieldModel>? inputFields,
  }) =>
      TemplateModel(
        id: id ?? 'template-${DateTime.now().millisecondsSinceEpoch}',
        name: name ?? 'Template with Inputs',
        description: 'A template with configurable input fields',
        thumbnailUrl: 'https://example.com/thumb.png',
        category: 'portrait',
        promptTemplate: 'Generate {prompt} in {style} style',
        inputFields: inputFields ?? [
          TemplateFixtures.basicInputField(),
          TemplateFixtures.selectInputField(),
        ],
        defaultAspectRatio: '1:1',
        isPremium: false,
      );

  /// Creates a premium template
  static TemplateModel premium({
    String? id,
    String? name,
  }) =>
      TemplateModel(
        id: id ?? 'template-${DateTime.now().millisecondsSinceEpoch}',
        name: name ?? 'Premium Template',
        description: 'A premium template with advanced features',
        thumbnailUrl: 'https://example.com/premium-thumb.png',
        category: 'artistic',
        promptTemplate: 'Advanced generation: {prompt}',
        inputFields: [
          TemplateFixtures.basicInputField(),
          TemplateFixtures.selectInputField(),
          InputFieldModel(
            name: 'quality',
            label: 'Quality',
            type: 'select',
            options: const ['Standard', 'HD', '4K'],
            required: false,
          ),
        ],
        defaultAspectRatio: '16:9',
        isPremium: true,
      );

  /// Creates a list of templates
  static List<TemplateModel> list({int count = 5}) => List.generate(
        count,
        (i) => TemplateFixtures.basic(
          id: 'template-$i',
          name: 'Template $i',
          category: i % 2 == 0 ? 'portrait' : 'landscape',
        ),
      );
}
