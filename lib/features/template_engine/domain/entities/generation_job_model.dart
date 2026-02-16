import 'package:freezed_annotation/freezed_annotation.dart';

part 'generation_job_model.freezed.dart';
part 'generation_job_model.g.dart';

enum JobStatus { pending, generating, processing, completed, failed }

@freezed
class GenerationJobModel with _$GenerationJobModel {
  const factory GenerationJobModel({
    required String id,
    required String userId,
    required String templateId,
    required String prompt,
    required JobStatus status,
    String? aspectRatio,
    int? imageCount,
    String? providerUsed, // 'kie' or 'gemini'
    String? providerTaskId, // taskId from provider
    List<String>? resultUrls,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? completedAt,
  }) = _GenerationJobModel;

  factory GenerationJobModel.fromJson(Map<String, dynamic> json) =>
      _$GenerationJobModelFromJson(_normalizeJson(json));

  static Map<String, dynamic> _normalizeJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);

    normalized['userId'] ??= json['user_id'];
    normalized['templateId'] ??= json['template_id'];
    normalized['aspectRatio'] ??= json['aspect_ratio'];
    normalized['imageCount'] ??= json['image_count'];
    normalized['providerUsed'] ??= json['provider_used'];
    normalized['providerTaskId'] ??= json['provider_task_id'];
    normalized['resultUrls'] ??= json['result_urls'];
    normalized['errorMessage'] ??= json['error_message'];
    normalized['createdAt'] ??= json['created_at'];
    normalized['completedAt'] ??= json['completed_at'];

    return normalized;
  }
}
