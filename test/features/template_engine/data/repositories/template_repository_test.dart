import 'dart:io';

import 'package:artio/features/template_engine/data/services/template_cache_service.dart';
import 'package:artio/features/template_engine/domain/entities/template_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../core/fixtures/template_fixtures.dart';

void main() {
  group('TemplateRepository', () {
    // Note: TemplateRepository uses Supabase Postgrest APIs with complex
    // generic type constraints that are difficult to mock with mocktail.
    // The PostgrestBuilder chain (select -> eq -> order) returns types
    // that cannot be easily stubbed without breaking mocktail's type system.
    //
    // Recommended testing approach:
    // 1. Integration tests against a real Supabase instance (preferred)
    // 2. Use a test Supabase project with known test data
    // 3. Test the actual TemplateModel parsing separately

    group('TemplateModel.fromJson', () {
      test('parses valid JSON correctly', () {
        final json = {
          'id': 'template-1',
          'name': 'Anime Style',
          'description': 'Generate anime art',
          'thumbnail_url': 'https://example.com/thumb.png',
          'category': 'portrait',
          'prompt_template': 'Generate {prompt} in anime style',
          'input_fields': <Map<String, dynamic>>[],
          'default_aspect_ratio': '1:1',
          'is_premium': false,
          'order': 1,
        };

        final template = TemplateModel.fromJson(json);

        expect(template.id, equals('template-1'));
        expect(template.name, equals('Anime Style'));
        expect(template.description, equals('Generate anime art'));
        expect(template.category, equals('portrait'));
        expect(template.isPremium, isFalse);
        expect(template.order, equals(1));
      });

      test('uses default values for optional fields', () {
        final json = {
          'id': 'template-2',
          'name': 'Basic',
          'description': 'Basic template',
          'thumbnail_url': 'https://example.com/basic.png',
          'category': 'general',
          'prompt_template': '{prompt}',
          'input_fields': <Map<String, dynamic>>[],
        };

        final template = TemplateModel.fromJson(json);

        expect(template.defaultAspectRatio, equals('1:1'));
        expect(template.isPremium, isFalse);
        expect(template.order, equals(0));
      });

      test('parses input fields correctly', () {
        final json = {
          'id': 'template-3',
          'name': 'With Fields',
          'description': 'Template with inputs',
          'thumbnail_url': 'https://example.com/fields.png',
          'category': 'art',
          'prompt_template': '{prompt} in {style}',
          'input_fields': [
            {
              'name': 'style',
              'label': 'Style',
              'type': 'select',
              'options': ['Anime', 'Realistic'],
              'required': true,
            },
          ],
          'default_aspect_ratio': '16:9',
          'is_premium': true,
          'order': 5,
        };

        final template = TemplateModel.fromJson(json);

        expect(template.inputFields, hasLength(1));
        expect(template.inputFields[0].name, equals('style'));
        expect(template.inputFields[0].type, equals('select'));
        expect(template.inputFields[0].options, contains('Anime'));
        expect(template.isPremium, isTrue);
      });
    });

    group('Cache integration', () {
      late TemplateCacheService cache;
      late Directory tempDir;

      setUp(() {
        tempDir = Directory.systemTemp.createTempSync('repo_cache_test_');
        cache = TemplateCacheService.forTesting(tempDir.path);
      });

      tearDown(() {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      });

      test('cache hit returns data without network', () async {
        final templates = TemplateFixtures.list(count: 3);
        await cache.cacheTemplates(templates);

        // Cache is valid → getCachedTemplates returns data.
        expect(cache.isCacheValid(), isTrue);
        final cached = await cache.getCachedTemplates();
        expect(cached, hasLength(3));
      });

      test('cache miss when no data cached', () async {
        expect(cache.isCacheValid(), isFalse);
        final cached = await cache.getCachedTemplates();
        expect(cached, isNull);
      });

      test('stale cache still returns data', () async {
        final templates = TemplateFixtures.list(count: 2);
        await cache.cacheTemplates(templates);

        // Even if isCacheValid() returns false (due to zero TTL),
        // getCachedTemplates() still returns the stale data.
        expect(cache.isCacheValid(maxAge: Duration.zero), isFalse);
        final stale = await cache.getCachedTemplates();
        expect(stale, isNotNull);
        expect(stale, hasLength(2));
      });

      test('cache update overwrites previous data', () async {
        await cache.cacheTemplates(TemplateFixtures.list(count: 2));
        final updated = TemplateFixtures.list();
        await cache.cacheTemplates(updated);

        final result = await cache.getCachedTemplates();
        expect(result, hasLength(5));
      });
    });
  });
}
