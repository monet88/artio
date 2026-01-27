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
      thumbnailUrl: json['thumbnailUrl'] as String,
      category: json['category'] as String,
      promptTemplate: json['promptTemplate'] as String,
      inputFields: (json['inputFields'] as List<dynamic>)
          .map((e) => InputFieldModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      defaultAspectRatio: json['defaultAspectRatio'] as String? ?? '1:1',
      isPremium: json['isPremium'] as bool? ?? false,
      order: (json['order'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$TemplateModelImplToJson(_$TemplateModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'thumbnailUrl': instance.thumbnailUrl,
      'category': instance.category,
      'promptTemplate': instance.promptTemplate,
      'inputFields': instance.inputFields,
      'defaultAspectRatio': instance.defaultAspectRatio,
      'isPremium': instance.isPremium,
      'order': instance.order,
    };
