import 'package:flutter/material.dart';

/// Artio Design System — Animation Constants & Builders
///
/// Centralized animation tokens for consistent motion design.
/// All durations and curves are `const` for tree-shaking.
abstract class AppAnimations {
  // ── Duration Tokens ──────────────────────────────────────────────────
  /// 100ms — micro-interactions (icon state, opacity toggle)
  static const Duration micro = Duration(milliseconds: 100);

  /// 150ms — fast feedback (press, hover, small state changes)
  static const Duration fast = Duration(milliseconds: 150);

  /// 300ms — standard transitions (page, expand, slide)
  static const Duration normal = Duration(milliseconds: 300);

  /// 500ms — emphasis animations (splash, onboarding, celebration)
  static const Duration slow = Duration(milliseconds: 500);

  /// 800ms — dramatic animations (splash logo, first-time reveal)
  static const Duration xSlow = Duration(milliseconds: 800);

  /// 1200ms — very long animations (background ambient, shimmer cycle)
  static const Duration ambient = Duration(milliseconds: 1200);

  // ── Curve Tokens ─────────────────────────────────────────────────────
  /// Standard easing — most UI transitions
  static const Curve defaultCurve = Curves.easeOutCubic;

  /// Bounce — completion celebrations, badge pop-in
  static const Curve bounceCurve = Curves.elasticOut;

  /// Sharp — bottom sheets, dialogs (enters fast, settles slow)
  static const Curve sharpCurve = Curves.easeOutExpo;

  /// Gentle — background movements, ambient animations
  static const Curve gentleCurve = Curves.easeInOutSine;

  /// Deceleration — items coming to rest after user action
  static const Curve decelerateCurve = Curves.decelerate;

  // ── Stagger Delays ───────────────────────────────────────────────────
  /// Offset between staggered list/grid items
  static const Duration staggerDelay = Duration(milliseconds: 50);

  /// Max items to stagger (avoid long wait for large lists)
  static const int maxStaggerItems = 12;

  // ── Page Transition Builders ─────────────────────────────────────────

  /// Fade transition — used for tab switches and auth flow
  static Widget fadeTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: defaultCurve,
      ),
      child: child,
    );
  }

  /// Slide-up transition — used for detail screens / modals
  static Widget slideUpTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: sharpCurve,
    ));

    return SlideTransition(
      position: offsetAnimation,
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: defaultCurve,
        ),
        child: child,
      ),
    );
  }

  /// Fade-through — Material 3 style, used for auth flows
  static Widget fadeThroughTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.92, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: defaultCurve,
          ),
        ),
        child: child,
      ),
    );
  }

  /// Scale-fade — for dialogs and overlays
  static Widget scaleFadeTransitionBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: bounceCurve,
        ),
      ),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: defaultCurve,
        ),
        child: child,
      ),
    );
  }
}
