// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_stats_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$analyticsStatsHash() => r'ff5f3f1f41e6c6a0125abf03e67864b6ce76c077';

/// Fetches and aggregates analytics data from Supabase.
///
/// Data sources:
/// - `profiles`: user counts (total, premium)
/// - `generation_jobs`: job counts + 7-day breakdown + top models
///
/// Copied from [analyticsStats].
@ProviderFor(analyticsStats)
final analyticsStatsProvider =
    AutoDisposeFutureProvider<AnalyticsStats>.internal(
      analyticsStats,
      name: r'analyticsStatsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$analyticsStatsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AnalyticsStatsRef = AutoDisposeFutureProviderRef<AnalyticsStats>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
