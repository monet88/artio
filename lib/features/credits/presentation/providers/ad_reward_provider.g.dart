// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ad_reward_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adRewardNotifierHash() => r'451bdc6237a240e30349d883305b81f0382008f6';

/// Manages the ad-watch → server-reward → UI-refresh flow.
///
/// State is the number of ads remaining today (0–10).
///
/// Copied from [AdRewardNotifier].
@ProviderFor(AdRewardNotifier)
final adRewardNotifierProvider =
    AutoDisposeAsyncNotifierProvider<AdRewardNotifier, int>.internal(
      AdRewardNotifier.new,
      name: r'adRewardNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adRewardNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AdRewardNotifier = AutoDisposeAsyncNotifier<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
