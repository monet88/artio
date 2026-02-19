import 'package:artio/core/exceptions/app_exception.dart';
import 'package:artio/features/subscription/data/repositories/subscription_repository.dart';
import 'package:artio/features/subscription/domain/entities/subscription_package.dart';
import 'package:artio/features/subscription/domain/entities/subscription_status.dart';
import 'package:artio/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSubscriptionRepository extends Mock
    implements SubscriptionRepository {}

void main() {
  late MockSubscriptionRepository mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockSubscriptionRepository();
    registerFallbackValue(const SubscriptionPackage(
      identifier: 'test',
      priceString: r'$0',
      nativePackage: 'native',
    ));
  });

  ProviderContainer createContainer({
    SubscriptionStatus initialStatus = const SubscriptionStatus(),
  }) {
    when(() => mockRepo.getStatus())
        .thenAnswer((_) async => initialStatus);

    return ProviderContainer(
      overrides: [
        subscriptionRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  }

  tearDown(() => container.dispose());

  group('SubscriptionNotifier', () {
    test('build() returns subscription status from repository', () async {
      const expected = SubscriptionStatus(tier: 'pro', isActive: true);
      container = createContainer(initialStatus: expected);

      final status =
          await container.read(subscriptionNotifierProvider.future);
      expect(status.isPro, isTrue);
      verify(() => mockRepo.getStatus()).called(1);
    });

    test('build() returns free status by default', () async {
      container = createContainer();

      final status =
          await container.read(subscriptionNotifierProvider.future);
      expect(status.isFree, isTrue);
    });

    group('purchase', () {
      test('updates state to loading then success', () async {
        container = createContainer();
        await container.read(subscriptionNotifierProvider.future);

        when(() => mockRepo.purchase(any())).thenAnswer(
          (_) async =>
              const SubscriptionStatus(tier: 'pro', isActive: true),
        );

        final notifier =
            container.read(subscriptionNotifierProvider.notifier);
        await notifier.purchase(const SubscriptionPackage(
          identifier: 'pro_monthly',
          priceString: r'$9.99',
          nativePackage: 'native',
        ));

        final state = container.read(subscriptionNotifierProvider);
        expect(state.value?.isPro, isTrue);
        verify(() => mockRepo.purchase(any())).called(1);
      });

      test('handles purchase error via AsyncValue.guard', () async {
        container = createContainer();
        await container.read(subscriptionNotifierProvider.future);

        when(() => mockRepo.purchase(any())).thenThrow(
          const AppException.payment(
            message: 'Purchase cancelled',
            code: 'user_cancelled',
          ),
        );

        final notifier =
            container.read(subscriptionNotifierProvider.notifier);
        await notifier.purchase(const SubscriptionPackage(
          identifier: 'pro',
          priceString: r'$9.99',
          nativePackage: 'native',
        ));

        final state = container.read(subscriptionNotifierProvider);
        expect(state.hasError, isTrue);
        expect(state.error, isA<PaymentException>());
      });
    });

    group('restore', () {
      test('updates state with restored subscription', () async {
        container = createContainer();
        await container.read(subscriptionNotifierProvider.future);

        when(() => mockRepo.restore()).thenAnswer(
          (_) async =>
              const SubscriptionStatus(tier: 'ultra', isActive: true),
        );

        final notifier =
            container.read(subscriptionNotifierProvider.notifier);
        await notifier.restore();

        final state = container.read(subscriptionNotifierProvider);
        expect(state.value?.isUltra, isTrue);
        verify(() => mockRepo.restore()).called(1);
      });

      test('handles restore error via AsyncValue.guard', () async {
        container = createContainer();
        await container.read(subscriptionNotifierProvider.future);

        when(() => mockRepo.restore()).thenThrow(
          const AppException.payment(
            message: 'Failed to restore',
            code: 'restore_error',
          ),
        );

        final notifier =
            container.read(subscriptionNotifierProvider.notifier);
        await notifier.restore();

        final state = container.read(subscriptionNotifierProvider);
        expect(state.hasError, isTrue);
      });
    });
  });

  group('offerings provider', () {
    test('returns list of packages from repository', () async {
      container = createContainer();

      when(() => mockRepo.getOfferings()).thenAnswer(
        (_) async => [
          const SubscriptionPackage(
            identifier: 'pro_monthly',
            priceString: r'$9.99/month',
            nativePackage: 'native',
          ),
        ],
      );

      final offerings = await container.read(offeringsProvider.future);
      expect(offerings, hasLength(1));
      expect(offerings.first.identifier, 'pro_monthly');
    });

    test('propagates error from repository', () async {
      container = createContainer();

      when(() => mockRepo.getOfferings()).thenThrow(
        const AppException.payment(message: 'Network error'),
      );

      expect(
        () => container.read(offeringsProvider.future),
        throwsA(isA<PaymentException>()),
      );
    });
  });
}
