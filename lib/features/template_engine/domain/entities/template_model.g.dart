// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TemplateModelImpl _$$TemplateModelImplFromJson(Map<String, dynamic> json) =>
    _$TemplateModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      thumbnailUrl: json['thumbnail_url'] as String,
      category: json['category'] as String,
      promptTemplate: json['prompt_template'] as String,
      inputFields: (json['input_fields'] as List<dynamic>)
          .map((e) => InputFieldModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      defaultAspectRatio: json['default_aspect_ratio'] as String? ?? '1:1',
      isPremium: json['is_premium'] as bool? ?? false,
      order: (json['order'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$TemplateModelImplToJson(_$TemplateModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'thumbnail_url': instance.thumbnailUrl,
      'category': instance.category,
      'prompt_template': instance.promptTemplate,
      'input_fields': instance.inputFields,
      'default_aspect_ratio': instance.defaultAspectRatio,
      'is_premium': instance.isPremium,
      'order': instance.order,
    };
