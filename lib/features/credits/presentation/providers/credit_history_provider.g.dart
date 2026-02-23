// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$creditHistoryHash() => r'9208374504f963eb1d71b3705b308f26cce13d23';

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

/// Loads the last [_pageSize] credit transactions.
/// Paginated via [offset].
///
/// Copied from [creditHistory].
@ProviderFor(creditHistory)
const creditHistoryProvider = CreditHistoryFamily();

/// Loads the last [_pageSize] credit transactions.
/// Paginated via [offset].
///
/// Copied from [creditHistory].
class CreditHistoryFamily extends Family<AsyncValue<List<CreditTransaction>>> {
  /// Loads the last [_pageSize] credit transactions.
  /// Paginated via [offset].
  ///
  /// Copied from [creditHistory].
  const CreditHistoryFamily();

  /// Loads the last [_pageSize] credit transactions.
  /// Paginated via [offset].
  ///
  /// Copied from [creditHistory].
  CreditHistoryProvider call({int offset = 0}) {
    return CreditHistoryProvider(offset: offset);
  }

  @override
  CreditHistoryProvider getProviderOverride(
    covariant CreditHistoryProvider provider,
  ) {
    return call(offset: provider.offset);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'creditHistoryProvider';
}

/// Loads the last [_pageSize] credit transactions.
/// Paginated via [offset].
///
/// Copied from [creditHistory].
class CreditHistoryProvider
    extends AutoDisposeFutureProvider<List<CreditTransaction>> {
  /// Loads the last [_pageSize] credit transactions.
  /// Paginated via [offset].
  ///
  /// Copied from [creditHistory].
  CreditHistoryProvider({int offset = 0})
    : this._internal(
        (ref) => creditHistory(ref as CreditHistoryRef, offset: offset),
        from: creditHistoryProvider,
        name: r'creditHistoryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$creditHistoryHash,
        dependencies: CreditHistoryFamily._dependencies,
        allTransitiveDependencies:
            CreditHistoryFamily._allTransitiveDependencies,
        offset: offset,
      );

  CreditHistoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.offset,
  }) : super.internal();

  final int offset;

  @override
  Override overrideWith(
    FutureOr<List<CreditTransaction>> Function(CreditHistoryRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CreditHistoryProvider._internal(
        (ref) => create(ref as CreditHistoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        offset: offset,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<CreditTransaction>> createElement() {
    return _CreditHistoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CreditHistoryProvider && other.offset == offset;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, offset.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CreditHistoryRef
    on AutoDisposeFutureProviderRef<List<CreditTransaction>> {
  /// The parameter `offset` of this provider.
  int get offset;
}

class _CreditHistoryProviderElement
    extends AutoDisposeFutureProviderElement<List<CreditTransaction>>
    with CreditHistoryRef {
  _CreditHistoryProviderElement(super.provider);

  @override
  int get offset => (origin as CreditHistoryProvider).offset;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
