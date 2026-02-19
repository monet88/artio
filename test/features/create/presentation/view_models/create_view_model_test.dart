import 'dart:async';

import 'package:artio/core/constants/app_constants.dart';
import 'package:artio/core/exceptions/app_exception.dart';
import 'package:artio/features/create/domain/entities/create_form_state.dart';
import 'package:artio/features/create/presentation/view_models/create_view_model.dart';
import 'package:artio/features/credits/domain/entities/credit_balance.dart';
import 'package:artio/features/credits/presentation/providers/credit_balance_provider.dart';
import 'package:artio/features/template_engine/data/repositories/generation_repository.dart';
import 'package:artio/features/template_engine/domain/entities/generation_job_model.dart';
import 'package:artio/features/template_engine/domain/policies/generation_policy.dart';
import 'package:artio/features/template_engine/presentation/providers/generation_policy_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../core/fixtures/fixtures.dart';

class MockGenerationRepository extends Mock implements GenerationRepository {}
class MockGenerationPolicy extends Mock implements IGenerationPolicy {}

class _FakeCreditBalanceNotifier extends CreditBalanceNotifier {
  _FakeCreditBalanceNotifier(this._balance);
  final int _balance;

  @override
  Stream<CreditBalance> build() {
    return Stream.value(CreditBalance(
      userId: 'test-user',
      balance: _balance,
      updatedAt: DateTime.now(),
    ));
  }
}

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

    ProviderContainer createContainer({int creditBalance = 100}) {
      return ProviderContainer(
        overrides: [
          generationRepositoryProvider.overrideWithValue(mockRepository),
          generationPolicyProvider.overrideWithValue(mockPolicy),
          creditBalanceNotifierProvider.overrideWith(() {
            return _FakeCreditBalanceNotifier(creditBalance);
          }),
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
              isPremiumUser: false,
            );

        final state = container.read(createViewModelProvider);
        expect(state.hasError, true);
      });

      test('rejects when prompt exceeds max length', () async {
        container = createContainer();
        final longPrompt = 'a' * (AppConstants.maxPromptLength + 1);

        await container.read(createViewModelProvider.notifier).generate(
              formState: CreateFormState(prompt: longPrompt),
              userId: 'user-1',
              isPremiumUser: false,
            );

        final state = container.read(createViewModelProvider);
        expect(state.hasError, true);
        expect(state.error, isA<GenerationException>());
      });

      test('rejects when model does not support selected aspect ratio', () async {
        container = createContainer();

        await container.read(createViewModelProvider.notifier).generate(
              formState: const CreateFormState(
                prompt: 'A sunset',
                modelId: 'gpt-image/1.5-text-to-image',
                aspectRatio: '16:9',
              ),
              userId: 'user-1',
              isPremiumUser: false,
            );

        final state = container.read(createViewModelProvider);
        expect(state.hasError, true);
        expect(state.error, isA<GenerationException>());
      });

      test('rejects premium model when user is not premium', () async {
        container = createContainer();

        await container.read(createViewModelProvider.notifier).generate(
              formState: const CreateFormState(
                prompt: 'A sunset',
                modelId: 'google/imagen4-ultra',
              ),
              userId: 'user-1',
              isPremiumUser: false,
            );

        verifyNever(() => mockPolicy.canGenerate(
          userId: any(named: 'userId'),
          templateId: any(named: 'templateId'),
        ));
        verifyNever(() => mockRepository.startGeneration(
          templateId: any(named: 'templateId'),
          prompt: any(named: 'prompt'),
          aspectRatio: any(named: 'aspectRatio'),
          imageCount: any(named: 'imageCount'),
          outputFormat: any(named: 'outputFormat'),
          modelId: any(named: 'modelId'),
        ));

        final state = container.read(createViewModelProvider);
        expect(state.hasError, true);
      });

      test('rejects when user has insufficient credits', () async {
        container = createContainer(creditBalance: 0);

        // Wait for the credit balance stream to emit data
        await container.read(creditBalanceNotifierProvider.future);

        await container.read(createViewModelProvider.notifier).generate(
              formState: const CreateFormState(prompt: 'A sunset'),
              userId: 'user-1',
              isPremiumUser: false,
            );

        verifyNever(() => mockPolicy.canGenerate(
          userId: any(named: 'userId'),
          templateId: any(named: 'templateId'),
        ));

        final state = container.read(createViewModelProvider);
        expect(state.hasError, true);
        expect(state.error, isA<PaymentException>());
      });

      test('proceeds when user has sufficient credits', () async {
        container = createContainer();

        // Wait for the credit balance stream to emit data
        await container.read(creditBalanceNotifierProvider.future);

        when(() => mockPolicy.canGenerate(
          userId: any(named: 'userId'),
          templateId: any(named: 'templateId'),
        )).thenAnswer((_) async => const GenerationEligibility.allowed());

        when(() => mockRepository.startGeneration(
          templateId: any(named: 'templateId'),
          prompt: any(named: 'prompt'),
          aspectRatio: any(named: 'aspectRatio'),
          imageCount: any(named: 'imageCount'),
          outputFormat: any(named: 'outputFormat'),
          modelId: any(named: 'modelId'),
        )).thenAnswer((_) async => 'job-123');

        when(() => mockRepository.watchJob('job-123'))
            .thenAnswer((_) => const Stream.empty());

        await container.read(createViewModelProvider.notifier).generate(
              formState: const CreateFormState(prompt: 'A sunset'),
              userId: 'user-1',
              isPremiumUser: false,
            );

        // Credit check passed, so policy should have been called
        verify(() => mockPolicy.canGenerate(
          userId: 'user-1',
          templateId: any(named: 'templateId'),
        )).called(1);
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
          outputFormat: any(named: 'outputFormat'),
          modelId: any(named: 'modelId'),
        )).thenAnswer((_) async => 'job-123');

        when(() => mockRepository.watchJob('job-123'))
            .thenAnswer((_) => jobStreamController.stream);

        container = createContainer();

        unawaited(container.read(createViewModelProvider.notifier).generate(
              formState: const CreateFormState(prompt: 'A sunset'),
              userId: 'user-123',
              isPremiumUser: false,
            ));

        await Future<void>.delayed(const Duration(milliseconds: 10));

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
          outputFormat: any(named: 'outputFormat'),
          modelId: any(named: 'modelId'),
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
              isPremiumUser: false,
            ));

        await Future<void>.delayed(const Duration(milliseconds: 10));

        verify(() => mockRepository.startGeneration(
          templateId: 'free-text',
          prompt: 'A beautiful landscape',
          aspectRatio: '16:9',
          imageCount: 2,
          outputFormat: 'jpg',
          modelId: 'google/imagen4',
        )).called(1);
      });

      test('passes output format and model id to repository', () async {
        when(() => mockPolicy.canGenerate(
          userId: any(named: 'userId'),
          templateId: any(named: 'templateId'),
        )).thenAnswer((_) async => const GenerationEligibility.allowed());

        when(() => mockRepository.startGeneration(
          templateId: any(named: 'templateId'),
          prompt: any(named: 'prompt'),
          aspectRatio: any(named: 'aspectRatio'),
          imageCount: any(named: 'imageCount'),
          outputFormat: any(named: 'outputFormat'),
          modelId: any(named: 'modelId'),
        )).thenAnswer((_) async => 'job-123');

        when(() => mockRepository.watchJob('job-123'))
            .thenAnswer((_) => jobStreamController.stream);

        container = createContainer();

        unawaited(container.read(createViewModelProvider.notifier).generate(
              formState: const CreateFormState(
                prompt: 'A beautiful landscape',
                outputFormat: 'png',
                modelId: 'flux-2/flex-text-to-image',
              ),
              userId: 'user-123',
              isPremiumUser: false,
            ));

        await Future<void>.delayed(const Duration(milliseconds: 10));

        verify(() => mockRepository.startGeneration(
          templateId: 'free-text',
          prompt: 'A beautiful landscape',
          outputFormat: 'png',
          modelId: 'flux-2/flex-text-to-image',
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
              isPremiumUser: false,
            );

        final state = container.read(createViewModelProvider);
        expect(state.hasError, true);
      });

      test('prevents duplicate submission while generating', () async {
        when(() => mockPolicy.canGenerate(
          userId: any(named: 'userId'),
          templateId: any(named: 'templateId'),
        )).thenAnswer((_) async => const GenerationEligibility.allowed());

        when(() => mockRepository.startGeneration(
          templateId: any(named: 'templateId'),
          prompt: any(named: 'prompt'),
          aspectRatio: any(named: 'aspectRatio'),
          imageCount: any(named: 'imageCount'),
          outputFormat: any(named: 'outputFormat'),
          modelId: any(named: 'modelId'),
        )).thenAnswer((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return 'job-123';
        });

        when(() => mockRepository.watchJob('job-123'))
            .thenAnswer((_) => jobStreamController.stream);

        container = createContainer();

        final notifier = container.read(createViewModelProvider.notifier);
        unawaited(notifier.generate(
          formState: const CreateFormState(prompt: 'First request'),
          userId: 'user-123',
          isPremiumUser: false,
        ));

        await Future<void>.delayed(const Duration(milliseconds: 1));

        await notifier.generate(
          formState: const CreateFormState(prompt: 'Second request'),
          userId: 'user-123',
          isPremiumUser: false,
        );

        verify(() => mockRepository.startGeneration(
          templateId: any(named: 'templateId'),
          prompt: any(named: 'prompt'),
          aspectRatio: any(named: 'aspectRatio'),
          imageCount: any(named: 'imageCount'),
          outputFormat: any(named: 'outputFormat'),
          modelId: any(named: 'modelId'),
        )).called(1);
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
          outputFormat: any(named: 'outputFormat'),
          modelId: any(named: 'modelId'),
        )).thenThrow(Exception('Network error'));

        container = createContainer();

        await container.read(createViewModelProvider.notifier).generate(
              formState: const CreateFormState(prompt: 'A sunset'),
              userId: 'user-123',
              isPremiumUser: false,
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
          outputFormat: any(named: 'outputFormat'),
          modelId: any(named: 'modelId'),
        )).thenAnswer((_) async => 'job-123');

        when(() => mockRepository.watchJob('job-123'))
            .thenAnswer((_) => jobStreamController.stream);

        container = createContainer();

        unawaited(container.read(createViewModelProvider.notifier).generate(
              formState: const CreateFormState(prompt: 'Test'),
              userId: 'user-123',
              isPremiumUser: false,
            ));

        await Future<void>.delayed(Duration.zero);
        jobStreamController.add(GenerationJobFixtures.processing());
        await Future<void>.delayed(Duration.zero);

        container.read(createViewModelProvider.notifier).reset();

        final state = container.read(createViewModelProvider);
        expect(state.hasValue, true);
        expect(state.value, isNull);
      });
    });
  });
}
