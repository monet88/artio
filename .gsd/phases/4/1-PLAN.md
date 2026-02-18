---
phase: 4
plan: 1
wave: 1
---

# Plan 4.1: Platform Config & Rewarded Ad Service

## Objective
Configure AdMob on both platforms, initialize the Mobile Ads SDK at app startup, and create a `RewardedAdService` that encapsulates loading, showing, and handling rewarded video ads. After this plan, the app can load and display test rewarded ads.

## Context
- `.gsd/SPEC.md` — Rewarded ads: +5 credits per ad, max 10/day, Google AdMob
- `pubspec.yaml` — `google_mobile_ads: ^6.0.0` already declared
- `android/app/src/main/AndroidManifest.xml` — Missing AdMob App ID meta-data
- `ios/Runner/Info.plist` — Already has `GADApplicationIdentifier` with test ID `ca-app-pub-3940256099942544~1458002511`
- `lib/main.dart` — App entry point, SDK init goes here
- `lib/core/services/haptic_service.dart` — Existing service pattern to follow

## Tasks

<task type="auto">
  <name>Add AdMob App ID to Android + Initialize SDK</name>
  <files>
    android/app/src/main/AndroidManifest.xml (MODIFY)
    lib/main.dart (MODIFY)
  </files>
  <action>
    1. Modify `AndroidManifest.xml` — Add AdMob App ID meta-data inside the `<application>` tag, after the `flutterEmbedding` meta-data (line 34):
       ```xml
       <meta-data
           android:name="com.google.android.gms.ads.APPLICATION_ID"
           android:value="ca-app-pub-3940256099942544~3347511713" />
       ```
       This is the Google-provided test App ID. Replace with real ID before production release.

    2. Modify `lib/main.dart` — Initialize MobileAds SDK after Supabase init:
       - Add import: `import 'package:google_mobile_ads/google_mobile_ads.dart';`
       - After `await SentryConfig.init();` (line 27), add:
         ```dart
         await MobileAds.instance.initialize();
         ```
       - This must complete before any ad loading

    AVOID:
    - Do NOT add real AdMob App IDs — use test IDs only (production IDs go in env config later)
    - Do NOT add any ad loading logic here — that's the RewardedAdService's job
  </action>
  <verify>
    dart analyze lib/main.dart — zero errors
    grep -q "com.google.android.gms.ads.APPLICATION_ID" android/app/src/main/AndroidManifest.xml
    grep -q "MobileAds.instance.initialize" lib/main.dart
  </verify>
  <done>
    - Android manifest has AdMob App ID meta-data
    - iOS Info.plist already has GADApplicationIdentifier (no change needed)
    - MobileAds SDK initialized in main.dart before runApp
    - `dart analyze` passes with zero errors
  </done>
</task>

<task type="auto">
  <name>Create RewardedAdService</name>
  <files>
    lib/core/services/rewarded_ad_service.dart (CREATE)
    lib/core/services/rewarded_ad_service.g.dart (GENERATED)
  </files>
  <action>
    1. Create `lib/core/services/rewarded_ad_service.dart`:
       - Riverpod provider using `@riverpod` annotation
       - Manages a single `RewardedAd` instance
       - Test ad unit IDs (from Google docs):
         - Android: `ca-app-pub-3940256099942544/5224354917`
         - iOS: `ca-app-pub-3940256099942544/1712485313`
       - Use `dart:io` `Platform.isAndroid` / `Platform.isIOS` to select correct ad unit ID
       - Methods:
         - `Future<void> loadAd()` — loads a rewarded ad, stores reference
         - `bool get isAdLoaded` — whether an ad is ready to show
         - `Future<bool> showAd()` — shows the ad, returns true if user earned reward
       - Implementation details:
         - `loadAd()`: Call `RewardedAd.load()` with ad unit ID, `AdRequest()`, and `RewardedAdLoadCallback`
         - Set `FullScreenContentCallback` on the loaded ad:
           - `onAdDismissedFullScreenContent`: dispose ad, pre-load next ad
           - `onAdFailedToShowFullScreenContent`: dispose ad, pre-load next ad
         - `showAd()`: Returns a `Future<bool>` using a `Completer`
           - If no ad loaded, return false
           - Show the ad, `onUserEarnedReward` callback completes with true
           - `onAdDismissedFullScreenContent` completes with false if not already completed
       - Auto-load first ad on creation via provider
       - Dispose ad in provider `ref.onDispose`

    2. Run `dart run build_runner build --delete-conflicting-outputs` to generate `.g.dart`

    AVOID:
    - Do NOT use real ad unit IDs — test IDs only
    - Do NOT handle credit awarding here — that's the Edge Function's job (Plan 4.2)
    - Do NOT add retry logic for failed ad loads beyond the automatic pre-load after show
    - Do NOT import `dart:io` directly in the service — use `defaultTargetPlatform` from `package:flutter/foundation.dart` instead (works on all platforms without import issues)
  </action>
  <verify>
    dart analyze lib/core/services/rewarded_ad_service.dart — zero errors
    test -f lib/core/services/rewarded_ad_service.g.dart
  </verify>
  <done>
    - `RewardedAdService` created with load/show/isAdLoaded API
    - Uses test ad unit IDs for both platforms
    - Auto-loads first ad on provider creation
    - Properly disposes ads to prevent memory leaks
    - Generated code compiles without errors
  </done>
</task>

## Success Criteria
- [ ] Android manifest contains AdMob App ID meta-data
- [ ] `MobileAds.instance.initialize()` called in `main.dart` before `runApp`
- [ ] `RewardedAdService` can load and show test rewarded ads
- [ ] Test ad unit IDs used (not production)
- [ ] `dart analyze` passes with zero errors on all modified/created files
- [ ] Code generation succeeds (`build_runner build`)
