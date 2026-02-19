import 'dart:convert';
import 'dart:io';

import 'package:artio/features/template_engine/data/services/template_cache_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../core/fixtures/template_fixtures.dart';

void main() {
  late TemplateCacheService service;
  late Directory tempDir;
  late File cacheFile;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('template_cache_test_');
    cacheFile = File('${tempDir.path}/templates_cache.json');
    service = TemplateCacheService.forTesting(tempDir.path);
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('TemplateCacheService', () {
    group('getCachedTemplates', () {
      test('returns null when no cache file exists', () async {
        final result = await service.getCachedTemplates();
        expect(result, isNull);
      });

      test('returns cached templates after caching', () async {
        final templates = TemplateFixtures.list(count: 3);

        await service.cacheTemplates(templates);
        final result = await service.getCachedTemplates();

        expect(result, isNotNull);
        expect(result, hasLength(3));
        expect(result![0].id, equals('template-0'));
        expect(result[1].id, equals('template-1'));
        expect(result[2].id, equals('template-2'));
      });

      test('returns null when cache file is corrupted JSON', () async {
        await cacheFile.writeAsString('not valid json{{{');

        final result = await service.getCachedTemplates();
        expect(result, isNull);
      });
    });

    group('cacheTemplates', () {
      test('writes templates to JSON file', () async {
        final templates = TemplateFixtures.list(count: 2);

        await service.cacheTemplates(templates);

        expect(cacheFile.existsSync(), isTrue);
        final data =
            jsonDecode(cacheFile.readAsStringSync()) as Map<String, dynamic>;
        expect(data['cached_at'], isNotNull);
        expect(data['templates'], hasLength(2));
      });

      test('preserves all template fields through roundtrip', () async {
        final original = TemplateFixtures.premium(
          id: 'premium-1',
          name: 'Premium Art',
        );

        await service.cacheTemplates([original]);
        final result = await service.getCachedTemplates();

        expect(result, hasLength(1));
        final restored = result!.first;
        expect(restored.id, equals('premium-1'));
        expect(restored.name, equals('Premium Art'));
        expect(restored.isPremium, isTrue);
        expect(restored.defaultAspectRatio, equals('16:9'));
        expect(restored.inputFields, hasLength(3));
      });
    });

    group('isCacheValid', () {
      test('returns false when no cache exists', () {
        expect(service.isCacheValid(), isFalse);
      });

      test('returns true immediately after caching', () async {
        await service.cacheTemplates(TemplateFixtures.list(count: 1));
        expect(service.isCacheValid(), isTrue);
      });

      test('returns false with zero-duration maxAge', () async {
        await service.cacheTemplates(TemplateFixtures.list(count: 1));
        // A zero maxAge means any age is too old.
        expect(service.isCacheValid(maxAge: Duration.zero), isFalse);
      });
    });

    group('clearCache', () {
      test('removes cache file and invalidates', () async {
        await service.cacheTemplates(TemplateFixtures.list(count: 1));
        expect(service.isCacheValid(), isTrue);

        await service.clearCache();

        expect(service.isCacheValid(), isFalse);
        expect(cacheFile.existsSync(), isFalse);
        final result = await service.getCachedTemplates();
        expect(result, isNull);
      });

      test('does not throw when no cache exists', () async {
        // Should not throw even if file doesn't exist.
        await expectLater(service.clearCache(), completes);
      });
    });
  });
}
