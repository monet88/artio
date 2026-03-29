// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_detail_page.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$jobDetailHash() => r'34dd07f1b2fc16768f4ba62364b3132a6272ad93';

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

/// See also [jobDetail].
@ProviderFor(jobDetail)
const jobDetailProvider = JobDetailFamily();

/// See also [jobDetail].
class JobDetailFamily extends Family<AsyncValue<AdminJobModel>> {
  /// See also [jobDetail].
  const JobDetailFamily();

  /// See also [jobDetail].
  JobDetailProvider call(String jobId) {
    return JobDetailProvider(jobId);
  }

  @override
  JobDetailProvider getProviderOverride(covariant JobDetailProvider provider) {
    return call(provider.jobId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'jobDetailProvider';
}

/// See also [jobDetail].
class JobDetailProvider extends AutoDisposeFutureProvider<AdminJobModel> {
  /// See also [jobDetail].
  JobDetailProvider(String jobId)
    : this._internal(
        (ref) => jobDetail(ref as JobDetailRef, jobId),
        from: jobDetailProvider,
        name: r'jobDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$jobDetailHash,
        dependencies: JobDetailFamily._dependencies,
        allTransitiveDependencies: JobDetailFamily._allTransitiveDependencies,
        jobId: jobId,
      );

  JobDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.jobId,
  }) : super.internal();

  final String jobId;

  @override
  Override overrideWith(
    FutureOr<AdminJobModel> Function(JobDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: JobDetailProvider._internal(
        (ref) => create(ref as JobDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        jobId: jobId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<AdminJobModel> createElement() {
    return _JobDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is JobDetailProvider && other.jobId == jobId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, jobId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin JobDetailRef on AutoDisposeFutureProviderRef<AdminJobModel> {
  /// The parameter `jobId` of this provider.
  String get jobId;
}

class _JobDetailProviderElement
    extends AutoDisposeFutureProviderElement<AdminJobModel>
    with JobDetailRef {
  _JobDetailProviderElement(super.provider);

  @override
  String get jobId => (origin as JobDetailProvider).jobId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
