import 'package:flutter_test/flutter_test.dart';
import 'package:artio/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/helpers/helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('ThemeModeNotifier', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initial theme is system', () {
      final container = createContainer();
      final theme = container.read(themeModeNotifierProvider);
      expect(theme, ThemeMode.system);
    });

    test('setThemeMode to dark updates state', () async {
      final container = createContainer();
      
      await container.read(themeModeNotifierProvider.notifier).setThemeMode(ThemeMode.dark);
      
      expect(container.read(themeModeNotifierProvider), ThemeMode.dark);
    });

    test('setThemeMode to light updates state', () async {
      final container = createContainer();
      
      await container.read(themeModeNotifierProvider.notifier).setThemeMode(ThemeMode.light);
      
      expect(container.read(themeModeNotifierProvider), ThemeMode.light);
    });

    test('setThemeMode to system updates state', () async {
      final container = createContainer();
      
      // First set to dark
      await container.read(themeModeNotifierProvider.notifier).setThemeMode(ThemeMode.dark);
      expect(container.read(themeModeNotifierProvider), ThemeMode.dark);
      
      // Then back to system
      await container.read(themeModeNotifierProvider.notifier).setThemeMode(ThemeMode.system);
      expect(container.read(themeModeNotifierProvider), ThemeMode.system);
    });

    test('theme changes persist across reads', () async {
      final container = createContainer();
      
      await container.read(themeModeNotifierProvider.notifier).setThemeMode(ThemeMode.dark);
      
      // Multiple reads should return same value
      expect(container.read(themeModeNotifierProvider), ThemeMode.dark);
      expect(container.read(themeModeNotifierProvider), ThemeMode.dark);
    });
  });
}
