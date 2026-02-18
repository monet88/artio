// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gallery_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$galleryStreamHash() => r'd9dc7f77ef5d74be9ace54352b4d462f6c590325';

/// Stream provider for realtime gallery updates
///
/// Copied from [galleryStream].
@ProviderFor(galleryStream)
final galleryStreamProvider =
    AutoDisposeStreamProvider<List<GalleryItem>>.internal(
      galleryStream,
      name: r'galleryStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$galleryStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GalleryStreamRef = AutoDisposeStreamProviderRef<List<GalleryItem>>;
String _$galleryActionsNotifierHash() =>
    r'2080b4fbf8ffcdab875edd03d52a56494d162f05';

/// Notifier for gallery actions (delete, restore, retry)
///
/// Copied from [GalleryActionsNotifier].
@ProviderFor(GalleryActionsNotifier)
final galleryActionsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<GalleryActionsNotifier, void>.internal(
      GalleryActionsNotifier.new,
      name: r'galleryActionsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$galleryActionsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GalleryActionsNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
