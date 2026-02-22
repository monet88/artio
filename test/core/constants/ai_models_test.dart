import 'package:artio/core/constants/ai_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AiModels', () {
    group('all', () {
      test('contains expected number of models', () {
        expect(AiModels.all.length, 18);
      });

      test('each model has required fields', () {
        for (final model in AiModels.all) {
          expect(model.id, isNotEmpty);
          expect(model.displayName, isNotEmpty);
          expect(model.supportedAspectRatios, isNotEmpty);
          expect(model.creditCost, greaterThan(0));
          expect(model.type, isNotEmpty);
        }
      });
    });

    group('defaultModelId', () {
      test('is google/imagen4', () {
        expect(AiModels.defaultModelId, 'google/imagen4');
      });
    });

    group('defaultModel', () {
      test('returns Imagen 4', () {
        final model = AiModels.defaultModel;
        expect(model.id, 'google/imagen4');
        expect(model.displayName, 'Imagen 4');
        expect(model.isPremium, isFalse);
      });
    });

    group('getById', () {
      test('returns model when found', () {
        final model = AiModels.getById('google/imagen4-fast');
        expect(model, isNotNull);
        expect(model!.displayName, 'Imagen 4 Fast');
      });

      test('returns null when not found', () {
        final model = AiModels.getById('nonexistent/model');
        expect(model, isNull);
      });
    });

    group('byType', () {
      test('filters text-to-image models', () {
        final models = AiModels.byType('text-to-image');
        expect(models, isNotEmpty);
        for (final model in models) {
          expect(model.type, 'text-to-image');
        }
      });

      test('filters image-to-image models', () {
        final models = AiModels.byType('image-to-image');
        expect(models, isNotEmpty);
        for (final model in models) {
          expect(model.type, 'image-to-image');
        }
      });

      test('filters image-editing models', () {
        final models = AiModels.byType('image-editing');
        expect(models, isNotEmpty);
        for (final model in models) {
          expect(model.type, 'image-editing');
        }
      });
    });

    group('textToImageModels', () {
      test('returns only text-to-image models', () {
        final models = AiModels.textToImageModels;
        expect(models, isNotEmpty);
        for (final model in models) {
          expect(model.type, 'text-to-image');
        }
      });
    });

    group('freeModels', () {
      test('returns only non-premium models', () {
        final models = AiModels.freeModels;
        expect(models, isNotEmpty);
        for (final model in models) {
          expect(model.isPremium, isFalse);
        }
      });
    });

    group('premium models', () {
      test('imagen4-ultra is premium', () {
        final model = AiModels.getById('google/imagen4-ultra');
        expect(model?.isPremium, isTrue);
      });

      test('flux-2/pro-text-to-image is premium', () {
        final model = AiModels.getById('flux-2/pro-text-to-image');
        expect(model?.isPremium, isTrue);
      });
    });

    group('supportedAspectRatios', () {
      test('contains unified ratio set', () {
        expect(
          AiModels.supportedAspectRatios,
          containsAll([
            '1:1',
            '3:4',
            '4:3',
            '9:16',
            '16:9',
          ]),
        );
      });
    });

    group('GPT models', () {
      test('use unified aspect ratios', () {
        final model = AiModels.getById('gpt-image/1.5-text-to-image');
        expect(model?.supportedAspectRatios, AiModels.supportedAspectRatios);
      });
    });

    group('new models', () {
      test('nano-banana-edit is marked as new', () {
        final model = AiModels.getById('google/nano-banana-edit');
        expect(model?.isNew, isTrue);
      });
    });

    group('supportsImageInput', () {
      test('imageCapableModels returns exactly 8 models', () {
        expect(AiModels.imageCapableModels.length, 8);
      });

      test('all models with supportsImageInput=true are in imageCapableModels', () {
        final imageModels = AiModels.imageCapableModels;
        for (final model in imageModels) {
          expect(model.supportsImageInput, isTrue);
        }
      });

      test('nano-banana-edit has supportsImageInput true', () {
        final model = AiModels.getById('google/nano-banana-edit');
        expect(model?.supportsImageInput, isTrue);
      });

      test('nano-banana-pro has supportsImageInput true', () {
        final model = AiModels.getById('nano-banana-pro');
        expect(model?.supportsImageInput, isTrue);
      });

      test('flux-2/flex-image-to-image has supportsImageInput true', () {
        final model = AiModels.getById('flux-2/flex-image-to-image');
        expect(model?.supportsImageInput, isTrue);
      });

      test('flux-2/pro-image-to-image has supportsImageInput true', () {
        final model = AiModels.getById('flux-2/pro-image-to-image');
        expect(model?.supportsImageInput, isTrue);
      });

      test('gpt-image/1.5-image-to-image has supportsImageInput true', () {
        final model = AiModels.getById('gpt-image/1.5-image-to-image');
        expect(model?.supportsImageInput, isTrue);
      });

      test('seedream/4.5-edit has supportsImageInput true', () {
        final model = AiModels.getById('seedream/4.5-edit');
        expect(model?.supportsImageInput, isTrue);
      });

      test('gemini-3-pro-image-preview has supportsImageInput true', () {
        final model = AiModels.getById('gemini-3-pro-image-preview');
        expect(model?.supportsImageInput, isTrue);
      });

      test('gemini-2.5-flash-image has supportsImageInput true', () {
        final model = AiModels.getById('gemini-2.5-flash-image');
        expect(model?.supportsImageInput, isTrue);
      });

      test('imagen-4.0-generate-001 has supportsImageInput false', () {
        final model = AiModels.getById('imagen-4.0-generate-001');
        expect(model?.supportsImageInput, isFalse);
      });

      test('google/imagen4 has supportsImageInput false', () {
        final model = AiModels.getById('google/imagen4');
        expect(model?.supportsImageInput, isFalse);
      });

      test('bidirectional filter excludes correctly', () {
        final imageModels = AiModels.all.where((m) => m.supportsImageInput).toList();
        final textModels = AiModels.all.where((m) => !m.supportsImageInput).toList();
        // No overlap
        final imageIds = imageModels.map((m) => m.id).toSet();
        final textIds = textModels.map((m) => m.id).toSet();
        expect(imageIds.intersection(textIds), isEmpty);
        // Full coverage
        expect(imageIds.length + textIds.length, AiModels.all.length);
      });
    });
  });
}
