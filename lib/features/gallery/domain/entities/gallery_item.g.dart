// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GalleryItemImpl _$$GalleryItemImplFromJson(Map<String, dynamic> json) =>
    _$GalleryItemImpl(
      id: json['id'] as String,
      jobId: json['jobId'] as String,
      userId: json['userId'] as String,
      templateId: json['templateId'] as String,
      templateName: json['templateName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: $enumDecode(_$GenerationStatusEnumMap, json['status']),
      imageUrl: json['imageUrl'] as String?,
      prompt: json['prompt'] as String?,
      resultPaths: (json['resultPaths'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );

Map<String, dynamic> _$$GalleryItemImplToJson(_$GalleryItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'jobId': instance.jobId,
      'userId': instance.userId,
      'templateId': instance.templateId,
      'templateName': instance.templateName,
      'createdAt': instance.createdAt.toIso8601String(),
      'status': _$GenerationStatusEnumMap[instance.status]!,
      'imageUrl': instance.imageUrl,
      'prompt': instance.prompt,
      'resultPaths': instance.resultPaths,
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'isFavorite': instance.isFavorite,
    };

const _$GenerationStatusEnumMap = {
  GenerationStatus.pending: 'pending',
  GenerationStatus.generating: 'generating',
  GenerationStatus.processing: 'processing',
  GenerationStatus.completed: 'completed',
  GenerationStatus.failed: 'failed',
};
