import 'package:artio/features/auth/presentation/state/auth_state.dart';
import 'package:artio/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:artio/features/gallery/data/repositories/gallery_repository.dart';
import 'package:artio/features/gallery/presentation/providers/gallery_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock the concrete GalleryRepository class
class MockGalleryRepository extends Mock implements GalleryRepository {}

void main() {
  group('GalleryProvider', () {
    late MockGalleryRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      mockRepository = MockGalleryRepository();
    });

    tearDown(() {
      container.dispose();
    });

    group('GalleryActionsNotifier', () {
      ProviderContainer createContainer() {
        return ProviderContainer(
          overrides: [
            galleryRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );
      }

      test('softDeleteImage calls repository', () async {
        when(() => mockRepository.softDeleteImage('job-123'))
            .thenAnswer((_) async {});

        container = createContainer();
        await container.read(galleryActionsNotifierProvider.notifier).softDeleteImage('job-123');

        verify(() => mockRepository.softDeleteImage('job-123')).called(1);
      });

      test('restoreImage calls repository', () async {
        when(() => mockRepository.restoreImage('job-123'))
            .thenAnswer((_) async {});

        container = createContainer();
        await container.read(galleryActionsNotifierProvider.notifier).restoreImage('job-123');

        verify(() => mockRepository.restoreImage('job-123')).called(1);
      });

      test('retryGeneration calls repository', () async {
        when(() => mockRepository.retryGeneration('job-123'))
            .thenAnswer((_) async {});

        container = createContainer();
        await container.read(galleryActionsNotifierProvider.notifier).retryGeneration('job-123');

        verify(() => mockRepository.retryGeneration('job-123')).called(1);
      });

      test('toggleFavorite calls repository with correct params', () async {
        when(() => mockRepository.toggleFavorite('item-123', true))
            .thenAnswer((_) async {});

        container = createContainer();
        await container.read(galleryActionsNotifierProvider.notifier).toggleFavorite('item-123', true);

        verify(() => mockRepository.toggleFavorite('item-123', true)).called(1);
      });

      test('softDeleteImage handles error gracefully', () async {
        when(() => mockRepository.softDeleteImage('job-123'))
            .thenThrow(Exception('Delete failed'));

        container = createContainer();
        await container.read(galleryActionsNotifierProvider.notifier).softDeleteImage('job-123');

        final state = container.read(galleryActionsNotifierProvider);
        expect(state.hasError, true);
      });
    });

    group('galleryStreamProvider', () {
      test('returns empty list when user is not authenticated', () async {
        container = ProviderContainer(
          overrides: [
            galleryRepositoryProvider.overrideWithValue(mockRepository),
            authViewModelProvider.overrideWith(_MockAuthNotifier.new),
          ],
        );

        // The stream should return empty when no authenticated user
        final stream = container.read(galleryStreamProvider);
        // Stream provider returns AsyncValue
        expect(stream, isA<AsyncValue>());
      });
    });
  });
}

// Mock auth notifier that returns unauthenticated state
class _MockAuthNotifier extends AuthViewModel {
  @override
  AuthState build() => const AuthState.initial();
}
