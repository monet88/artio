import 'package:flutter/services.dart';

/// Centralized haptic feedback service for Artio.
///
/// Provides semantic haptic feedback methods for consistent tactile responses.
/// All methods are static — call directly without instantiation.
///
/// Usage:
/// ```dart
/// HapticService.buttonTap();       // Light for buttons
/// HapticService.generationDone();  // Medium for task completion
/// HapticService.navigationTap();   // Selection for tab switches
/// HapticService.error();           // Heavy for errors
/// ```
abstract class HapticService {
  // ── Button Interactions ──────────────────────────────────────────────
  /// Light impact — standard button taps, toggles, chip selections
  static void buttonTap() => HapticFeedback.lightImpact();

  /// Light impact — toggle switches, checkboxes
  static void toggle() => HapticFeedback.lightImpact();

  // ── Navigation ───────────────────────────────────────────────────────
  /// Selection click — tab bar taps, bottom nav, segment control
  static void navigationTap() => HapticFeedback.selectionClick();

  /// Selection click — swipe between pages, page indicator change
  static void pageTurn() => HapticFeedback.selectionClick();

  // ── Task Completion ──────────────────────────────────────────────────
  /// Medium impact — generation complete, download done, save success
  static void taskComplete() => HapticFeedback.mediumImpact();

  /// Alias for task completion — specifically for generation
  static void generationDone() => HapticFeedback.mediumImpact();

  /// Medium impact — download finished
  static void downloadComplete() => HapticFeedback.mediumImpact();

  // ── Feedback / Alerts ────────────────────────────────────────────────
  /// Heavy impact — error, failed action, destructive confirmation
  static void error() => HapticFeedback.heavyImpact();

  /// Medium impact — warning, caution
  static void warning() => HapticFeedback.mediumImpact();

  /// Light impact — info, subtle notification
  static void info() => HapticFeedback.lightImpact();

  // ── Gestures ─────────────────────────────────────────────────────────
  /// Light impact — long press start
  static void longPress() => HapticFeedback.lightImpact();

  /// Selection click — drag threshold reached
  static void dragThreshold() => HapticFeedback.selectionClick();

  /// Medium impact — pull-to-refresh trigger
  static void pullToRefresh() => HapticFeedback.mediumImpact();

  // ── Special ──────────────────────────────────────────────────────────
  /// Heavy impact — delete confirmation, destructive action
  static void destructive() => HapticFeedback.heavyImpact();

  /// Light impact — copy to clipboard
  static void copy() => HapticFeedback.lightImpact();

  /// Medium impact — share action triggered
  static void share() => HapticFeedback.mediumImpact();
}
