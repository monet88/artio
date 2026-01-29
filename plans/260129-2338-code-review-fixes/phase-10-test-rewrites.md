# Phase 10: Test Rewrites

## Parallelization Info

| Property | Value |
|----------|-------|
| Group | E (Tests) |
| Can Run With | Phase 11 |
| Blocked By | Group C (Phases 05-08) |
| Blocks | None |

## File Ownership (Exclusive)

- `test/features/template_engine/data/repositories/generation_repository_test.dart`
- `test/features/template_engine/data/repositories/template_repository_test.dart`

## Priority: MEDIUM

**Issue**: Repository tests mock the interface (`ITemplateRepository`, `IGenerationRepository`) instead of testing the actual implementation. This tests mock behavior, not production code.

## Current State Analysis

Both test files mock the interface instead of testing the implementation:

```dart
// WRONG: Mocks the INTERFACE
class MockTemplateRepository extends Mock implements ITemplateRepository {}

test('returns list of templates', () async {
  when(() => mockRepository.fetchTemplates())
      .thenAnswer((_) async => expectedTemplates);

  final result = await mockRepository.fetchTemplates();  // Calling the MOCK!
  expect(result, hasLength(3));  // Always passes - tests nothing
});
```

## Correct Approach: Unit Tests with Mocked SupabaseClient

Test the **implementation** class by mocking its **dependencies**.

### Rewritten `template_repository_test.dart`

```dart
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:artio/features/template_engine/data/repositories/template_repository.dart';
import 'package:artio/features/template_engine/domain/entities/template_model.dart';
import 'package:artio/exceptions/app_exception.dart';

// Mock Supabase classes
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock
    implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}

class MockPostgrestTransformBuilder extends Mock
    implements PostgrestTransformBuilder<List<Map<String, dynamic>>> {}

void main() {
  late TemplateRepository repository;
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;
  late MockPostgrestTransformBuilder mockTransformBuilder;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();
    mockTransformBuilder = MockPostgrestTransformBuilder();

    when(() => mockClient.from('templates')).thenReturn(mockQueryBuilder);
    repository = TemplateRepository(mockClient);
  });

  group('TemplateRepository', () {
    group('fetchTemplates', () {
      test('returns parsed templates from Supabase response', () async {
        final rawData = [
          {
            'id': 'template-1',
            'name': 'Anime Style',
            'description': 'Generate anime art',
            'category': 'art',
            'prompt_template': 'anime style {subject}',
            'order': 1,
            'is_premium': false,
            'input_fields': [],
          },
        ];

        when(() => mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(() => mockFilterBuilder.order('order', ascending: true))
            .thenReturn(mockTransformBuilder);
        when(() => mockTransformBuilder.then(any()))
            .thenAnswer((_) async => rawData);

        final result = await repository.fetchTemplates();

        expect(result, hasLength(1));
        expect(result[0].id, equals('template-1'));
        expect(result[0].name, equals('Anime Style'));
        verify(() => mockClient.from('templates')).called(1);
      });

      test('returns empty list when no templates exist', () async {
        when(() => mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(() => mockFilterBuilder.order('order', ascending: true))
            .thenReturn(mockTransformBuilder);
        when(() => mockTransformBuilder.then(any()))
            .thenAnswer((_) async => <Map<String, dynamic>>[]);

        final result = await repository.fetchTemplates();

        expect(result, isEmpty);
      });

      test('throws AppException.network on Supabase error', () async {
        when(() => mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(() => mockFilterBuilder.order('order', ascending: true))
            .thenReturn(mockTransformBuilder);
        when(() => mockTransformBuilder.then(any()))
            .thenThrow(PostgrestException(message: 'Connection failed'));

        expect(
          () => repository.fetchTemplates(),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('fetchTemplate', () {
      test('returns template when found', () async {
        final rawData = {
          'id': 'template-123',
          'name': 'Anime Style',
          'description': 'Generate anime art',
          'category': 'art',
          'prompt_template': 'anime style {subject}',
          'order': 1,
          'is_premium': false,
          'input_fields': [],
        };

        when(() => mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(() => mockFilterBuilder.eq('id', 'template-123'))
            .thenReturn(mockFilterBuilder);
        when(() => mockFilterBuilder.maybeSingle())
            .thenAnswer((_) async => rawData);

        final result = await repository.fetchTemplate('template-123');

        expect(result, isNotNull);
        expect(result!.id, equals('template-123'));
      });

      test('returns null when template not found', () async {
        when(() => mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(() => mockFilterBuilder.eq('id', 'nonexistent'))
            .thenReturn(mockFilterBuilder);
        when(() => mockFilterBuilder.maybeSingle())
            .thenAnswer((_) async => null);

        final result = await repository.fetchTemplate('nonexistent');

        expect(result, isNull);
      });
    });
  });
}
```

### Rewritten `generation_repository_test.dart`

```dart
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:artio/features/template_engine/data/repositories/generation_repository.dart';
import 'package:artio/features/template_engine/domain/entities/generation_job_model.dart';
import 'package:artio/exceptions/app_exception.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}
class MockFunctionsClient extends Mock implements FunctionsClient {}

void main() {
  late GenerationRepository repository;
  late MockSupabaseClient mockClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;
  late MockFunctionsClient mockFunctions;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder();
    mockFunctions = MockFunctionsClient();

    when(() => mockClient.from('generation_jobs')).thenReturn(mockQueryBuilder);
    when(() => mockClient.functions).thenReturn(mockFunctions);

    repository = GenerationRepository(mockClient);
  });

  group('GenerationRepository', () {
    group('startGeneration', () {
      test('creates job and invokes edge function', () async {
        when(() => mockQueryBuilder.insert(any()))
            .thenReturn(mockFilterBuilder);
        when(() => mockFilterBuilder.select())
            .thenReturn(mockFilterBuilder);
        when(() => mockFilterBuilder.single())
            .thenAnswer((_) async => {'id': 'job-123', 'status': 'pending'});

        when(() => mockFunctions.invoke(
              'generate-image',
              body: any(named: 'body'),
            )).thenAnswer((_) async => FunctionResponse(
              data: {'success': true},
              status: 200,
            ));

        final result = await repository.startGeneration(
          templateId: 'template-1',
          prompt: 'A beautiful sunset',
        );

        expect(result, equals('job-123'));
        verify(() => mockClient.from('generation_jobs')).called(1);
      });
    });

    group('fetchJob', () {
      test('returns job when found', () async {
        final rawData = {
          'id': 'job-123',
          'status': 'completed',
          'prompt': 'A sunset',
          'image_url': 'https://example.com/image.png',
        };

        when(() => mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(() => mockFilterBuilder.eq('id', 'job-123'))
            .thenReturn(mockFilterBuilder);
        when(() => mockFilterBuilder.maybeSingle())
            .thenAnswer((_) async => rawData);

        final result = await repository.fetchJob('job-123');

        expect(result, isNotNull);
        expect(result!.id, equals('job-123'));
      });

      test('returns null when job not found', () async {
        when(() => mockQueryBuilder.select()).thenReturn(mockFilterBuilder);
        when(() => mockFilterBuilder.eq('id', 'nonexistent'))
            .thenReturn(mockFilterBuilder);
        when(() => mockFilterBuilder.maybeSingle())
            .thenAnswer((_) async => null);

        final result = await repository.fetchJob('nonexistent');

        expect(result, isNull);
      });
    });
  });
}
```

## Key Differences

| Aspect | Original | Fixed |
|--------|----------|-------|
| What's mocked | `ITemplateRepository` interface | `SupabaseClient` dependency |
| Class under test | None (mock only) | `TemplateRepository` implementation |
| What's tested | Mock returns configured value | Repository parsing, error handling |
| Value | Zero | Catches JSON parsing bugs, error mapping |

## Success Criteria

- [ ] Tests verify actual `TemplateRepository` and `GenerationRepository` classes
- [ ] Supabase client is mocked, not the repository interface
- [ ] Tests cover success, empty, and error scenarios
- [ ] All tests pass with `flutter test`

## Test Commands

```bash
flutter test test/features/template_engine/data/repositories/
```
