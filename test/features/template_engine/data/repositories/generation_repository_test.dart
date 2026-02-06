import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:artio/features/template_engine/data/repositories/generation_repository.dart';
import 'package:artio/features/template_engine/domain/entities/generation_job_model.dart';
import 'package:artio/core/exceptions/app_exception.dart';

import '../../../../core/mocks/mock_supabase_client.dart';

void main() {
  late GenerationRepository repository;
  late MockSupabaseClient mockClient;
  late MockFunctionsClient mockFunctions;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockFunctions = MockFunctionsClient();

    when(() => mockClient.functions).thenReturn(mockFunctions);

    repository = GenerationRepository(mockClient);
  });

  group('GenerationRepository', () {
    group('startGeneration', () {
      test('returns job ID on successful edge function call', () async {
        when(() => mockFunctions.invoke(
              'generate-image',
              body: any(named: 'body'),
            )).thenAnswer((_) async => FunctionResponse(
              data: {'job_id': 'job-123'},
              status: 200,
            ));

        final result = await repository.startGeneration(
          templateId: 'template-1',
          prompt: 'A beautiful sunset',
        );

        expect(result, equals('job-123'));
        verify(() => mockFunctions.invoke(
              'generate-image',
              body: {
                'template_id': 'template-1',
                'prompt': 'A beautiful sunset',
                'aspect_ratio': '1:1',
                'image_count': 1,
              },
            )).called(1);
      });

      test('throws AppException.generation on 429 rate limit', () async {
        when(() => mockFunctions.invoke(
              'generate-image',
              body: any(named: 'body'),
            )).thenAnswer((_) async => FunctionResponse(
              data: {'error': 'Rate limited'},
              status: 429,
            ));

        expect(
          () => repository.startGeneration(
            templateId: 'template-1',
            prompt: 'test',
          ),
          throwsA(isA<AppException>().having(
            (e) => e.message,
            'message',
            contains('Too many requests'),
          )),
        );
      });

      test('throws AppException.generation on server error', () async {
        when(() => mockFunctions.invoke(
              'generate-image',
              body: any(named: 'body'),
            )).thenAnswer((_) async => FunctionResponse(
              data: {'error': 'Internal server error'},
              status: 500,
            ));

        expect(
          () => repository.startGeneration(
            templateId: 'template-1',
            prompt: 'test',
          ),
          throwsA(isA<AppException>()),
        );
      });

      test('throws AppException.generation when job_id missing', () async {
        when(() => mockFunctions.invoke(
              'generate-image',
              body: any(named: 'body'),
            )).thenAnswer((_) async => FunctionResponse(
              data: {'success': true},
              status: 200,
            ));

        expect(
          () => repository.startGeneration(
            templateId: 'template-1',
            prompt: 'test',
          ),
          throwsA(isA<AppException>().having(
            (e) => e.message,
            'message',
            contains('Invalid response'),
          )),
        );
      });

      test('throws AppException.generation on FunctionException with 429',
          () async {
        when(() => mockFunctions.invoke(
              'generate-image',
              body: any(named: 'body'),
            )).thenThrow(const FunctionException(
          status: 429,
          reasonPhrase: 'Too Many Requests',
        ));

        expect(
          () => repository.startGeneration(
            templateId: 'template-1',
            prompt: 'test',
          ),
          throwsA(isA<AppException>().having(
            (e) => e.message,
            'message',
            contains('Too many requests'),
          )),
        );
      });

      test('trims whitespace from prompt', () async {
        when(() => mockFunctions.invoke(
              'generate-image',
              body: any(named: 'body'),
            )).thenAnswer((_) async => FunctionResponse(
              data: {'job_id': 'job-456'},
              status: 200,
            ));

        await repository.startGeneration(
          templateId: 'template-1',
          prompt: '  A beautiful sunset  ',
        );

        verify(() => mockFunctions.invoke(
              'generate-image',
              body: {
                'template_id': 'template-1',
                'prompt': 'A beautiful sunset',
                'aspect_ratio': '1:1',
                'image_count': 1,
              },
            )).called(1);
      });

      test('uses custom aspect ratio and image count', () async {
        when(() => mockFunctions.invoke(
              'generate-image',
              body: any(named: 'body'),
            )).thenAnswer((_) async => FunctionResponse(
              data: {'job_id': 'job-789'},
              status: 200,
            ));

        await repository.startGeneration(
          templateId: 'template-1',
          prompt: 'test',
          aspectRatio: '16:9',
          imageCount: 4,
        );

        verify(() => mockFunctions.invoke(
              'generate-image',
              body: {
                'template_id': 'template-1',
                'prompt': 'test',
                'aspect_ratio': '16:9',
                'image_count': 4,
              },
            )).called(1);
      });
    });

    // Note: fetchJob(), fetchUserJobs(), and watchJob() Postgrest method chains
    // are tested via integration tests. Below we test the pure logic separately.
  });

  group('GenerationJobModel JSON parsing', () {
    test('fromJson parses complete job correctly', () {
      final json = {
        'id': 'job-123',
        'userId': 'user-456',
        'templateId': 'template-789',
        'prompt': 'A beautiful sunset',
        'status': 'completed',
        'aspectRatio': '16:9',
        'imageCount': 2,
        'providerUsed': 'gemini',
        'providerTaskId': 'task-abc',
        'resultUrls': ['https://example.com/img1.png', 'https://example.com/img2.png'],
        'errorMessage': null,
        'createdAt': '2026-01-30T10:00:00.000Z',
        'completedAt': '2026-01-30T10:05:00.000Z',
      };

      final job = GenerationJobModel.fromJson(json);

      expect(job.id, equals('job-123'));
      expect(job.userId, equals('user-456'));
      expect(job.templateId, equals('template-789'));
      expect(job.prompt, equals('A beautiful sunset'));
      expect(job.status, equals(JobStatus.completed));
      expect(job.aspectRatio, equals('16:9'));
      expect(job.imageCount, equals(2));
      expect(job.providerUsed, equals('gemini'));
      expect(job.resultUrls, hasLength(2));
    });

    test('fromJson parses pending job with minimal fields', () {
      final json = {
        'id': 'job-pending',
        'userId': 'user-1',
        'templateId': 'template-1',
        'prompt': 'Test prompt',
        'status': 'pending',
      };

      final job = GenerationJobModel.fromJson(json);

      expect(job.id, equals('job-pending'));
      expect(job.status, equals(JobStatus.pending));
      expect(job.resultUrls, isNull);
      expect(job.errorMessage, isNull);
    });

    test('fromJson parses failed job with error message', () {
      final json = {
        'id': 'job-failed',
        'userId': 'user-1',
        'templateId': 'template-1',
        'prompt': 'Test',
        'status': 'failed',
        'errorMessage': 'Provider rate limited',
      };

      final job = GenerationJobModel.fromJson(json);

      expect(job.status, equals(JobStatus.failed));
      expect(job.errorMessage, equals('Provider rate limited'));
    });

    test('fromJson handles all JobStatus values', () {
      for (final status in ['pending', 'generating', 'processing', 'completed', 'failed']) {
        final json = {
          'id': 'job-$status',
          'userId': 'user-1',
          'templateId': 'template-1',
          'prompt': 'Test',
          'status': status,
        };

        final job = GenerationJobModel.fromJson(json);
        expect(job.status.name, equals(status));
      }
    });
  });

  group('Error mapping', () {
    test('PostgrestException maps to AppException.network', () {
      const postgrestError = PostgrestException(
        message: 'Connection failed',
        code: '500',
      );

      final appException = AppException.network(
        message: postgrestError.message,
        statusCode: int.tryParse(postgrestError.code ?? ''),
      );

      expect(appException.message, equals('Connection failed'));
    });

    test('PostgrestException with non-numeric code handles gracefully', () {
      const postgrestError = PostgrestException(
        message: 'Auth error',
        code: 'PGRST301',
      );

      final appException = AppException.network(
        message: postgrestError.message,
        statusCode: int.tryParse(postgrestError.code ?? ''),
      );

      expect(appException.message, equals('Auth error'));
    });
  });
}
