import 'package:artio/core/services/rewarded_ad_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RewardedAdService', () {
    test('isAdLoaded is false initially', () {
      final service = RewardedAdService();
      expect(service.isAdLoaded, isFalse);
      service.dispose();
    });

    test('isLoading is false initially', () {
      final service = RewardedAdService();
      expect(service.isLoading, isFalse);
      service.dispose();
    });

    test('showAd returns false when no ad is loaded', () async {
      final service = RewardedAdService();
      final result = await service.showAd();
      expect(result, isFalse);
      service.dispose();
    });

    test('extends ChangeNotifier', () {
      final service = RewardedAdService();
      expect(service, isA<ChangeNotifier>());
      service.dispose();
    });
  });
}
