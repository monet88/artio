// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$offeringsHash() => r'e9c4dc5822abac007535a32b3e8d8c5f6b05f425';

/// Provider for available subscription offerings.
///
/// Copied from [offerings].
@ProviderFor(offerings)
final offeringsProvider = AutoDisposeFutureProvider<List<Package>>.internal(
  offerings,
  name: r'offeringsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$offeringsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OfferingsRef = AutoDisposeFutureProviderRef<List<Package>>;
String _$subscriptionNotifierHash() =>
    r'e284506445117fe7bec8952a6d7ad053cba02c9b';

/// See also [SubscriptionNotifier].
@ProviderFor(SubscriptionNotifier)
final subscriptionNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      SubscriptionNotifier,
      SubscriptionStatus
    >.internal(
      SubscriptionNotifier.new,
      name: r'subscriptionNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$subscriptionNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SubscriptionNotifier = AutoDisposeAsyncNotifier<SubscriptionStatus>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
