// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$offeringsHash() => r'2eb62fe03c9a43507e707198a0ac0883f456eea6';

/// Provider for available subscription offerings.
///
/// Copied from [offerings].
@ProviderFor(offerings)
final offeringsProvider =
    AutoDisposeFutureProvider<List<SubscriptionPackage>>.internal(
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
typedef OfferingsRef = AutoDisposeFutureProviderRef<List<SubscriptionPackage>>;
String _$subscriptionNotifierHash() =>
    r'376d0f0ed706f49953565fb6163f48c529997a41';

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
