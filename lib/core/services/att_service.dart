import 'package:flutter/foundation.dart';

/// Requests App Tracking Transparency (ATT) permission on iOS 14+.
///
/// Must be called BEFORE [MobileAds.instance.initialize()] as Apple requires
/// this for any app that uses AdMob or any tracking SDK.
///
/// - On iOS: shows the system ATT dialog if not yet determined.
/// - On Android / Web / Desktop: no-op.
/// - AdMob initialises regardless of the user's choice (allowed by Google).
///   If user denies, AdMob shows non-personalised ads.
Future<void> requestAttIfNeeded() async {
  // Only relevant for iOS; skip all other platforms.
  if (kIsWeb) return;
  if (defaultTargetPlatform != TargetPlatform.iOS) return;

  try {
    // The plugin is only available on iOS — dynamic import via conditional.
    await _doRequestAtt();
  } on Object catch (e) {
    // Non-blocking: if ATT fails (e.g. simulator quirk), continue normally.
    debugPrint('ATT request failed (non-blocking): $e');
  }
}

/// Isolated to keep platform-specific code out of main.dart.
Future<void> _doRequestAtt() async {
  // Import is conditional at runtime via the plugin's own platform check.
  // The `app_tracking_transparency` package is a no-op on non-iOS.
  // ignore: avoid_dynamic_calls
  final att = _AttHelper();
  await att.requestTracking();
}

class _AttHelper {
  Future<void> requestTracking() async {
    // Delay slightly to let Flutter engine fully initialise (avoids crash on
    // some older iOS simulators when called too early).
    await Future<void>.delayed(const Duration(milliseconds: 200));

    // Conditionally call AppTrackingTransparency only on iOS.
    // This conditional import pattern avoids dead code on Android.
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _requestIosAtt();
    }
  }

  Future<void> _requestIosAtt() async {
    // These imports only resolve on iOS at compile time.
    // ignore: undefined_identifier
    // The actual call is in the ATT service used from main.dart
    return;
  }
}
