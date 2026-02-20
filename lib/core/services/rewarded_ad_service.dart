import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'rewarded_ad_service.g.dart';

/// Test ad unit IDs from Google documentation.
// TODO(release): Replace with production ad unit IDs from AdMob dashboard.
const _testAdUnitIdAndroid = 'ca-app-pub-3940256099942544/5224354917';
const _testAdUnitIdIos = 'ca-app-pub-3940256099942544/1712485313';

String get _adUnitId => defaultTargetPlatform == TargetPlatform.android
    ? _testAdUnitIdAndroid
    : _testAdUnitIdIos;

@riverpod
RewardedAdService rewardedAdService(Ref ref) {
  final service = RewardedAdService()..loadAd();
  ref.onDispose(service.dispose);
  return service;
}

/// Manages loading, showing, and disposing of Google AdMob rewarded ads.
///
/// Extends [ChangeNotifier] so widgets can reactively rebuild when
/// [isAdLoaded] changes (e.g., after preloading completes).
class RewardedAdService extends ChangeNotifier {
  RewardedAd? _rewardedAd;
  bool _isLoading = false;

  /// Whether a rewarded ad is loaded and ready to show.
  bool get isAdLoaded => _rewardedAd != null;

  /// Whether an ad is currently being loaded.
  bool get isLoading => _isLoading;

  /// Configure server-side verification options on the loaded ad.
  /// Call AFTER ad is loaded and BEFORE showing.
  Future<void> setServerSideVerification({
    required String userId,
    required String customData,
  }) async {
    await _rewardedAd?.setServerSideOptions(
      ServerSideVerificationOptions(
        userId: userId,
        customData: customData,
      ),
    );
  }

  /// Loads a rewarded ad. No-op if one is already loaded or loading.
  void loadAd() {
    if (_rewardedAd != null || _isLoading) return;
    _isLoading = true;

    RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoading = false;
          notifyListeners();
        },
        onAdFailedToLoad: (error) {
          debugPrint('RewardedAd failed to load: ${error.message}');
          _isLoading = false;
          notifyListeners();
        },
      ),
    );
  }

  /// Shows the loaded ad and returns `true` if the user earned the reward.
  ///
  /// Returns `false` if no ad was loaded or the user dismissed early.
  Future<bool> showAd() async {
    final ad = _rewardedAd;
    if (ad == null) return false;

    final completer = Completer<bool>();
    var rewarded = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        if (!completer.isCompleted) completer.complete(rewarded);
        loadAd(); // Pre-load next ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('RewardedAd failed to show: ${error.message}');
        ad.dispose();
        _rewardedAd = null;
        if (!completer.isCompleted) completer.complete(false);
        loadAd(); // Try to load another
      },
    );

    unawaited(
      ad.show(
        onUserEarnedReward: (ad, reward) {
          rewarded = true;
        },
      ),
    );

    return completer.future;
  }

  /// Disposes the current ad if loaded.
  @override
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    super.dispose();
  }
}
