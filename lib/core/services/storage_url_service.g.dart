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

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
