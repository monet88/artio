// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generation_options_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GenerationOptionsModelImpl _$$GenerationOptionsModelImplFromJson(
  Map<String, dynamic> json,
) => _$GenerationOptionsModelImpl(
  aspectRatio: json['aspectRatio'] as String? ?? '1:1',
  imageCount: (json['imageCount'] as num?)?.toInt() ?? 1,
  outputFormat: json['outputFormat'] as String? ?? 'jpg',
  modelId: json['modelId'] as String? ?? 'google/imagen4',
  otherIdeas: json['otherIdeas'] as String? ?? '',
);

Map<String, dynamic> _$$GenerationOptionsModelImplToJson(
  _$GenerationOptionsModelImpl instance,
) => <String, dynamic>{
  'aspectRatio': instance.aspectRatio,
  'imageCount': instance.imageCount,
  'outputFormat': instance.outputFormat,
  'modelId': instance.modelId,
  'otherIdeas': instance.otherIdeas,
};
