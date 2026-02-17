import 'package:artio/utils/logger_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'notifications_provider.g.dart';

@riverpod
class NotificationsNotifier extends _$NotificationsNotifier {
  static const _key = 'notifications_enabled';
  bool _hasUserToggled = false;

  @override
  bool build() => true;

  Future<void> setState(bool value) async {
    if (state == value) return;
    _hasUserToggled = true;
    state = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, value);
    } on Exception catch (e, st) {
      Log.e('Failed to save notification preference', e, st);
    }
  }

  Future<void> init() async {
    if (_hasUserToggled) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getBool(_key);
      if (value != null && !_hasUserToggled) {
        state = value;
      }
    } on Exception catch (e, st) {
      Log.e('Failed to load notification preference', e, st);
    }
  }
}
