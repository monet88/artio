import 'package:artio/features/settings/data/notifications_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('NotificationsNotifier', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('build returns true by default', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final value = container.read(notificationsNotifierProvider);
      expect(value, isTrue);
    });

    test('setState updates state to false', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(notificationsNotifierProvider.notifier);
      await notifier.setState(value: false);

      expect(container.read(notificationsNotifierProvider), isFalse);
    });

    test('setState persists to SharedPreferences', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(notificationsNotifierProvider.notifier);
      await notifier.setState(value: false);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('notifications_enabled'), isFalse);
    });

    test('setState with same value does nothing', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(notificationsNotifierProvider.notifier);
      // Default is true, setting to true again should be a no-op
      await notifier.setState(value: true);

      // State stays true
      expect(container.read(notificationsNotifierProvider), isTrue);
    });

    test('init loads from SharedPreferences when no user toggle',
        () async {
      SharedPreferences.setMockInitialValues({
        'notifications_enabled': false,
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(notificationsNotifierProvider.notifier);
      await notifier.init();

      expect(container.read(notificationsNotifierProvider), isFalse);
    });

    test('init does not overwrite user toggle', () async {
      SharedPreferences.setMockInitialValues({
        'notifications_enabled': false,
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier =
          container.read(notificationsNotifierProvider.notifier);
      // Toggle OFF first (state changes from true→false, sets _hasUserToggled)
      await notifier.setState(value: false);
      // Then toggle back ON (user explicitly chose ON)
      await notifier.setState(value: true);
      // init should not override user's explicit toggle
      await notifier.init();

      expect(container.read(notificationsNotifierProvider), isTrue);
    });
  });
}
