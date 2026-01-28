import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/view_models/auth_view_model.dart';
import '../../data/repositories/gallery_repository.dart';
import '../../domain/entities/gallery_item.dart';

part 'gallery_provider.g.dart';

/// Stream provider for realtime gallery updates
@riverpod
Stream<List<GalleryItem>> galleryStream(Ref ref) {
  final authState = ref.watch(authViewModelProvider);
  final userId = authState.maybeMap(
    authenticated: (s) => s.user.id,
    orElse: () => null,
  );
  
  if (userId == null) return Stream.value([]);
  
  final repository = ref.watch(galleryRepositoryProvider);
  return repository.watchUserImages(userId: userId);
}

/// Notifier for gallery actions (delete, restore, retry)
@riverpod
class GalleryActionsNotifier extends _$GalleryActionsNotifier {
  @override
  FutureOr<void> build() {}

  Future<void> softDeleteImage(String jobId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(galleryRepositoryProvider);
      await repository.softDeleteImage(jobId);
    });
  }

  Future<void> restoreImage(String jobId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(galleryRepositoryProvider);
      await repository.restoreImage(jobId);
    });
  }

  Future<void> retryGeneration(String jobId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(galleryRepositoryProvider);
      await repository.retryGeneration(jobId);
    });
  }

  Future<void> toggleFavorite(String itemId, bool isFavorite) async {
    final repository = ref.read(galleryRepositoryProvider);
    await repository.toggleFavorite(itemId, isFavorite);
  }
}
