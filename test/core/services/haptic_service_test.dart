import 'package:artio/core/services/haptic_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HapticService', () {
    final hapticCalls = <String>[];

    setUp(() {
      hapticCalls.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            hapticCalls.add(call.arguments as String);
          }
          return null;
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    test('buttonTap triggers lightImpact', () async {
      HapticService.buttonTap();
      await Future<void>.delayed(Duration.zero);
      expect(hapticCalls, contains('HapticFeedbackType.lightImpact'));
    });

    test('toggle triggers lightImpact', () async {
      HapticService.toggle();
      await Future<void>.delayed(Duration.zero);
      expect(hapticCalls, contains('HapticFeedbackType.lightImpact'));
    });

    test('navigationTap triggers selectionClick', () async {
      HapticService.navigationTap();
      await Future<void>.delayed(Duration.zero);
      expect(hapticCalls, contains('HapticFeedbackType.selectionClick'));
    });

    test('taskComplete triggers mediumImpact', () async {
      HapticService.taskComplete();
      await Future<void>.delayed(Duration.zero);
      expect(hapticCalls, contains('HapticFeedbackType.mediumImpact'));
    });

    test('error triggers heavyImpact', () async {
      HapticService.error();
      await Future<void>.delayed(Duration.zero);
      expect(hapticCalls, contains('HapticFeedbackType.heavyImpact'));
    });

    test('destructive triggers heavyImpact', () async {
      HapticService.destructive();
      await Future<void>.delayed(Duration.zero);
      expect(hapticCalls, contains('HapticFeedbackType.heavyImpact'));
    });
  });
}
