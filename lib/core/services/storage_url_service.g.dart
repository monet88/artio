// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_url_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$storageUrlServiceHash() => r'3d2f1e06fc4024a2a20dcbbf58e72b7e2b5cb2a3';

/// See also [storageUrlService].
@ProviderFor(storageUrlService)
final storageUrlServiceProvider =
    AutoDisposeProvider<StorageUrlService>.internal(
      storageUrlService,
      name: r'storageUrlServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$storageUrlServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StorageUrlServiceRef = AutoDisposeProviderRef<StorageUrlService>;
String _$signedStorageUrlHash() => r'dedcf7acf5f25e594f9eeb3399bce14c052e58db';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Resolves a single storage path to a signed HTTPS URL.
/// Used in widgets via `ref.watch(signedStorageUrlProvider(path))`.
///
/// Copied from [signedStorageUrl].
@ProviderFor(signedStorageUrl)
const signedStorageUrlProvider = SignedStorageUrlFamily();

/// Resolves a single storage path to a signed HTTPS URL.
/// Used in widgets via `ref.watch(signedStorageUrlProvider(path))`.
///
/// Copied from [signedStorageUrl].
class SignedStorageUrlFamily extends Family<AsyncValue<String?>> {
  /// Resolves a single storage path to a signed HTTPS URL.
  /// Used in widgets via `ref.watch(signedStorageUrlProvider(path))`.
  ///
  /// Copied from [signedStorageUrl].
  const SignedStorageUrlFamily();

  /// Resolves a single storage path to a signed HTTPS URL.
  /// Used in widgets via `ref.watch(signedStorageUrlProvider(path))`.
  ///
  /// Copied from [signedStorageUrl].
  SignedStorageUrlProvider call(String storagePath) {
    return SignedStorageUrlProvider(storagePath);
  }

  @override
  SignedStorageUrlProvider getProviderOverride(
    covariant SignedStorageUrlProvider provider,
  ) {
    return call(provider.storagePath);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'signedStorageUrlProvider';
}

/// Resolves a single storage path to a signed HTTPS URL.
/// Used in widgets via `ref.watch(signedStorageUrlProvider(path))`.
///
/// Copied from [signedStorageUrl].
class SignedStorageUrlProvider extends AutoDisposeFutureProvider<String?> {
  /// Resolves a single storage path to a signed HTTPS URL.
  /// Used in widgets via `ref.watch(signedStorageUrlProvider(path))`.
  ///
  /// Copied from [signedStorageUrl].
  SignedStorageUrlProvider(String storagePath)
    : this._internal(
        (ref) => signedStorageUrl(ref as SignedStorageUrlRef, storagePath),
        from: signedStorageUrlProvider,
        name: r'signedStorageUrlProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$signedStorageUrlHash,
        dependencies: SignedStorageUrlFamily._dependencies,
        allTransitiveDependencies:
            SignedStorageUrlFamily._allTransitiveDependencies,
        storagePath: storagePath,
      );

  SignedStorageUrlProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.storagePath,
  }) : super.internal();

  final String storagePath;

  @override
  Override overrideWith(
    FutureOr<String?> Function(SignedStorageUrlRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SignedStorageUrlProvider._internal(
        (ref) => create(ref as SignedStorageUrlRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        storagePath: storagePath,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<String?> createElement() {
    return _SignedStorageUrlProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SignedStorageUrlProvider &&
        other.storagePath == storagePath;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, storagePath.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SignedStorageUrlRef on AutoDisposeFutureProviderRef<String?> {
  /// The parameter `storagePath` of this provider.
  String get storagePath;
}

class _SignedStorageUrlProviderElement
    extends AutoDisposeFutureProviderElement<String?>
    with SignedStorageUrlRef {
  _SignedStorageUrlProviderElement(super.provider);

  @override
  String get storagePath => (origin as SignedStorageUrlProvider).storagePath;
}

String _$gallerySignedUrlsHash() => r'333703756d303d9789259529edfa173cb2668dba';

/// Batch-resolves a list of gallery item image paths to signed URLs.
/// Returns a map of storagePath → signedUrl.
/// Use this at the page level to avoid N+1 signed URL API calls.
///
/// Copied from [gallerySignedUrls].
@ProviderFor(gallerySignedUrls)
const gallerySignedUrlsProvider = GallerySignedUrlsFamily();

/// Batch-resolves a list of gallery item image paths to signed URLs.
/// Returns a map of storagePath → signedUrl.
/// Use this at the page level to avoid N+1 signed URL API calls.
///
/// Copied from [gallerySignedUrls].
class GallerySignedUrlsFamily extends Family<AsyncValue<Map<String, String?>>> {
  /// Batch-resolves a list of gallery item image paths to signed URLs.
  /// Returns a map of storagePath → signedUrl.
  /// Use this at the page level to avoid N+1 signed URL API calls.
  ///
  /// Copied from [gallerySignedUrls].
  const GallerySignedUrlsFamily();

  /// Batch-resolves a list of gallery item image paths to signed URLs.
  /// Returns a map of storagePath → signedUrl.
  /// Use this at the page level to avoid N+1 signed URL API calls.
  ///
  /// Copied from [gallerySignedUrls].
  GallerySignedUrlsProvider call(List<String> paths) {
    return GallerySignedUrlsProvider(paths);
  }

  @override
  GallerySignedUrlsProvider getProviderOverride(
    covariant GallerySignedUrlsProvider provider,
  ) {
    return call(provider.paths);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'gallerySignedUrlsProvider';
}

/// Batch-resolves a list of gallery item image paths to signed URLs.
/// Returns a map of storagePath → signedUrl.
/// Use this at the page level to avoid N+1 signed URL API calls.
///
/// Copied from [gallerySignedUrls].
class GallerySignedUrlsProvider
    extends AutoDisposeFutureProvider<Map<String, String?>> {
  /// Batch-resolves a list of gallery item image paths to signed URLs.
  /// Returns a map of storagePath → signedUrl.
  /// Use this at the page level to avoid N+1 signed URL API calls.
  ///
  /// Copied from [gallerySignedUrls].
  GallerySignedUrlsProvider(List<String> paths)
    : this._internal(
        (ref) => gallerySignedUrls(ref as GallerySignedUrlsRef, paths),
        from: gallerySignedUrlsProvider,
        name: r'gallerySignedUrlsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$gallerySignedUrlsHash,
        dependencies: GallerySignedUrlsFamily._dependencies,
        allTransitiveDependencies:
            GallerySignedUrlsFamily._allTransitiveDependencies,
        paths: paths,
      );

  GallerySignedUrlsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.paths,
  }) : super.internal();

  final List<String> paths;

  @override
  Override overrideWith(
    FutureOr<Map<String, String?>> Function(GallerySignedUrlsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GallerySignedUrlsProvider._internal(
        (ref) => create(ref as GallerySignedUrlsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        paths: paths,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, String?>> createElement() {
    return _GallerySignedUrlsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GallerySignedUrlsProvider && other.paths == paths;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, paths.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GallerySignedUrlsRef
    on AutoDisposeFutureProviderRef<Map<String, String?>> {
  /// The parameter `paths` of this provider.
  List<String> get paths;
}

class _GallerySignedUrlsProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, String?>>
    with GallerySignedUrlsRef {
  _GallerySignedUrlsProviderElement(super.provider);

  @override
  List<String> get paths => (origin as GallerySignedUrlsProvider).paths;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
