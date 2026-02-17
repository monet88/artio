import 'package:artio/features/template_engine/domain/entities/generation_job_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../core/fixtures/fixtures.dart';

void main() {
  group('GenerationJobModel', () {
    group('creation', () {
      test('creates pending job', () {
        final job = GenerationJobFixtures.pending();

        expect(job.status, JobStatus.pending);
        expect(job.id, isNotEmpty);
        expect(job.userId, isNotEmpty);
        expect(job.templateId, isNotEmpty);
        expect(job.prompt, isNotEmpty);
      });

      test('creates generating job', () {
        final job = GenerationJobFixtures.generating();

        expect(job.status, JobStatus.generating);
        expect(job.providerUsed, isNotNull);
        expect(job.providerTaskId, isNotNull);
      });

      test('creates processing job', () {
        final job = GenerationJobFixtures.processing();

        expect(job.status, JobStatus.processing);
      });

      test('creates completed job with results', () {
        final job = GenerationJobFixtures.completed();

        expect(job.status, JobStatus.completed);
        expect(job.resultUrls, isNotNull);
        expect(job.resultUrls, isNotEmpty);
        expect(job.completedAt, isNotNull);
      });

      test('creates failed job with error', () {
        final job = GenerationJobFixtures.failed();

        expect(job.status, JobStatus.failed);
        expect(job.errorMessage, isNotNull);
        expect(job.errorMessage, isNotEmpty);
      });
    });

    group('JobStatus enum', () {
      test('has all expected values', () {
        expect(JobStatus.values, contains(JobStatus.pending));
        expect(JobStatus.values, contains(JobStatus.generating));
        expect(JobStatus.values, contains(JobStatus.processing));
        expect(JobStatus.values, contains(JobStatus.completed));
        expect(JobStatus.values, contains(JobStatus.failed));
      });

      test('pending is initial state', () {
        final job = GenerationJobFixtures.pending();
        expect(job.status, JobStatus.pending);
      });
    });

    group('JSON serialization', () {
      test('serializes pending job to JSON', () {
        final job = GenerationJobFixtures.pending();
        final json = job.toJson();

        expect(json['id'], job.id);
        expect(json['userId'], job.userId);
        expect(json['templateId'], job.templateId);
        expect(json['prompt'], job.prompt);
        expect(json['status'], 'pending');
      });

      test('serializes completed job to JSON', () {
        final job = GenerationJobFixtures.completed();
        final json = job.toJson();

        expect(json['status'], 'completed');
        expect(json['resultUrls'], isNotNull);
      });

      test('deserializes from JSON correctly', () {
        final json = {
          'id': 'job-123',
          'userId': 'user-456',
          'templateId': 'template-789',
          'prompt': 'A test prompt',
          'status': 'completed',
          'resultUrls': ['https://example.com/result.png'],
        };

        final job = GenerationJobModel.fromJson(json);

        expect(job.id, 'job-123');
        expect(job.status, JobStatus.completed);
        expect(job.resultUrls, isNotNull);
      });

      test('handles null optional fields in JSON', () {
        final json = {
          'id': 'job-123',
          'userId': 'user-456',
          'templateId': 'template-789',
          'prompt': 'A test prompt',
          'status': 'pending',
        };

        final job = GenerationJobModel.fromJson(json);

        expect(job.aspectRatio, isNull);
        expect(job.resultUrls, isNull);
        expect(job.errorMessage, isNull);
      });

      test('roundtrip serialization preserves data', () {
        final original = GenerationJobFixtures.completed();
        final json = original.toJson();
        final restored = GenerationJobModel.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.status, original.status);
        expect(restored.resultUrls, original.resultUrls);
      });
    });

    group('copyWith', () {
      test('updates status', () {
        final pending = GenerationJobFixtures.pending();
        final generating = pending.copyWith(status: JobStatus.generating);

        expect(generating.status, JobStatus.generating);
        expect(pending.status, JobStatus.pending);
      });

      test('adds result URLs', () {
        final processing = GenerationJobFixtures.processing();
        final completed = processing.copyWith(
          status: JobStatus.completed,
          resultUrls: ['https://example.com/result.png'],
        );

        expect(completed.status, JobStatus.completed);
        expect(completed.resultUrls, isNotEmpty);
      });

      test('adds error message', () {
        final processing = GenerationJobFixtures.processing();
        final failed = processing.copyWith(
          status: JobStatus.failed,
          errorMessage: 'Something went wrong',
        );

        expect(failed.status, JobStatus.failed);
        expect(failed.errorMessage, 'Something went wrong');
      });
    });

    group('equality', () {
      test('same jobs are equal', () {
        const job1 = GenerationJobModel(
          id: 'same-id',
          userId: 'user',
          templateId: 'template',
          prompt: 'prompt',
          status: JobStatus.pending,
        );
        const job2 = GenerationJobModel(
          id: 'same-id',
          userId: 'user',
          templateId: 'template',
          prompt: 'prompt',
          status: JobStatus.pending,
        );

        expect(job1, equals(job2));
      });

      test('different jobs are not equal', () {
        final job1 = GenerationJobFixtures.pending(id: 'job-1');
        final job2 = GenerationJobFixtures.pending(id: 'job-2');

        expect(job1, isNot(equals(job2)));
      });
    });

    group('fixtures', () {
      test('list fixture creates jobs with different statuses', () {
        final jobs = GenerationJobFixtures.list();

        expect(jobs.length, 5);
        
        final statuses = jobs.map((j) => j.status).toSet();
        expect(statuses, contains(JobStatus.pending));
        expect(statuses, contains(JobStatus.generating));
        expect(statuses, contains(JobStatus.processing));
        expect(statuses, contains(JobStatus.completed));
        expect(statuses, contains(JobStatus.failed));
      });
    });
  });
}
