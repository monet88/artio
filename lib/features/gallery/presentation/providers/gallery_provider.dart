import 'package:artio/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:artio/features/gallery/data/repositories/gallery_repository.dart';
import 'package:artio/features/gallery/domain/entities/gallery_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
  bool _isProcessing = false;

  @override
  FutureOr<void> build() {}

  Future<void> softDeleteImage(String jobId) async {
    if (_isProcessing || state.isLoading) return;
    _isProcessing = true;
    try {
      state = const AsyncLoading();
      state = await AsyncValue.guard(() async {
        final repository = ref.read(galleryRepositoryProvider);
        await repository.softDeleteImage(jobId);
      });
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> restoreImage(String jobId) async {
    if (_isProcessing || state.isLoading) return;
    _isProcessing = true;
    try {
      state = const AsyncLoading();
      state = await AsyncValue.guard(() async {
        final repository = ref.read(galleryRepositoryProvider);
        await repository.restoreImage(jobId);
      });
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> retryGeneration(String jobId) async {
    if (_isProcessing || state.isLoading) return;
    _isProcessing = true;
    try {
      state = const AsyncLoading();
      state = await AsyncValue.guard(() async {
        final repository = ref.read(galleryRepositoryProvider);
        await repository.retryGeneration(jobId);
      });
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> toggleFavorite(String itemId, {required bool isFavorite}) async {
    if (_isProcessing || state.isLoading) return;
    _isProcessing = true;
    try {
      state = await AsyncValue.guard(() async {
        final repository = ref.read(galleryRepositoryProvider);
        await repository.toggleFavorite(itemId, isFavorite: isFavorite);
      });
    } finally {
      _isProcessing = false;
    }
  }
}
