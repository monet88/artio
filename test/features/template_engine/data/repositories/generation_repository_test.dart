import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:artio/features/template_engine/domain/repositories/i_generation_repository.dart';
import 'package:artio/features/template_engine/domain/entities/generation_job_model.dart';
import 'package:artio/exceptions/app_exception.dart';

import '../../../../core/fixtures/generation_job_fixtures.dart';

// Mock the interface, NOT the implementation
class MockGenerationRepository extends Mock implements IGenerationRepository {}

void main() {
  late MockGenerationRepository mockRepository;

  setUp(() {
    mockRepository = MockGenerationRepository();
  });

  group('IGenerationRepository', () {
    group('startGeneration', () {
      test('returns job ID on success', () async {
        when(() => mockRepository.startGeneration(
              templateId: 'template-1',
              prompt: 'A beautiful sunset',
              aspectRatio: '1:1',
              imageCount: 1,
            )).thenAnswer((_) async => 'job-123');

        final result = await mockRepository.startGeneration(
          templateId: 'template-1',
          prompt: 'A beautiful sunset',
          aspectRatio: '1:1',
          imageCount: 1,
        );

        expect(result, equals('job-123'));
      });

      test('throws AppException.generation on rate limit (429)', () async {
        when(() => mockRepository.startGeneration(
              templateId: any(named: 'templateId'),
              prompt: any(named: 'prompt'),
              aspectRatio: any(named: 'aspectRatio'),
              imageCount: any(named: 'imageCount'),
            )).thenThrow(
          const AppException.generation(
            message: 'Too many requests. Please wait a moment and try again.',
          ),
        );

        expect(
          () => mockRepository.startGeneration(
            templateId: 'template-1',
            prompt: 'test',
          ),
          throwsA(isA<AppException>()),
        );
      });

      test('throws AppException.generation on server error', () async {
        when(() => mockRepository.startGeneration(
              templateId: any(named: 'templateId'),
              prompt: any(named: 'prompt'),
              aspectRatio: any(named: 'aspectRatio'),
              imageCount: any(named: 'imageCount'),
            )).thenThrow(
          const AppException.generation(message: 'Generation failed'),
        );

        expect(
          () => mockRepository.startGeneration(
            templateId: 'template-1',
            prompt: 'test',
          ),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('watchJob', () {
      test('emits job updates', () async {
        final controller = StreamController<GenerationJobModel>();
        final job = GenerationJobFixtures.pending(id: 'job-123');

        when(() => mockRepository.watchJob('job-123'))
            .thenAnswer((_) => controller.stream);

        final stream = mockRepository.watchJob('job-123');

        controller.add(job);

        await expectLater(
          stream,
          emits(isA<GenerationJobModel>().having(
            (j) => j.id,
            'id',
            'job-123',
          )),
        );

        await controller.close();
      });

      test('emits status changes from pending to completed', () async {
        final controller = StreamController<GenerationJobModel>();
        final pendingJob = GenerationJobFixtures.pending(id: 'job-123');
        final processingJob = GenerationJobFixtures.processing(id: 'job-123');
        final completedJob = GenerationJobFixtures.completed(id: 'job-123');

        when(() => mockRepository.watchJob('job-123'))
            .thenAnswer((_) => controller.stream);

        final stream = mockRepository.watchJob('job-123');

        controller.add(pendingJob);
        controller.add(processingJob);
        controller.add(completedJob);

        await expectLater(
          stream,
          emitsInOrder([
            isA<GenerationJobModel>().having((j) => j.status, 'status', JobStatus.pending),
            isA<GenerationJobModel>().having((j) => j.status, 'status', JobStatus.processing),
            isA<GenerationJobModel>().having((j) => j.status, 'status', JobStatus.completed),
          ]),
        );

        await controller.close();
      });
    });

    group('fetchUserJobs', () {
      test('returns list of jobs', () async {
        final jobs = [
          GenerationJobFixtures.completed(id: 'job-1'),
          GenerationJobFixtures.completed(id: 'job-2'),
        ];

        when(() => mockRepository.fetchUserJobs(limit: 20, offset: 0))
            .thenAnswer((_) async => jobs);

        final result = await mockRepository.fetchUserJobs(limit: 20, offset: 0);

        expect(result, hasLength(2));
      });

      test('returns empty list when no jobs exist', () async {
        when(() => mockRepository.fetchUserJobs(limit: 20, offset: 0))
            .thenAnswer((_) async => []);

        final result = await mockRepository.fetchUserJobs(limit: 20, offset: 0);

        expect(result, isEmpty);
      });

      test('throws AppException.network on error', () async {
        when(() => mockRepository.fetchUserJobs(limit: 20, offset: 0))
            .thenThrow(const AppException.network(message: 'Connection failed'));

        expect(
          () => mockRepository.fetchUserJobs(limit: 20, offset: 0),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('fetchJob', () {
      test('returns job when found', () async {
        final job = GenerationJobFixtures.completed(id: 'job-123');

        when(() => mockRepository.fetchJob('job-123'))
            .thenAnswer((_) async => job);

        final result = await mockRepository.fetchJob('job-123');

        expect(result, isNotNull);
        expect(result!.id, equals('job-123'));
      });

      test('returns null when job not found', () async {
        when(() => mockRepository.fetchJob('nonexistent'))
            .thenAnswer((_) async => null);

        final result = await mockRepository.fetchJob('nonexistent');

        expect(result, isNull);
      });
    });
  });
}
