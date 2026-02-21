import 'package:artio/features/subscription/domain/entities/subscription_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SubscriptionStatus', () {
    test('isFree returns true when not active', () {
      const status = SubscriptionStatus();
      expect(status.isFree, isTrue);
      expect(status.isActive, isFalse);
      expect(status.isPro, isFalse);
      expect(status.isUltra, isFalse);
    });

    test('isFree returns true when active but no tier', () {
      const status = SubscriptionStatus(isActive: true);
      expect(status.isFree, isTrue);
    });

    test('isPro returns true for active pro subscription', () {
      const status = SubscriptionStatus(
        tier: 'pro',
        isActive: true,
        willRenew: true,
      );
      expect(status.isPro, isTrue);
      expect(status.isUltra, isFalse);
      expect(status.isFree, isFalse);
      expect(status.monthlyCredits, 200);
    });

    test('isUltra returns true for active ultra subscription', () {
      const status = SubscriptionStatus(
        tier: 'ultra',
        isActive: true,
        willRenew: true,
      );
      expect(status.isUltra, isTrue);
      expect(status.isPro, isFalse);
      expect(status.isFree, isFalse);
      expect(status.monthlyCredits, 500);
    });

    test('isPro returns false when not active', () {
      const status = SubscriptionStatus(tier: 'pro');
      expect(status.isPro, isFalse);
      expect(status.isFree, isTrue);
    });

    test('monthlyCredits returns 0 for free tier', () {
      const status = SubscriptionStatus();
      expect(status.monthlyCredits, 0);
    });

    test('expiresAt is correctly stored', () {
      final expires = DateTime(2026, 3);
      final status = SubscriptionStatus(
        tier: 'pro',
        isActive: true,
        expiresAt: expires,
      );
      expect(status.expiresAt, expires);
    });

    test('equality works correctly (Freezed)', () {
      const a = SubscriptionStatus(tier: 'pro', isActive: true);
      const b = SubscriptionStatus(tier: 'pro', isActive: true);
      const c = SubscriptionStatus(tier: 'ultra', isActive: true);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('fromJson/toJson roundtrip', () {
      final original = SubscriptionStatus(
        tier: 'ultra',
        isActive: true,
        expiresAt: DateTime.utc(2026, 6, 15),
        willRenew: true,
      );
      final json = original.toJson();
      final restored = SubscriptionStatus.fromJson(json);
      expect(restored, equals(original));
    });
  });
}
