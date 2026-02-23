import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'onboarding_provider.g.dart';

const _kOnboardingDoneKey = 'onboarding_done';

/// Returns [true] if the user has already completed onboarding.
/// Persisted across sessions via SharedPreferences.
@riverpod
Future<bool> onboardingDone(Ref ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_kOnboardingDoneKey) ?? false;
}

/// Marks onboarding as completed. Call when user taps "Get Started".
Future<void> markOnboardingDone() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_kOnboardingDoneKey, true);
}
