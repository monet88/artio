import 'dart:async';

import 'package:artio/features/template_engine/data/repositories/generation_repository.dart';
import 'package:artio/features/template_engine/domain/entities/generation_job_model.dart';
import 'package:artio/features/template_engine/domain/policies/generation_policy.dart';
import 'package:artio/features/template_engine/presentation/providers/generation_policy_provider.dart';
import 'package:artio/features/template_engine/presentation/view_models/generation_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../core/fixtures/fixtures.dart';

// Mock classes
class MockGenerationRepository extends Mock implements GenerationRepository {}

class MockGenerationPolicy extends Mock implements IGenerationPolicy {}

void main() {
  group('GenerationViewModel', () {
    late MockGenerationRepository mockRepository;
    late MockGenerationPolicy mockPolicy;
    late ProviderContainer container;
    late StreamController<GenerationJobModel> jobStreamController;

    setUp(() {
      mockRepository = MockGenerationRepository();
      mockPolicy = MockGenerationPolicy();
      jobStreamController = StreamController<GenerationJobModel>.broadcast();
    });

    tearDown(() {
      container.dispose();
      jobStreamController.close();
    });

    ProviderContainer createContainer() {
      return ProviderContainer(
        overrides: [
          generationRepositoryProvider.overrideWithValue(mockRepository),
          generationPolicyProvider.overrideWithValue(mockPolicy),
        ],
      );
    }

    group('initial state', () {
      test('starts with AsyncData(null)', () {
        when(
          () => mockPolicy.canGenerate(
            userId: any(named: 'userId'),
            templateId: any(named: 'templateId'),
          ),
        ).thenAnswer((_) async => const GenerationEligibility.allowed());

        container = createContainer();
        final state = container.read(generationViewModelProvider);

        expect(state, isA<AsyncData<GenerationJobModel?>>());
        expect(state.value, isNull);
      });
    });

    group('generate', () {
      test('calls policy canGenerate with correct params', () async {
        when(
          () => mockPolicy.canGenerate(
            userId: any(named: 'userId'),
            templateId: any(named: 'templateId'),
          ),
        ).thenAnswer((_) async => const GenerationEligibility.allowed());

        when(
          () => mockRepository.startGeneration(
            userId: any(named: 'userId'),
            templateId: any(named: 'templateId'),
            prompt: any(named: 'prompt'),
            aspectRatio: any(named: 'aspectRatio'),
            imageCount: any(named: 'imageCount'),
          ),
        ).thenAnswer((_) async => 'job-123');

        when(
          () => mockRepository.watchJob('job-123'),
        ).thenAnswer((_) => jobStreamController.stream);

        container = createContainer();

        unawaited(
          container
              .read(generationViewModelProvider.notifier)
              .generate(
                templateId: 'template-1',
                prompt: 'A beautiful landscape',
                userId: 'user-123',
              ),
        );

        await Future<void>.delayed(const Duration(milliseconds: 10));

        verify(
          () => mockPolicy.canGenerate(
            userId: 'user-123',
            templateId: 'template-1',
          ),
        ).called(1);
      });

      test('calls repository startGeneration when policy allows', () async {
        when(
          () => mockPolicy.canGenerate(
            userId: any(named: 'userId'),
            templateId: any(named: 'templateId'),
          ),
        ).thenAnswer((_) async => const GenerationEligibility.allowed());

        when(
          () => mockRepository.startGeneration(
            userId: any(named: 'userId'),
            templateId: any(named: 'templateId'),
            prompt: any(named: 'prompt'),
            aspectRatio: any(named: 'aspectRatio'),
            imageCount: any(named: 'imageCount'),
          ),
        ).thenAnswer((_) async => 'job-123');

        when(
          () => mockRepository.watchJob('job-123'),
        ).thenAnswer((_) => jobStreamController.stream);

        container = createContainer();

        unawaited(
          container
              .read(generationViewModelProvider.notifier)
              .generate(
                templateId: 'template-1',
                prompt: 'A beautiful landscape',
                userId: 'user-123',
                aspectRatio: '16:9',
                imageCount: 2,
              ),
        );

        await Future<void>.delayed(const Duration(milliseconds: 10));

        verify(
          () => mockRepository.startGeneration(
            userId: 'user-123',
            templateId: 'template-1',
            prompt: 'A beautiful landscape',
            aspectRatio: '16:9',
            imageCount: 2,
          ),
        ).called(1);
      });

      test('sets error state when policy denies generation', () async {
        when(
          () => mockPolicy.canGenerate(
            userId: any(named: 'userId'),
            templateId: any(named: 'templateId'),
          ),
        ).thenAnswer(
          (_) async => const GenerationEligibility.denied(
            reason: 'No credits remaining',
          ),
        );

        container = createContainer();

        await container
            .read(generationViewModelProvider.notifier)
            .generate(
              templateId: 'template-1',
              prompt: 'A beautiful landscape',
              userId: 'user-123',
            );

        final state = container.read(generationViewModelProvider);
        expect(state.hasError, true);
      });

      test('sets error state when repository throws', () async {
        when(
          () => mockPolicy.canGenerate(
            userId: any(named: 'userId'),
            templateId: any(named: 'templateId'),
          ),
        ).thenAnswer((_) async => const GenerationEligibility.allowed());

        when(
          () => mockRepository.startGeneration(
            userId: any(named: 'userId'),
            templateId: any(named: 'templateId'),
            prompt: any(named: 'prompt'),
            aspectRatio: any(named: 'aspectRatio'),
            imageCount: any(named: 'imageCount'),
          ),
        ).thenThrow(Exception('Network error'));

        container = createContainer();

        await container
            .read(generationViewModelProvider.notifier)
            .generate(
              templateId: 'template-1',
              prompt: 'A beautiful landscape',
              userId: 'user-123',
            );

        final state = container.read(generationViewModelProvider);
        expect(state.hasError, true);
      });
    });

    group('reset', () {
      test('resets state to AsyncData(null)', () async {
        when(
          () => mockPolicy.canGenerate(
            userId: any(named: 'userId'),
            templateId: any(named: 'templateId'),
          ),
        ).thenAnswer((_) async => const GenerationEligibility.allowed());

        when(
          () => mockRepository.startGeneration(
            userId: any(named: 'userId'),
            templateId: any(named: 'templateId'),
            prompt: any(named: 'prompt'),
            aspectRatio: any(named: 'aspectRatio'),
            imageCount: any(named: 'imageCount'),
          ),
        ).thenAnswer((_) async => 'job-123');

        when(
          () => mockRepository.watchJob('job-123'),
        ).thenAnswer((_) => jobStreamController.stream);

        container = createContainer();

        // Start generation
        unawaited(
          container
              .read(generationViewModelProvider.notifier)
              .generate(
                templateId: 'template-1',
                prompt: 'Test',
                userId: 'user-123',
              ),
        );

        await Future<void>.delayed(Duration.zero);

        // Emit a job
        jobStreamController.add(GenerationJobFixtures.processing());
        await Future<void>.delayed(Duration.zero);

        // Reset
        container.read(generationViewModelProvider.notifier).reset();

        final state = container.read(generationViewModelProvider);
        expect(state.hasValue, true);
        expect(state.value, isNull);
      });
    });
  });
}
