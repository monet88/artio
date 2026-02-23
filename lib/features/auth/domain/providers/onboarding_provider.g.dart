// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$onboardingDoneHash() => r'8034dd8611410b1c5c4b6db4904e89a56cd431fb';

/// Returns [true] if the user has already completed onboarding.
/// Persisted across sessions via SharedPreferences.
///
/// Copied from [onboardingDone].
@ProviderFor(onboardingDone)
final onboardingDoneProvider = AutoDisposeFutureProvider<bool>.internal(
  onboardingDone,
  name: r'onboardingDoneProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$onboardingDoneHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OnboardingDoneRef = AutoDisposeFutureProviderRef<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
