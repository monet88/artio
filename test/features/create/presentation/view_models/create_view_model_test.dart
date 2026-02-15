import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:artio/features/create/domain/entities/create_form_state.dart';
import 'package:artio/features/create/presentation/view_models/create_view_model.dart';
import 'package:artio/features/template_engine/presentation/providers/generation_policy_provider.dart';
import 'package:artio/features/template_engine/data/repositories/generation_repository.dart';
import 'package:artio/features/template_engine/domain/entities/generation_job_model.dart';
import 'package:artio/features/template_engine/domain/policies/generation_policy.dart';
import '../../../../core/fixtures/fixtures.dart';

class MockGenerationRepository extends Mock implements GenerationRepository {}
class MockGenerationPolicy extends Mock implements IGenerationPolicy {}

void main() {
  group('CreateViewModel', () {
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
        container = createContainer();
        final state = container.read(createViewModelProvider);

        expect(state, isA<AsyncData<GenerationJobModel?>>());
        expect(state.value, isNull);
      });
    });

    group('generate', () {
      test('rejects when formState invalid', () async {
        container = createContainer();
        await container.read(createViewModelProvider.notifier).generate(
              formState: const CreateFormState(prompt: 'ab'),
              userId: 'user-1',
            );

        final state = container.read(createViewModelProvider);
        expect(state.hasError, true);
      });

      test('calls policy canGenerate with correct params', () async {
        when(() => mockPolicy.canGenerate(
          userId: any(named: 'userId'),
          templateId: any(named: 'templateId'),
        )).thenAnswer((_) async => const GenerationEligibility.allowed());

        when(() => mockRepository.startGeneration(
          templateId: any(named: 'templateId'),
          prompt: any(named: 'prompt'),
          aspectRatio: any(named: 'aspectRatio'),
          imageCount: any(named: 'imageCount'),
        )).thenAnswer((_) async => 'job-123');

        when(() => mockRepository.watchJob('job-123'))
            .thenAnswer((_) => jobStreamController.stream);

        container = createContainer();

        unawaited(container.read(createViewModelProvider.notifier).generate(
              formState: const CreateFormState(prompt: 'A sunset'),
              userId: 'user-123',
            ));

        await Future.delayed(const Duration(milliseconds: 10));

        verify(() => mockPolicy.canGenerate(
          userId: 'user-123',
          templateId: 'free-text',
        )).called(1);
      });

      test('calls repository startGeneration when policy allows', () async {
        when(() => mockPolicy.canGenerate(
          userId: any(named: 'userId'),
          templateId: any(named: 'templateId'),
        )).thenAnswer((_) async => const GenerationEligibility.allowed());

        when(() => mockRepository.startGeneration(
          templateId: any(named: 'templateId'),
          prompt: any(named: 'prompt'),
          aspectRatio: any(named: 'aspectRatio'),
          imageCount: any(named: 'imageCount'),
        )).thenAnswer((_) async => 'job-123');

        when(() => mockRepository.watchJob('job-123'))
            .thenAnswer((_) => jobStreamController.stream);

        container = createContainer();

        unawaited(container.read(createViewModelProvider.notifier).generate(
              formState: const CreateFormState(
                prompt: 'A beautiful landscape',
                aspectRatio: '16:9',
                imageCount: 2,
              ),
              userId: 'user-123',
            ));

        await Future.delayed(const Duration(milliseconds: 10));

        verify(() => mockRepository.startGeneration(
          templateId: 'free-text',
          prompt: 'A beautiful landscape',
          aspectRatio: '16:9',
          imageCount: 2,
        )).called(1);
      });

      test('sets error state when policy denies generation', () async {
        when(() => mockPolicy.canGenerate(
          userId: any(named: 'userId'),
          templateId: any(named: 'templateId'),
        )).thenAnswer((_) async => const GenerationEligibility.denied(
          reason: 'No credits remaining',
        ));

        container = createContainer();

        await container.read(createViewModelProvider.notifier).generate(
              formState: const CreateFormState(prompt: 'A sunset'),
              userId: 'user-123',
            );

        final state = container.read(createViewModelProvider);
        expect(state.hasError, true);
      });

      test('sets error state when repository throws', () async {
        when(() => mockPolicy.canGenerate(
          userId: any(named: 'userId'),
          templateId: any(named: 'templateId'),
        )).thenAnswer((_) async => const GenerationEligibility.allowed());

        when(() => mockRepository.startGeneration(
          templateId: any(named: 'templateId'),
          prompt: any(named: 'prompt'),
          aspectRatio: any(named: 'aspectRatio'),
          imageCount: any(named: 'imageCount'),
        )).thenThrow(Exception('Network error'));

        container = createContainer();

        await container.read(createViewModelProvider.notifier).generate(
              formState: const CreateFormState(prompt: 'A sunset'),
              userId: 'user-123',
            );

        final state = container.read(createViewModelProvider);
        expect(state.hasError, true);
      });
    });

    group('reset', () {
      test('resets state to AsyncData(null)', () async {
        when(() => mockPolicy.canGenerate(
          userId: any(named: 'userId'),
          templateId: any(named: 'templateId'),
        )).thenAnswer((_) async => const GenerationEligibility.allowed());

        when(() => mockRepository.startGeneration(
          templateId: any(named: 'templateId'),
          prompt: any(named: 'prompt'),
          aspectRatio: any(named: 'aspectRatio'),
          imageCount: any(named: 'imageCount'),
        )).thenAnswer((_) async => 'job-123');

        when(() => mockRepository.watchJob('job-123'))
            .thenAnswer((_) => jobStreamController.stream);

        container = createContainer();

        unawaited(container.read(createViewModelProvider.notifier).generate(
              formState: const CreateFormState(prompt: 'Test'),
              userId: 'user-123',
            ));

        await Future.delayed(Duration.zero);
        jobStreamController.add(GenerationJobFixtures.processing());
        await Future.delayed(Duration.zero);

        container.read(createViewModelProvider.notifier).reset();

        final state = container.read(createViewModelProvider);
        expect(state.hasValue, true);
        expect(state.value, isNull);
      });
    });
  });
}
