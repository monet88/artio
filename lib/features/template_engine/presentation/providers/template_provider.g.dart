// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$templateByIdHash() => r'4acca29dd5b6fca9225c81dbd06f3f9ffcb538d6';

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

/// See also [templateById].
@ProviderFor(templateById)
const templateByIdProvider = TemplateByIdFamily();

/// See also [templateById].
class TemplateByIdFamily extends Family<AsyncValue<TemplateModel?>> {
  /// See also [templateById].
  const TemplateByIdFamily();

  /// See also [templateById].
  TemplateByIdProvider call(String id) {
    return TemplateByIdProvider(id);
  }

  @override
  TemplateByIdProvider getProviderOverride(
    covariant TemplateByIdProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'templateByIdProvider';
}

/// See also [templateById].
class TemplateByIdProvider extends AutoDisposeFutureProvider<TemplateModel?> {
  /// See also [templateById].
  TemplateByIdProvider(String id)
    : this._internal(
        (ref) => templateById(ref as TemplateByIdRef, id),
        from: templateByIdProvider,
        name: r'templateByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$templateByIdHash,
        dependencies: TemplateByIdFamily._dependencies,
        allTransitiveDependencies:
            TemplateByIdFamily._allTransitiveDependencies,
        id: id,
      );

  TemplateByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<TemplateModel?> Function(TemplateByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TemplateByIdProvider._internal(
        (ref) => create(ref as TemplateByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<TemplateModel?> createElement() {
    return _TemplateByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TemplateByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TemplateByIdRef on AutoDisposeFutureProviderRef<TemplateModel?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _TemplateByIdProviderElement
    extends AutoDisposeFutureProviderElement<TemplateModel?>
    with TemplateByIdRef {
  _TemplateByIdProviderElement(super.provider);

  @override
  String get id => (origin as TemplateByIdProvider).id;
}

String _$templatesHash() => r'6bf66ebe6d3419c4121d46be672f1349cbd69c40';

/// See also [templates].
@ProviderFor(templates)
final templatesProvider =
    AutoDisposeFutureProvider<List<TemplateModel>>.internal(
      templates,
      name: r'templatesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$templatesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TemplatesRef = AutoDisposeFutureProviderRef<List<TemplateModel>>;
String _$templatesByCategoryHash() =>
    r'9fc66d20aa935f608b2579c192c9879aa6f20374';

/// See also [templatesByCategory].
@ProviderFor(templatesByCategory)
const templatesByCategoryProvider = TemplatesByCategoryFamily();

/// See also [templatesByCategory].
class TemplatesByCategoryFamily
    extends Family<AsyncValue<List<TemplateModel>>> {
  /// See also [templatesByCategory].
  const TemplatesByCategoryFamily();

  /// See also [templatesByCategory].
  TemplatesByCategoryProvider call(String category) {
    return TemplatesByCategoryProvider(category);
  }

  @override
  TemplatesByCategoryProvider getProviderOverride(
    covariant TemplatesByCategoryProvider provider,
  ) {
    return call(provider.category);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'templatesByCategoryProvider';
}

/// See also [templatesByCategory].
class TemplatesByCategoryProvider
    extends AutoDisposeFutureProvider<List<TemplateModel>> {
  /// See also [templatesByCategory].
  TemplatesByCategoryProvider(String category)
    : this._internal(
        (ref) => templatesByCategory(ref as TemplatesByCategoryRef, category),
        from: templatesByCategoryProvider,
        name: r'templatesByCategoryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$templatesByCategoryHash,
        dependencies: TemplatesByCategoryFamily._dependencies,
        allTransitiveDependencies:
            TemplatesByCategoryFamily._allTransitiveDependencies,
        category: category,
      );

  TemplatesByCategoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.category,
  }) : super.internal();

  final String category;

  @override
  Override overrideWith(
    FutureOr<List<TemplateModel>> Function(TemplatesByCategoryRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TemplatesByCategoryProvider._internal(
        (ref) => create(ref as TemplatesByCategoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        category: category,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<TemplateModel>> createElement() {
    return _TemplatesByCategoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TemplatesByCategoryProvider && other.category == category;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, category.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TemplatesByCategoryRef
    on AutoDisposeFutureProviderRef<List<TemplateModel>> {
  /// The parameter `category` of this provider.
  String get category;
}

class _TemplatesByCategoryProviderElement
    extends AutoDisposeFutureProviderElement<List<TemplateModel>>
    with TemplatesByCategoryRef {
  _TemplatesByCategoryProviderElement(super.provider);

  @override
  String get category => (origin as TemplatesByCategoryProvider).category;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
