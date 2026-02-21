import 'package:artio/features/template_engine/domain/entities/generation_job_model.dart';

/// Test data factories for [GenerationJobModel]
class GenerationJobFixtures {
  /// Creates a pending job
  static GenerationJobModel pending({
    String? id,
    String? userId,
    String? templateId,
    String? prompt,
  }) => GenerationJobModel(
    id: id ?? 'job-${DateTime.now().millisecondsSinceEpoch}',
    userId: userId ?? 'user-123',
    templateId: templateId ?? 'template-456',
    prompt: prompt ?? 'A beautiful sunset',
    status: JobStatus.pending,
    createdAt: DateTime.now(),
  );

  /// Creates a job in generating status
  static GenerationJobModel generating({
    String? id,
    String? userId,
    String? templateId,
    String? prompt,
  }) => GenerationJobModel(
    id: id ?? 'job-${DateTime.now().millisecondsSinceEpoch}',
    userId: userId ?? 'user-123',
    templateId: templateId ?? 'template-456',
    prompt: prompt ?? 'A beautiful sunset',
    status: JobStatus.generating,
    aspectRatio: '1:1',
    imageCount: 1,
    providerUsed: 'kie',
    providerTaskId: 'task-${DateTime.now().millisecondsSinceEpoch}',
    createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
  );

  /// Creates a job in processing status
  static GenerationJobModel processing({
    String? id,
    String? userId,
    String? templateId,
    String? prompt,
  }) => GenerationJobModel(
    id: id ?? 'job-${DateTime.now().millisecondsSinceEpoch}',
    userId: userId ?? 'user-123',
    templateId: templateId ?? 'template-456',
    prompt: prompt ?? 'A beautiful sunset',
    status: JobStatus.processing,
    aspectRatio: '1:1',
    imageCount: 1,
    providerUsed: 'kie',
    providerTaskId: 'task-${DateTime.now().millisecondsSinceEpoch}',
    createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
  );

  /// Creates a completed job with results
  static GenerationJobModel completed({
    String? id,
    String? userId,
    String? templateId,
    String? prompt,
    List<String>? resultUrls,
  }) => GenerationJobModel(
    id: id ?? 'job-${DateTime.now().millisecondsSinceEpoch}',
    userId: userId ?? 'user-123',
    templateId: templateId ?? 'template-456',
    prompt: prompt ?? 'A beautiful sunset',
    status: JobStatus.completed,
    aspectRatio: '1:1',
    imageCount: 1,
    providerUsed: 'kie',
    providerTaskId: 'task-${DateTime.now().millisecondsSinceEpoch}',
    resultUrls:
        resultUrls ??
        [
          'https://storage.example.com/results/image-${DateTime.now().millisecondsSinceEpoch}.png',
        ],
    createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    completedAt: DateTime.now(),
  );

  /// Creates a failed job
  static GenerationJobModel failed({
    String? id,
    String? userId,
    String? templateId,
    String? prompt,
    String? errorMessage,
  }) => GenerationJobModel(
    id: id ?? 'job-${DateTime.now().millisecondsSinceEpoch}',
    userId: userId ?? 'user-123',
    templateId: templateId ?? 'template-456',
    prompt: prompt ?? 'A beautiful sunset',
    status: JobStatus.failed,
    errorMessage: errorMessage ?? 'Generation failed: Internal server error',
    createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
  );

  /// Creates a list of jobs with various statuses
  static List<GenerationJobModel> list({int count = 5}) =>
      List.generate(count, (i) {
        switch (i % 5) {
          case 0:
            return GenerationJobFixtures.pending(id: 'job-$i');
          case 1:
            return GenerationJobFixtures.generating(id: 'job-$i');
          case 2:
            return GenerationJobFixtures.processing(id: 'job-$i');
          case 3:
            return GenerationJobFixtures.completed(id: 'job-$i');
          case 4:
          default:
            return GenerationJobFixtures.failed(id: 'job-$i');
        }
      });
}
