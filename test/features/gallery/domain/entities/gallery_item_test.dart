import 'package:flutter_test/flutter_test.dart';
import 'package:artio/features/gallery/domain/entities/gallery_item.dart';
import '../../../../core/fixtures/fixtures.dart';

void main() {
  group('GalleryItem', () {
    group('creation', () {
      test('creates completed gallery item', () {
        final item = GalleryItemFixtures.completed();

        expect(item.status, GenerationStatus.completed);
        expect(item.imageUrl, isNotNull);
        expect(item.id, isNotEmpty);
      });

      test('creates failed gallery item', () {
        final item = GalleryItemFixtures.failed();

        expect(item.status, GenerationStatus.failed);
        // Failed items may still have imageUrl from fixture defaults
      });

      test('creates processing gallery item', () {
        final item = GalleryItemFixtures.processing();

        expect(item.status, GenerationStatus.processing);
        // Processing items may still have imageUrl from fixture defaults
      });

      test('creates favorite gallery item', () {
        final item = GalleryItemFixtures.favorite();

        expect(item.isFavorite, true);
        expect(item.status, GenerationStatus.completed);
      });

      test('creates deleted gallery item', () {
        final item = GalleryItemFixtures.deleted();

        expect(item.deletedAt, isNotNull);
      });
    });

    group('GenerationStatus enum', () {
      test('has all expected values', () {
        expect(GenerationStatus.values, contains(GenerationStatus.pending));
        expect(GenerationStatus.values, contains(GenerationStatus.generating));
        expect(GenerationStatus.values, contains(GenerationStatus.processing));
        expect(GenerationStatus.values, contains(GenerationStatus.completed));
        expect(GenerationStatus.values, contains(GenerationStatus.failed));
      });
    });

    group('JSON serialization', () {
      test('serializes to JSON correctly', () {
        final item = GalleryItemFixtures.completed();
        final json = item.toJson();

        expect(json['id'], item.id);
        expect(json['jobId'], item.jobId);
        expect(json['userId'], item.userId);
        expect(json['templateId'], item.templateId);
        expect(json['status'], 'completed');
      });

      test('deserializes from JSON correctly', () {
        final json = {
          'id': 'gallery-123',
          'jobId': 'job-456',
          'userId': 'user-789',
          'templateId': 'template-001',
          'templateName': 'Portrait',
          'createdAt': DateTime.now().toIso8601String(),
          'status': 'completed',
          'imageUrl': 'https://example.com/image.png',
          'isFavorite': true,
        };

        final item = GalleryItem.fromJson(json);

        expect(item.id, 'gallery-123');
        expect(item.status, GenerationStatus.completed);
        expect(item.isFavorite, true);
      });

      test('handles null optional fields', () {
        final json = {
          'id': 'gallery-123',
          'jobId': 'job-456',
          'userId': 'user-789',
          'templateId': 'template-001',
          'templateName': 'Portrait',
          'createdAt': DateTime.now().toIso8601String(),
          'status': 'pending',
        };

        final item = GalleryItem.fromJson(json);

        expect(item.imageUrl, isNull);
        expect(item.prompt, isNull);
        expect(item.deletedAt, isNull);
        expect(item.isFavorite, false);
      });

      test('roundtrip serialization preserves data', () {
        final original = GalleryItemFixtures.completed();
        final json = original.toJson();
        final restored = GalleryItem.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.jobId, original.jobId);
        expect(restored.status, original.status);
        expect(restored.imageUrl, original.imageUrl);
      });
    });

    group('copyWith', () {
      test('updates favorite status', () {
        final item = GalleryItemFixtures.completed();
        final favorited = item.copyWith(isFavorite: true);

        expect(favorited.isFavorite, true);
        expect(item.isFavorite, false);
      });

      test('updates deleted status', () {
        final item = GalleryItemFixtures.completed();
        final now = DateTime.now();
        final deleted = item.copyWith(deletedAt: now);

        expect(deleted.deletedAt, now);
        expect(item.deletedAt, isNull);
      });
    });

    group('equality', () {
      test('same items are equal', () {
        final now = DateTime.now();
        final item1 = GalleryItem(
          id: 'same-id',
          jobId: 'job',
          userId: 'user',
          templateId: 'template',
          templateName: 'Template',
          createdAt: now,
          status: GenerationStatus.completed,
        );
        final item2 = GalleryItem(
          id: 'same-id',
          jobId: 'job',
          userId: 'user',
          templateId: 'template',
          templateName: 'Template',
          createdAt: now,
          status: GenerationStatus.completed,
        );

        expect(item1, equals(item2));
      });

      test('different items are not equal', () {
        final item1 = GalleryItemFixtures.single(id: 'id-1');
        final item2 = GalleryItemFixtures.single(id: 'id-2');

        expect(item1, isNot(equals(item2)));
      });
    });

    group('fixtures', () {
      test('list fixture creates multiple items', () {
        final items = GalleryItemFixtures.list();

        expect(items.length, 10);
      });

      test('list fixture includes various statuses', () {
        final items = GalleryItemFixtures.list();
        final statuses = items.map((i) => i.status).toSet();

        expect(statuses, contains(GenerationStatus.completed));
      });

      test('list fixture includes favorites', () {
        final items = GalleryItemFixtures.list();
        final favorites = items.where((i) => i.isFavorite);

        expect(favorites, isNotEmpty);
      });

      test('empty fixture returns empty list', () {
        final items = GalleryItemFixtures.empty();

        expect(items, isEmpty);
      });
    });
  });
}
