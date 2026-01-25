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
    List<String>? resultUrls,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? completedAt,
  }) = _GenerationJobModel;

  factory GenerationJobModel.fromJson(Map<String, dynamic> json) =>
      _$GenerationJobModelFromJson(json);
}
