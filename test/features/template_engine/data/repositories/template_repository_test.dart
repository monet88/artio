import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:artio/features/template_engine/domain/repositories/i_template_repository.dart';
import 'package:artio/features/template_engine/domain/entities/template_model.dart';
import 'package:artio/exceptions/app_exception.dart';

import '../../../../core/fixtures/template_fixtures.dart';

// Mock the interface, NOT the implementation
class MockTemplateRepository extends Mock implements ITemplateRepository {}

void main() {
  late MockTemplateRepository mockRepository;

  setUp(() {
    mockRepository = MockTemplateRepository();
  });

  group('ITemplateRepository', () {
    group('fetchTemplates', () {
      test('returns list of templates on success', () async {
        final expectedTemplates = TemplateFixtures.list(count: 3);

        when(() => mockRepository.fetchTemplates())
            .thenAnswer((_) async => expectedTemplates);

        final result = await mockRepository.fetchTemplates();

        expect(result, hasLength(3));
        expect(result[0].id, equals('template-0'));
        verify(() => mockRepository.fetchTemplates()).called(1);
      });

      test('returns empty list when no templates exist', () async {
        when(() => mockRepository.fetchTemplates())
            .thenAnswer((_) async => []);

        final result = await mockRepository.fetchTemplates();

        expect(result, isEmpty);
      });

      test('throws AppException.network on database error', () async {
        when(() => mockRepository.fetchTemplates()).thenThrow(
          const AppException.network(message: 'Database connection failed'),
        );

        expect(
          () => mockRepository.fetchTemplates(),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('fetchTemplate', () {
      test('returns template when found', () async {
        final expectedTemplate = TemplateFixtures.basic(
          id: 'template-123',
          name: 'Anime Style',
        );

        when(() => mockRepository.fetchTemplate('template-123'))
            .thenAnswer((_) async => expectedTemplate);

        final result = await mockRepository.fetchTemplate('template-123');

        expect(result, isNotNull);
        expect(result!.id, equals('template-123'));
        expect(result.name, equals('Anime Style'));
      });

      test('returns null when template not found', () async {
        when(() => mockRepository.fetchTemplate('nonexistent'))
            .thenAnswer((_) async => null);

        final result = await mockRepository.fetchTemplate('nonexistent');

        expect(result, isNull);
      });

      test('throws AppException on error', () async {
        when(() => mockRepository.fetchTemplate('error-id')).thenThrow(
          const AppException.unknown(message: 'Unexpected error'),
        );

        expect(
          () => mockRepository.fetchTemplate('error-id'),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('fetchByCategory', () {
      test('returns templates filtered by category', () async {
        final portraitTemplates = [
          TemplateFixtures.basic(id: 't1', category: 'portrait'),
          TemplateFixtures.basic(id: 't2', category: 'portrait'),
        ];

        when(() => mockRepository.fetchByCategory('portrait'))
            .thenAnswer((_) async => portraitTemplates);

        final result = await mockRepository.fetchByCategory('portrait');

        expect(result, hasLength(2));
        expect(result.every((t) => t.category == 'portrait'), isTrue);
      });

      test('returns empty list for unknown category', () async {
        when(() => mockRepository.fetchByCategory('unknown'))
            .thenAnswer((_) async => []);

        final result = await mockRepository.fetchByCategory('unknown');

        expect(result, isEmpty);
      });
    });

    group('watchTemplates', () {
      test('emits templates stream', () async {
        final controller = StreamController<List<TemplateModel>>();
        final templates = TemplateFixtures.list(count: 2);

        when(() => mockRepository.watchTemplates())
            .thenAnswer((_) => controller.stream);

        final stream = mockRepository.watchTemplates();

        controller.add(templates);

        await expectLater(
          stream,
          emits(hasLength(2)),
        );

        await controller.close();
      });

      test('emits updated templates when data changes', () async {
        final controller = StreamController<List<TemplateModel>>();
        final initialTemplates = TemplateFixtures.list(count: 2);
        final updatedTemplates = TemplateFixtures.list(count: 4);

        when(() => mockRepository.watchTemplates())
            .thenAnswer((_) => controller.stream);

        final stream = mockRepository.watchTemplates();

        controller.add(initialTemplates);
        controller.add(updatedTemplates);

        await expectLater(
          stream,
          emitsInOrder([
            hasLength(2),
            hasLength(4),
          ]),
        );

        await controller.close();
      });
    });
  });
}
