import 'package:artio/core/constants/ai_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AiModels', () {
    group('all', () {
      test('contains expected number of models', () {
        expect(AiModels.all.length, 16);
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

    group('standardAspectRatios', () {
      test('contains all expected ratios', () {
        expect(AiModels.standardAspectRatios, containsAll([
          '1:1', '2:3', '3:2', '4:5', '5:4', '9:16', '16:9', '3:4', '4:3',
        ]));
      });
    });

    group('gptAspectRatios', () {
      test('contains limited GPT ratios', () {
        expect(AiModels.gptAspectRatios, ['1:1', '2:3', '3:2']);
      });
    });

    group('GPT models', () {
      test('have limited aspect ratios', () {
        final model = AiModels.getById('gpt-image/1.5-text-to-image');
        expect(model?.supportedAspectRatios, AiModels.gptAspectRatios);
      });
    });

    group('new models', () {
      test('nano-banana-edit is marked as new', () {
        final model = AiModels.getById('google/nano-banana-edit');
        expect(model?.isNew, isTrue);
      });
    });
  });
}
