---
phase: 3
plan: 1
wave: 1
---

# Plan 3.1: AdMob Build Flavor Configuration

## Objective
Configure AdMob ad unit IDs to switch automatically based on build mode: test IDs for debug/profile, real IDs for release. This prevents invalid traffic flags from Google while ensuring production uses real ad units.

## Context
- lib/core/services/rewarded_ad_service.dart — Currently hardcodes test ad unit IDs (lines 12-17)
- Has `TODO(release): Replace with production ad unit IDs from AdMob dashboard`
- Uses `package:flutter/foundation.dart` (already imported, has `kReleaseMode`)

## Tasks

<task type="auto">
  <name>Implement build-mode AdMob ID switching</name>
  <files>lib/core/services/rewarded_ad_service.dart</files>
  <action>
    Replace the current hardcoded test IDs with build-mode aware getters:

    ```dart
    // Google test ad unit IDs — used in debug/profile builds.
    const _testAdUnitIdAndroid = 'ca-app-pub-3940256099942544/5224354917';
    const _testAdUnitIdIos = 'ca-app-pub-3940256099942544/1712485313';

    // Production ad unit IDs — used in release builds only.
    // TODO(admob): Replace these with real IDs from AdMob dashboard before first release.
    const _prodAdUnitIdAndroid = 'ca-app-pub-XXXXX/YYYYY';
    const _prodAdUnitIdIos = 'ca-app-pub-XXXXX/ZZZZZ';

    String get _adUnitId {
      final isAndroid = defaultTargetPlatform == TargetPlatform.android;
      if (kReleaseMode) {
        return isAndroid ? _prodAdUnitIdAndroid : _prodAdUnitIdIos;
      }
      return isAndroid ? _testAdUnitIdAndroid : _testAdUnitIdIos;
    }
    ```

    Keep `_prodAdUnitIdAndroid` and `_prodAdUnitIdIos` as placeholder values until user provides real IDs. Mark with `TODO(admob)`.

    Remove the old `TODO(release)` comment.

    **Do NOT:**
    - Create .env-based configuration (overkill for 2 constants)
    - Add abstraction layers or interfaces
  </action>
  <verify>flutter analyze</verify>
  <done>AdMob IDs switch based on kReleaseMode. Old TODO removed. Analyzer clean.</done>
</task>

<task type="auto">
  <name>Add test device registration documentation</name>
  <files>lib/core/services/rewarded_ad_service.dart</files>
  <action>
    Add a doc comment to the `RewardedAdService` class explaining how QA testers should register their device:

    ```dart
    /// ## QA Testing with Real Ads
    ///
    /// To test with real ad units without triggering invalid traffic:
    /// ```dart
    /// MobileAds.instance.updateRequestConfiguration(
    ///   RequestConfiguration(testDeviceIds: ['YOUR_DEVICE_ID']),
    /// );
    /// ```
    /// Get device ID from logcat/console when running with real ad units.
    ```

    Add this as a comment block above the class, NOT as runtime code.
  </action>
  <verify>flutter analyze</verify>
  <done>QA testing documentation added. Analyzer clean.</done>
</task>

## Success Criteria
- [ ] Debug builds use Google test ad unit IDs
- [ ] Release builds use production ad unit ID placeholders
- [ ] `kReleaseMode` used for switching (no custom env logic)
- [ ] QA testing documentation added
- [ ] Zero analyzer issues
