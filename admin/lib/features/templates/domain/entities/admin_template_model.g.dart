// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_template_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AdminTemplateModelImpl _$$AdminTemplateModelImplFromJson(
  Map<String, dynamic> json,
) => _$AdminTemplateModelImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  category: json['category'] as String,
  promptTemplate: json['prompt_template'] as String,
  order: (json['order'] as num).toInt(),
  isPremium: json['is_premium'] as bool? ?? false,
  isActive: json['is_active'] as bool? ?? true,
  thumbnailUrl: json['thumbnail_url'] as String?,
  defaultAspectRatio: json['default_aspect_ratio'] as String? ?? '1:1',
  inputFields:
      (json['input_fields'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ??
      const [],
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$$AdminTemplateModelImplToJson(
  _$AdminTemplateModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'category': instance.category,
  'prompt_template': instance.promptTemplate,
  'order': instance.order,
  'is_premium': instance.isPremium,
  'is_active': instance.isActive,
  'thumbnail_url': instance.thumbnailUrl,
  'default_aspect_ratio': instance.defaultAspectRatio,
  'input_fields': instance.inputFields,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
