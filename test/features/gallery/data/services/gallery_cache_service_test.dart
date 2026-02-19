import 'dart:convert';
import 'dart:io';

import 'package:artio/features/gallery/data/services/gallery_cache_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../core/fixtures/gallery_item_fixtures.dart';

void main() {
  late GalleryCacheService service;
  late Directory tempDir;
  late File cacheFile;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('gallery_cache_test_');
    cacheFile = File('${tempDir.path}/gallery_cache.json');
    service = GalleryCacheService.forTesting(tempDir.path);
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('GalleryCacheService', () {
    group('getCachedItems', () {
      test('returns null when no cache file exists', () async {
        final result = await service.getCachedItems();
        expect(result, isNull);
      });

      test('returns cached items after caching', () async {
        final items = GalleryItemFixtures.list(count: 3);

        await service.cacheItems(items);
        final result = await service.getCachedItems();

        expect(result, isNotNull);
        expect(result, hasLength(3));
        expect(result![0].id, equals('gallery-0'));
        expect(result[1].id, equals('gallery-1'));
        expect(result[2].id, equals('gallery-2'));
      });

      test('returns null when cache file is corrupted JSON', () async {
        await cacheFile.writeAsString('not valid json{{{');

        final result = await service.getCachedItems();
        expect(result, isNull);
      });
    });

    group('cacheItems', () {
      test('writes items to JSON file', () async {
        final items = GalleryItemFixtures.list(count: 2);

        await service.cacheItems(items);

        expect(cacheFile.existsSync(), isTrue);
        final data =
            jsonDecode(cacheFile.readAsStringSync()) as Map<String, dynamic>;
        expect(data['cached_at'], isNotNull);
        expect(data['items'], hasLength(2));
      });

      test('preserves all fields through roundtrip', () async {
        final original = GalleryItemFixtures.favorite(id: 'fav-1');

        await service.cacheItems([original]);
        final result = await service.getCachedItems();

        expect(result, hasLength(1));
        final restored = result!.first;
        expect(restored.id, equals('fav-1'));
        expect(restored.isFavorite, isTrue);
        expect(restored.status, equals(original.status));
      });
    });

    group('isCacheValid', () {
      test('returns false when no cache exists', () {
        expect(service.isCacheValid(), isFalse);
      });

      test('returns true immediately after caching', () async {
        await service.cacheItems(GalleryItemFixtures.list(count: 1));
        expect(service.isCacheValid(), isTrue);
      });

      test('returns false with zero-duration maxAge', () async {
        await service.cacheItems(GalleryItemFixtures.list(count: 1));
        expect(service.isCacheValid(maxAge: Duration.zero), isFalse);
      });
    });

    group('clearCache', () {
      test('removes cache file and invalidates', () async {
        await service.cacheItems(GalleryItemFixtures.list(count: 1));
        expect(service.isCacheValid(), isTrue);

        await service.clearCache();

        expect(service.isCacheValid(), isFalse);
        expect(cacheFile.existsSync(), isFalse);
        final result = await service.getCachedItems();
        expect(result, isNull);
      });

      test('does not throw when no cache exists', () async {
        await expectLater(service.clearCache(), completes);
      });
    });
  });
}
