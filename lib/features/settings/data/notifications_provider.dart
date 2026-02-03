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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }

  Future<void> init() async {
    if (_hasUserToggled) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getBool(_key);
    if (value != null && !_hasUserToggled) {
      state = value;
    }
  }

}
