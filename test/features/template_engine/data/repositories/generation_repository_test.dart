import 'dart:async';

import 'package:artio/core/exceptions/app_exception.dart';
import 'package:artio/features/template_engine/data/repositories/generation_repository.dart';
import 'package:artio/features/template_engine/domain/entities/generation_job_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/mocks/mock_supabase_client.dart';

/// Fake that resolves to a fixed Map when awaited (via PostgrestBuilder.then).
class _FakePostgrestSingleResponse extends Fake
    implements PostgrestTransformBuilder<Map<String, dynamic>> {
  _FakePostgrestSingleResponse(this._data);
  final Map<String, dynamic> _data;

  @override
  Future<R> then<R>(
    FutureOr<R> Function(Map<String, dynamic>) onValue, {
    Function? onError,
  }) =>
      Future<Map<String, dynamic>>.value(_data)
          .then(onValue, onError: onError);

  @override
  Future<Map<String, dynamic>> catchError(
    Function onError, {
    bool Function(Object)? test,
  }) =>
      Future<Map<String, dynamic>>.value(_data)
          .catchError(onError, test: test);

  @override
  Future<Map<String, dynamic>> whenComplete(
    FutureOr<void> Function() action,
  ) =>
      Future<Map<String, dynamic>>.value(_data).whenComplete(action);

  @override
  Stream<Map<String, dynamic>> asStream() => Stream.value(_data);

  @override
  Future<Map<String, dynamic>> timeout(
    Duration timeLimit, {
    FutureOr<Map<String, dynamic>> Function()? onTimeout,
  }) =>
      Future<Map<String, dynamic>>.value(_data)
          .timeout(timeLimit, onTimeout: onTimeout);
}

void main() {
  late GenerationRepository repository;
  late MockSupabaseClient mockClient;
  late MockFunctionsClient mockFunctions;
  late MockSupabaseStreamFilterBuilder mockStreamFilterBuilder;

  setUpAll(() {
    registerFallbackValue(
      StreamTransformer<List<Map<String, dynamic>>, GenerationJobModel>
          .fromHandlers(),
    );
  });

  setUp(() {
    mockClient = MockSupabaseClient();
    mockFunctions = MockFunctionsClient();
    mockStreamFilterBuilder = MockSupabaseStreamFilterBuilder();

    when(() => mockClient.functions).thenReturn(mockFunctions);

    repository = GenerationRepository(mockClient);
  });

  group('GenerationRepository', () {
    group('startGeneration', () {
      late MockSupabaseQueryBuilder mockJobQueryBuilder;
      late MockPostgrestFilterBuilder<List<Map<String, dynamic>>>
          mockInsertBuilder;

      /// Stubs the DB insert chain:
      /// from('generation_jobs').insert({...}).select('id').single()
      void stubDbInsert({String jobId = 'job-123'}) {
        mockJobQueryBuilder = MockSupabaseQueryBuilder();
        mockInsertBuilder =
            MockPostgrestFilterBuilder<List<Map<String, dynamic>>>();

        when(() => mockClient.from('generation_jobs'))
            .thenAnswer((_) => mockJobQueryBuilder);
        when(() => mockJobQueryBuilder.insert(any()))
            .thenAnswer((_) => mockInsertBuilder);
        when(() => mockInsertBuilder.select(any()))
            .thenAnswer((_) => mockInsertBuilder);
        when(() => mockInsertBuilder.single())
            .thenAnswer((_) => _FakePostgrestSingleResponse({'id': jobId}));
      }

      test('returns job ID from DB insert on success', () async {
        stubDbInsert();
        when(() => mockFunctions.invoke(
              'generate-image',
              body: any(named: 'body'),
            )).thenAnswer((_) async => FunctionResponse(
              data: {'status': 'ok'},
              status: 200,
            ));

        final result = await repository.startGeneration(
          userId: 'test-user-id',
          templateId: 'template-1',
          prompt: 'A beautiful sunset',
        );

        expect(result, equals('job-123'));
        verify(() => mockFunctions.invoke(
              'generate-image',
              body: {
                'jobId': 'job-123',
                'userId': 'test-user-id',
                'template_id': 'template-1',
                'prompt': 'A beautiful sunset',
                'aspect_ratio': '1:1',
                'image_count': 1,
              },
            )).called(1);
      });

      test('throws AppException.network on 429 rate limit', () async {
        stubDbInsert();
        when(() => mockFunctions.invoke(
              'generate-image',
              body: any(named: 'body'),
            )).thenAnswer((_) async => FunctionResponse(
              data: {'error': 'Rate limited'},
              status: 429,
            ));

        expect(
          () => repository.startGeneration(
            userId: 'test-user-id',
            templateId: 'template-1',
            prompt: 'test',
          ),
          throwsA(isA<NetworkException>().having(
            (e) => e.statusCode,
            'statusCode',
            429,
          )),
        );
      });

      test('throws AppException.generation on server error', () async {
        stubDbInsert();
        when(() => mockFunctions.invoke(
              'generate-image',
              body: any(named: 'body'),
            )).thenAnswer((_) async => FunctionResponse(
              data: {'error': 'Internal server error'},
              status: 500,
            ));

        expect(
          () => repository.startGeneration(
            userId: 'test-user-id',
            templateId: 'template-1',
            prompt: 'test',
          ),
          throwsA(isA<AppException>()),
        );
      });

      test('throws AppException.network on FunctionException with 429',
          () async {
        stubDbInsert();
        when(() => mockFunctions.invoke(
              'generate-image',
              body: any(named: 'body'),
            )).thenThrow(const FunctionException(
          status: 429,
          reasonPhrase: 'Too Many Requests',
        ));

        expect(
          () => repository.startGeneration(
            userId: 'test-user-id',
            templateId: 'template-1',
            prompt: 'test',
          ),
          throwsA(isA<NetworkException>().having(
            (e) => e.statusCode,
            'statusCode',
            429,
          )),
        );
      });

      test('throws AppException.network on timeout', () async {
        stubDbInsert();
        when(() => mockFunctions.invoke(
              'generate-image',
              body: any(named: 'body'),
            )).thenThrow(TimeoutException('Timeout'));

        expect(
          () => repository.startGeneration(
            userId: 'test-user-id',
            templateId: 'template-1',
            prompt: 'test',
          ),
          throwsA(isA<NetworkException>().having(
            (e) => e.statusCode,
            'statusCode',
            408,
          )),
        );
      });

      test('trims whitespace from prompt', () async {
        stubDbInsert();
        when(() => mockFunctions.invoke(
              'generate-image',
              body: any(named: 'body'),
            )).thenAnswer((_) async => FunctionResponse(
              data: {'status': 'ok'},
              status: 200,
            ));

        await repository.startGeneration(
          userId: 'test-user-id',
          templateId: 'template-1',
          prompt: '  A beautiful sunset  ',
        );

        verify(() => mockFunctions.invoke(
              'generate-image',
              body: {
                'jobId': 'job-123',
                'userId': 'test-user-id',
                'template_id': 'template-1',
                'prompt': 'A beautiful sunset',
                'aspect_ratio': '1:1',
                'image_count': 1,
              },
            )).called(1);
      });

      test('uses custom aspect ratio and image count', () async {
        stubDbInsert();
        when(() => mockFunctions.invoke(
              'generate-image',
              body: any(named: 'body'),
            )).thenAnswer((_) async => FunctionResponse(
              data: {'status': 'ok'},
              status: 200,
            ));

        await repository.startGeneration(
          userId: 'test-user-id',
          templateId: 'template-1',
          prompt: 'test',
          aspectRatio: '16:9',
          imageCount: 4,
        );

        verify(() => mockFunctions.invoke(
              'generate-image',
              body: {
                'jobId': 'job-123',
                'userId': 'test-user-id',
                'template_id': 'template-1',
                'prompt': 'test',
                'aspect_ratio': '16:9',
                'image_count': 4,
              },
            )).called(1);
      });
    });

    group('watchJob', () {
      test('emits job after empty-stream grace period', () async {
        final controller = StreamController<List<Map<String, dynamic>>>.broadcast();

        final queryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('generation_jobs'))
            .thenAnswer((_) => queryBuilder);

        when(() => queryBuilder.stream(primaryKey: ['id']))
            .thenAnswer((_) => mockStreamFilterBuilder);
        when(() => mockStreamFilterBuilder.eq('id', 'job-1'))
            .thenAnswer((_) => mockStreamFilterBuilder);
        when(
          () => mockStreamFilterBuilder
              .transform<GenerationJobModel>(any()),
        ).thenAnswer((invocation) {
          final transformer = invocation.positionalArguments.first
              as StreamTransformer<List<Map<String, dynamic>>, GenerationJobModel>;
          return controller.stream.transform(transformer);
        });

        final emittedJobs = <GenerationJobModel>[];
        final errors = <Object>[];

        final subscription = repository.watchJob('job-1').listen(
              emittedJobs.add,
              onError: errors.add,
            );

        controller
          ..add([])
          ..add([])
          ..add([
          {
            'id': 'job-1',
            'user_id': 'user-1',
            'template_id': 'free-text',
            'prompt': 'A prompt',
            'status': 'pending',
          }
        ]);

        await Future<void>.delayed(const Duration(milliseconds: 20));

        expect(errors, isEmpty);
        expect(emittedJobs, hasLength(1));
        expect(emittedJobs.first.id, 'job-1');

        await subscription.cancel();
        await controller.close();
      });

      test('throws after max empty events', () async {
        final controller = StreamController<List<Map<String, dynamic>>>.broadcast();

        final queryBuilder = MockSupabaseQueryBuilder();
        when(() => mockClient.from('generation_jobs'))
            .thenAnswer((_) => queryBuilder);

        when(() => queryBuilder.stream(primaryKey: ['id']))
            .thenAnswer((_) => mockStreamFilterBuilder);
        when(() => mockStreamFilterBuilder.eq('id', 'job-1'))
            .thenAnswer((_) => mockStreamFilterBuilder);
        when(
          () => mockStreamFilterBuilder
              .transform<GenerationJobModel>(any()),
        ).thenAnswer((invocation) {
          final transformer = invocation.positionalArguments.first
              as StreamTransformer<List<Map<String, dynamic>>, GenerationJobModel>;
          return controller.stream.transform(transformer);
        });

        final errors = <Object>[];

        final subscription = repository.watchJob('job-1').listen(
              (_) {},
              onError: errors.add,
            );

        controller
          ..add([])
          ..add([])
          ..add([]);

        await Future<void>.delayed(const Duration(milliseconds: 20));

        expect(errors, hasLength(1));
        expect(errors.first, isA<AppException>());

        await subscription.cancel();
        await controller.close();
      });
    });
  });

  group('GenerationJobModel JSON parsing', () {
    test('fromJson parses complete job correctly', () {
      final json = {
        'id': 'job-123',
        'user_id': 'user-456',
        'template_id': 'template-789',
        'prompt': 'A beautiful sunset',
        'status': 'completed',
        'aspect_ratio': '16:9',
        'image_count': 2,
        'provider_used': 'gemini',
        'provider_task_id': 'task-abc',
        'result_urls': ['https://example.com/img1.png', 'https://example.com/img2.png'],
        'error_message': null,
        'created_at': '2026-01-30T10:00:00.000Z',
        'completed_at': '2026-01-30T10:05:00.000Z',
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
        'user_id': 'user-1',
        'template_id': 'template-1',
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
        'user_id': 'user-1',
        'template_id': 'template-1',
        'prompt': 'Test',
        'status': 'failed',
        'error_message': 'Provider rate limited',
      };

      final job = GenerationJobModel.fromJson(json);

      expect(job.status, equals(JobStatus.failed));
      expect(job.errorMessage, equals('Provider rate limited'));
    });

    test('fromJson handles all JobStatus values', () {
      for (final status in ['pending', 'generating', 'processing', 'completed', 'failed']) {
        final json = {
          'id': 'job-$status',
          'user_id': 'user-1',
          'template_id': 'template-1',
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
