// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_detail_page.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userDetailHash() => r'be103ee2eac4aa54296e21f5e395f6785ec0a3f5';

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

/// See also [userDetail].
@ProviderFor(userDetail)
const userDetailProvider = UserDetailFamily();

/// See also [userDetail].
class UserDetailFamily extends Family<AsyncValue<AdminUserModel>> {
  /// See also [userDetail].
  const UserDetailFamily();

  /// See also [userDetail].
  UserDetailProvider call(String userId) {
    return UserDetailProvider(userId);
  }

  @override
  UserDetailProvider getProviderOverride(
    covariant UserDetailProvider provider,
  ) {
    return call(provider.userId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'userDetailProvider';
}

/// See also [userDetail].
class UserDetailProvider extends AutoDisposeFutureProvider<AdminUserModel> {
  /// See also [userDetail].
  UserDetailProvider(String userId)
    : this._internal(
        (ref) => userDetail(ref as UserDetailRef, userId),
        from: userDetailProvider,
        name: r'userDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$userDetailHash,
        dependencies: UserDetailFamily._dependencies,
        allTransitiveDependencies: UserDetailFamily._allTransitiveDependencies,
        userId: userId,
      );

  UserDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    FutureOr<AdminUserModel> Function(UserDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserDetailProvider._internal(
        (ref) => create(ref as UserDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<AdminUserModel> createElement() {
    return _UserDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserDetailProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserDetailRef on AutoDisposeFutureProviderRef<AdminUserModel> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UserDetailProviderElement
    extends AutoDisposeFutureProviderElement<AdminUserModel>
    with UserDetailRef {
  _UserDetailProviderElement(super.provider);

  @override
  String get userId => (origin as UserDetailProvider).userId;
}

String _$userGenerationCountHash() =>
    r'4206f8b009702c43e30e59cb9c695ae9711b44fa';

/// See also [userGenerationCount].
@ProviderFor(userGenerationCount)
const userGenerationCountProvider = UserGenerationCountFamily();

/// See also [userGenerationCount].
class UserGenerationCountFamily extends Family<AsyncValue<int>> {
  /// See also [userGenerationCount].
  const UserGenerationCountFamily();

  /// See also [userGenerationCount].
  UserGenerationCountProvider call(String userId) {
    return UserGenerationCountProvider(userId);
  }

  @override
  UserGenerationCountProvider getProviderOverride(
    covariant UserGenerationCountProvider provider,
  ) {
    return call(provider.userId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'userGenerationCountProvider';
}

/// See also [userGenerationCount].
class UserGenerationCountProvider extends AutoDisposeFutureProvider<int> {
  /// See also [userGenerationCount].
  UserGenerationCountProvider(String userId)
    : this._internal(
        (ref) => userGenerationCount(ref as UserGenerationCountRef, userId),
        from: userGenerationCountProvider,
        name: r'userGenerationCountProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$userGenerationCountHash,
        dependencies: UserGenerationCountFamily._dependencies,
        allTransitiveDependencies:
            UserGenerationCountFamily._allTransitiveDependencies,
        userId: userId,
      );

  UserGenerationCountProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    FutureOr<int> Function(UserGenerationCountRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserGenerationCountProvider._internal(
        (ref) => create(ref as UserGenerationCountRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<int> createElement() {
    return _UserGenerationCountProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserGenerationCountProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserGenerationCountRef on AutoDisposeFutureProviderRef<int> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UserGenerationCountProviderElement
    extends AutoDisposeFutureProviderElement<int>
    with UserGenerationCountRef {
  _UserGenerationCountProviderElement(super.provider);

  @override
  String get userId => (origin as UserGenerationCountProvider).userId;
}

String _$userRecentJobsHash() => r'aa16c3dc6482a7e42741130d4367bf8ac07fd691';

/// See also [userRecentJobs].
@ProviderFor(userRecentJobs)
const userRecentJobsProvider = UserRecentJobsFamily();

/// See also [userRecentJobs].
class UserRecentJobsFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// See also [userRecentJobs].
  const UserRecentJobsFamily();

  /// See also [userRecentJobs].
  UserRecentJobsProvider call(String userId) {
    return UserRecentJobsProvider(userId);
  }

  @override
  UserRecentJobsProvider getProviderOverride(
    covariant UserRecentJobsProvider provider,
  ) {
    return call(provider.userId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'userRecentJobsProvider';
}

/// See also [userRecentJobs].
class UserRecentJobsProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// See also [userRecentJobs].
  UserRecentJobsProvider(String userId)
    : this._internal(
        (ref) => userRecentJobs(ref as UserRecentJobsRef, userId),
        from: userRecentJobsProvider,
        name: r'userRecentJobsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$userRecentJobsHash,
        dependencies: UserRecentJobsFamily._dependencies,
        allTransitiveDependencies:
            UserRecentJobsFamily._allTransitiveDependencies,
        userId: userId,
      );

  UserRecentJobsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    FutureOr<List<Map<String, dynamic>>> Function(UserRecentJobsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserRecentJobsProvider._internal(
        (ref) => create(ref as UserRecentJobsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _UserRecentJobsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserRecentJobsProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserRecentJobsRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UserRecentJobsProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with UserRecentJobsRef {
  _UserRecentJobsProviderElement(super.provider);

  @override
  String get userId => (origin as UserRecentJobsProvider).userId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
