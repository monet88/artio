import 'package:flutter_test/flutter_test.dart';
import 'package:aiart/features/template_engine/data/repositories/generation_repository.dart';
import 'package:aiart/features/template_engine/domain/entities/generation_job_model.dart';

import 'supabase_test_setup.dart';

void main() {
  late GenerationRepository repository;

  setUpAll(() async {
    await SupabaseTestSetup.init();
    await SupabaseTestSetup.signInTestUser();
    repository = GenerationRepository(SupabaseTestSetup.client);
  });

  tearDownAll(() async {
    await SupabaseTestSetup.cleanup();
  });

  group('GenerationRepository Integration', () {
    test('fetchUserJobs returns list of user jobs', () async {
      final jobs = await repository.fetchUserJobs(limit: 10);

      expect(jobs, isA<List<GenerationJobModel>>());
    });

    test('fetchUserJobs respects limit parameter', () async {
      final jobs = await repository.fetchUserJobs(limit: 5);

      expect(jobs.length, lessThanOrEqualTo(5));
    });

    test('fetchUserJobs respects offset parameter', () async {
      final allJobs = await repository.fetchUserJobs(limit: 10, offset: 0);
      if (allJobs.length < 2) {
        markTestSkipped('Requires at least 2 jobs in database to test offset');
        return;
      }

      final offsetJobs = await repository.fetchUserJobs(limit: 10, offset: 1);

      expect(offsetJobs.first.id, equals(allJobs[1].id));
    });

    test('fetchJob returns null for non-existent job', () async {
      final job = await repository.fetchJob('00000000-0000-0000-0000-000000000000');

      expect(job, isNull);
    });

    test('fetchJob returns job by id', () async {
      final jobs = await repository.fetchUserJobs(limit: 1);
      if (jobs.isEmpty) return;

      final job = await repository.fetchJob(jobs.first.id);

      expect(job, isNotNull);
      expect(job!.id, equals(jobs.first.id));
    });

    test('watchJob emits job updates stream', () async {
      final jobs = await repository.fetchUserJobs(limit: 1);
      if (jobs.isEmpty) {
        // Skip if no jobs exist
        return;
      }

      final stream = repository.watchJob(jobs.first.id);
      final first = await stream.first;

      expect(first, isA<GenerationJobModel>());
      expect(first.id, equals(jobs.first.id));
    });
  });
}
