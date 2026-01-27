// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generation_job_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GenerationJobModelImpl _$$GenerationJobModelImplFromJson(
  Map<String, dynamic> json,
) => _$GenerationJobModelImpl(
  id: json['id'] as String,
  userId: json['userId'] as String,
  templateId: json['templateId'] as String,
  prompt: json['prompt'] as String,
  status: $enumDecode(_$JobStatusEnumMap, json['status']),
  aspectRatio: json['aspectRatio'] as String?,
  imageCount: (json['imageCount'] as num?)?.toInt(),
  resultUrls: (json['resultUrls'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  errorMessage: json['errorMessage'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
);

Map<String, dynamic> _$$GenerationJobModelImplToJson(
  _$GenerationJobModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'templateId': instance.templateId,
  'prompt': instance.prompt,
  'status': _$JobStatusEnumMap[instance.status]!,
  'aspectRatio': instance.aspectRatio,
  'imageCount': instance.imageCount,
  'resultUrls': instance.resultUrls,
  'errorMessage': instance.errorMessage,
  'createdAt': instance.createdAt?.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
};

const _$JobStatusEnumMap = {
  JobStatus.pending: 'pending',
  JobStatus.generating: 'generating',
  JobStatus.processing: 'processing',
  JobStatus.completed: 'completed',
  JobStatus.failed: 'failed',
};
