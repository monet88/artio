import 'package:artio/core/exceptions/app_exception.dart';
import 'package:artio/features/subscription/domain/entities/subscription_package.dart';
import 'package:artio/features/subscription/domain/entities/subscription_status.dart';
import 'package:artio/features/subscription/domain/repositories/i_subscription_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

/// Mock the interface so we can test the provider's state machine
/// without calling RevenueCat SDK statics.
class MockSubscriptionRepository extends Mock
    implements ISubscriptionRepository {}

void main() {
  group('ISubscriptionRepository contract', () {
    late MockSubscriptionRepository mockRepo;

    setUp(() {
      mockRepo = MockSubscriptionRepository();
      registerFallbackValue(
        const SubscriptionPackage(
          identifier: 'test',
          priceString: r'$0',
          nativePackage: 'native',
        ),
      );
    });

    test('getStatus returns free status for non-subscriber', () async {
      when(
        () => mockRepo.getStatus(),
      ).thenAnswer((_) async => const SubscriptionStatus());

      final status = await mockRepo.getStatus();
      expect(status.isFree, isTrue);
      expect(status.isActive, isFalse);
      expect(status.tier, isNull);
    });

    test('getStatus returns active pro status', () async {
      when(() => mockRepo.getStatus()).thenAnswer(
        (_) async => const SubscriptionStatus(
          tier: 'pro',
          isActive: true,
          willRenew: true,
        ),
      );

      final status = await mockRepo.getStatus();
      expect(status.isPro, isTrue);
      expect(status.isActive, isTrue);
      expect(status.willRenew, isTrue);
    });

    test('getStatus returns active ultra status', () async {
      when(() => mockRepo.getStatus()).thenAnswer(
        (_) async => SubscriptionStatus(
          tier: 'ultra',
          isActive: true,
          expiresAt: DateTime.utc(2026, 6),
        ),
      );

      final status = await mockRepo.getStatus();
      expect(status.isUltra, isTrue);
      expect(status.expiresAt, DateTime.utc(2026, 6));
    });

    test('getStatus throws AppException.payment on SDK error', () async {
      when(() => mockRepo.getStatus()).thenThrow(
        const AppException.payment(
          message: 'Failed to get subscription status',
          code: 'network_error',
        ),
      );

      expect(() => mockRepo.getStatus(), throwsA(isA<PaymentException>()));
    });

    test('getOfferings returns parsed packages', () async {
      when(() => mockRepo.getOfferings()).thenAnswer(
        (_) async => [
          const SubscriptionPackage(
            identifier: 'pro_monthly',
            priceString: r'$9.99/month',
            nativePackage: 'native_pkg_1',
          ),
          const SubscriptionPackage(
            identifier: 'ultra_monthly',
            priceString: r'$19.99/month',
            nativePackage: 'native_pkg_2',
          ),
        ],
      );

      final offerings = await mockRepo.getOfferings();
      expect(offerings, hasLength(2));
      expect(offerings[0].identifier, 'pro_monthly');
      expect(offerings[1].priceString, r'$19.99/month');
    });

    test('getOfferings returns empty list when no current offering', () async {
      when(() => mockRepo.getOfferings()).thenAnswer((_) async => []);

      final offerings = await mockRepo.getOfferings();
      expect(offerings, isEmpty);
    });

    test('purchase returns updated status on success', () async {
      when(() => mockRepo.purchase(any())).thenAnswer(
        (_) async => const SubscriptionStatus(
          tier: 'pro',
          isActive: true,
          willRenew: true,
        ),
      );

      final result = await mockRepo.purchase(
        const SubscriptionPackage(
          identifier: 'pro_monthly',
          priceString: r'$9.99',
          nativePackage: 'native',
        ),
      );

      expect(result.isPro, isTrue);
      expect(result.isActive, isTrue);
    });

    test('purchase throws user_cancelled on cancellation', () async {
      when(() => mockRepo.purchase(any())).thenThrow(
        const AppException.payment(
          message: 'Purchase cancelled',
          code: 'user_cancelled',
        ),
      );

      expect(
        () => mockRepo.purchase(
          const SubscriptionPackage(
            identifier: 'pro',
            priceString: r'$9.99',
            nativePackage: 'native',
          ),
        ),
        throwsA(
          isA<PaymentException>().having(
            (e) => e.code,
            'code',
            'user_cancelled',
          ),
        ),
      );
    });

    test('restore returns updated status', () async {
      when(() => mockRepo.restore()).thenAnswer(
        (_) async => const SubscriptionStatus(tier: 'ultra', isActive: true),
      );

      final status = await mockRepo.restore();
      expect(status.isUltra, isTrue);
    });

    test('restore throws on failure', () async {
      when(() => mockRepo.restore()).thenThrow(
        const AppException.payment(
          message: 'Failed to restore purchases',
          code: 'restore_error',
        ),
      );

      expect(() => mockRepo.restore(), throwsA(isA<PaymentException>()));
    });
  });
}
