import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:artio/features/gallery/domain/repositories/i_gallery_repository.dart';
import 'package:artio/features/gallery/domain/entities/gallery_item.dart';

import '../../../../core/fixtures/gallery_item_fixtures.dart';

// Mock the interface, NOT the implementation
class MockGalleryRepository extends Mock implements IGalleryRepository {}

void main() {
  late MockGalleryRepository mockRepository;

  setUp(() {
    mockRepository = MockGalleryRepository();
  });

  group('IGalleryRepository', () {
    group('fetchGalleryItems', () {
      test('returns list of gallery items', () async {
        final items = GalleryItemFixtures.list(count: 5);

        when(() => mockRepository.fetchGalleryItems(
              limit: 20,
              offset: 0,
              templateId: null,
            )).thenAnswer((_) async => items);

        final result = await mockRepository.fetchGalleryItems(
          limit: 20,
          offset: 0,
        );

        expect(result, hasLength(5));
      });

      test('returns empty list when no items exist', () async {
        when(() => mockRepository.fetchGalleryItems(
              limit: 20,
              offset: 0,
              templateId: null,
            )).thenAnswer((_) async => []);

        final result = await mockRepository.fetchGalleryItems(
          limit: 20,
          offset: 0,
        );

        expect(result, isEmpty);
      });

      test('returns filtered items when templateId provided', () async {
        final filteredItems = [
          GalleryItemFixtures.single(templateId: 'template-1', status: GenerationStatus.completed),
        ];

        when(() => mockRepository.fetchGalleryItems(
              limit: 20,
              offset: 0,
              templateId: 'template-1',
            )).thenAnswer((_) async => filteredItems);

        final result = await mockRepository.fetchGalleryItems(
          limit: 20,
          offset: 0,
          templateId: 'template-1',
        );

        expect(result, hasLength(1));
        expect(result[0].templateId, equals('template-1'));
      });
    });

    group('watchUserImages', () {
      test('emits gallery items stream', () async {
        final controller = StreamController<List<GalleryItem>>();
        final items = GalleryItemFixtures.list(count: 3);

        when(() => mockRepository.watchUserImages(userId: 'user-123'))
            .thenAnswer((_) => controller.stream);

        final stream = mockRepository.watchUserImages(userId: 'user-123');

        controller.add(items);

        await expectLater(
          stream,
          emits(hasLength(3)),
        );

        await controller.close();
      });

      test('emits updated items when new image added', () async {
        final controller = StreamController<List<GalleryItem>>();
        final initialItems = GalleryItemFixtures.list(count: 2);
        final updatedItems = GalleryItemFixtures.list(count: 3);

        when(() => mockRepository.watchUserImages(userId: 'user-123'))
            .thenAnswer((_) => controller.stream);

        final stream = mockRepository.watchUserImages(userId: 'user-123');

        controller.add(initialItems);
        controller.add(updatedItems);

        await expectLater(
          stream,
          emitsInOrder([
            hasLength(2),
            hasLength(3),
          ]),
        );

        await controller.close();
      });
    });

    group('deleteJob', () {
      test('completes without error on success', () async {
        when(() => mockRepository.deleteJob('job-123'))
            .thenAnswer((_) async {});

        await expectLater(
          mockRepository.deleteJob('job-123'),
          completes,
        );

        verify(() => mockRepository.deleteJob('job-123')).called(1);
      });
    });

    group('softDeleteImage', () {
      test('completes without error on success', () async {
        when(() => mockRepository.softDeleteImage('job-123'))
            .thenAnswer((_) async {});

        await expectLater(
          mockRepository.softDeleteImage('job-123'),
          completes,
        );
      });
    });

    group('restoreImage', () {
      test('completes without error on success', () async {
        when(() => mockRepository.restoreImage('job-123'))
            .thenAnswer((_) async {});

        await expectLater(
          mockRepository.restoreImage('job-123'),
          completes,
        );
      });
    });

    group('retryGeneration', () {
      test('completes without error on success', () async {
        when(() => mockRepository.retryGeneration('job-123'))
            .thenAnswer((_) async {});

        await expectLater(
          mockRepository.retryGeneration('job-123'),
          completes,
        );
      });
    });

    group('downloadImage', () {
      test('returns file path on success', () async {
        when(() => mockRepository.downloadImage('https://example.com/image.png'))
            .thenAnswer((_) async => '/path/to/downloaded/image.png');

        final result = await mockRepository.downloadImage(
          'https://example.com/image.png',
        );

        expect(result, contains('image.png'));
      });

      test('throws exception on download failure', () async {
        when(() => mockRepository.downloadImage('https://invalid.url/image.png'))
            .thenThrow(Exception('Failed to download image'));

        expect(
          () => mockRepository.downloadImage('https://invalid.url/image.png'),
          throwsException,
        );
      });
    });

    group('toggleFavorite', () {
      test('completes without error when favoriting', () async {
        when(() => mockRepository.toggleFavorite('item-123', true))
            .thenAnswer((_) async {});

        await expectLater(
          mockRepository.toggleFavorite('item-123', true),
          completes,
        );
      });

      test('completes without error when unfavoriting', () async {
        when(() => mockRepository.toggleFavorite('item-123', false))
            .thenAnswer((_) async {});

        await expectLater(
          mockRepository.toggleFavorite('item-123', false),
          completes,
        );
      });
    });
  });
}
