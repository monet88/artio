import '../entities/generation_job_model.dart';

abstract class IGenerationRepository {
  Future<String> startGeneration({
    required String templateId,
    required String prompt,
    String aspectRatio = '1:1',
    int imageCount = 1,
  });

  Stream<GenerationJobModel> watchJob(String jobId);
  Future<List<GenerationJobModel>> fetchUserJobs({int limit = 20, int offset = 0});
  Future<GenerationJobModel?> fetchJob(String jobId);
}
