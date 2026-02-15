// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_form_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateFormStateImpl _$$CreateFormStateImplFromJson(
  Map<String, dynamic> json,
) => _$CreateFormStateImpl(
  prompt: json['prompt'] as String? ?? '',
  negativePrompt: json['negativePrompt'] as String? ?? '',
  aspectRatio: json['aspectRatio'] as String? ?? '1:1',
  imageCount: (json['imageCount'] as num?)?.toInt() ?? 1,
  outputFormat: json['outputFormat'] as String? ?? 'jpg',
  modelId: json['modelId'] as String? ?? 'google/imagen4',
);

Map<String, dynamic> _$$CreateFormStateImplToJson(
  _$CreateFormStateImpl instance,
) => <String, dynamic>{
  'prompt': instance.prompt,
  'negativePrompt': instance.negativePrompt,
  'aspectRatio': instance.aspectRatio,
  'imageCount': instance.imageCount,
  'outputFormat': instance.outputFormat,
  'modelId': instance.modelId,
};
