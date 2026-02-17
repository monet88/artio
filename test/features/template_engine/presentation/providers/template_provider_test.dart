import 'package:artio/features/template_engine/data/repositories/template_repository.dart';
import 'package:artio/features/template_engine/presentation/providers/template_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../core/fixtures/fixtures.dart';

// Mock the concrete TemplateRepository class
class MockTemplateRepository extends Mock implements TemplateRepository {}

void main() {
  group('TemplateProvider', () {
    late MockTemplateRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      mockRepository = MockTemplateRepository();
    });

    tearDown(() {
      container.dispose();
    });

    ProviderContainer createContainer() {
      return ProviderContainer(
        overrides: [
          templateRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    }

    group('templatesProvider', () {
      test('returns list of templates on success', () async {
        final templates = TemplateFixtures.list(count: 3);
        when(() => mockRepository.fetchTemplates())
            .thenAnswer((_) async => templates);

        container = createContainer();
        final result = await container.read(templatesProvider.future);

        expect(result.length, 3);
        verify(() => mockRepository.fetchTemplates()).called(1);
      });

      test('returns empty list when no templates', () async {
        when(() => mockRepository.fetchTemplates())
            .thenAnswer((_) async => []);

        container = createContainer();
        final result = await container.read(templatesProvider.future);

        expect(result, isEmpty);
      });

      test('throws exception on error', () async {
        when(() => mockRepository.fetchTemplates())
            .thenThrow(Exception('Network error'));

        container = createContainer();

        expect(
          () => container.read(templatesProvider.future),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('templateByIdProvider', () {
      test('returns template when found', () async {
        final template = TemplateFixtures.basic(id: 'template-123');
        when(() => mockRepository.fetchTemplate('template-123'))
            .thenAnswer((_) async => template);

        container = createContainer();
        final result = await container.read(
          templateByIdProvider('template-123').future,
        );

        expect(result, isNotNull);
        expect(result!.id, 'template-123');
      });

      test('returns null when not found', () async {
        when(() => mockRepository.fetchTemplate('nonexistent'))
            .thenAnswer((_) async => null);

        container = createContainer();
        final result = await container.read(
          templateByIdProvider('nonexistent').future,
        );

        expect(result, isNull);
      });
    });

    group('templatesByCategoryProvider', () {
      test('returns templates filtered by category', () async {
        final templates = TemplateFixtures.list(count: 2);
        when(() => mockRepository.fetchByCategory('portrait'))
            .thenAnswer((_) async => templates);

        container = createContainer();
        final result = await container.read(
          templatesByCategoryProvider('portrait').future,
        );

        expect(result.length, 2);
        verify(() => mockRepository.fetchByCategory('portrait')).called(1);
      });

      test('returns empty list for unknown category', () async {
        when(() => mockRepository.fetchByCategory('unknown'))
            .thenAnswer((_) async => []);

        container = createContainer();
        final result = await container.read(
          templatesByCategoryProvider('unknown').future,
        );

        expect(result, isEmpty);
      });
    });
  });
}
