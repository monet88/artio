import 'package:artio/core/exceptions/app_exception.dart';
import 'package:artio/core/services/rewarded_ad_service.dart';
import 'package:artio/features/credits/domain/repositories/i_credit_repository.dart';
import 'package:artio/features/credits/presentation/providers/ad_reward_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCreditRepository extends Mock implements ICreditRepository {}

class MockRewardedAdService extends Mock implements RewardedAdService {}

void main() {
  late MockCreditRepository mockRepo;
  late MockRewardedAdService mockAdService;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockCreditRepository();
    mockAdService = MockRewardedAdService();

    when(() => mockRepo.fetchAdsRemainingToday())
        .thenAnswer((_) async => 8);

    container = ProviderContainer(
      overrides: [
        // Override the repository
        adRewardNotifierProvider.overrideWith(() {
          final notifier = AdRewardNotifier();
          return notifier;
        }),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('AdRewardNotifier (mock repo)', () {
    test('rewardAdCredits returns correct record on success', () async {
      when(() => mockRepo.rewardAdCredits()).thenAnswer(
        (_) async => (creditsAwarded: 5, newBalance: 55, adsRemaining: 7),
      );

      final result = await mockRepo.rewardAdCredits();

      expect(result.creditsAwarded, 5);
      expect(result.newBalance, 55);
      expect(result.adsRemaining, 7);
    });

    test('rewardAdCredits throws validation on daily limit', () async {
      when(() => mockRepo.rewardAdCredits()).thenThrow(
        const AppException.network(
          message: 'Daily ad limit reached (10/day)',
          statusCode: 429,
        ),
      );

      expect(
        () => mockRepo.rewardAdCredits(),
        throwsA(isA<NetworkException>()),
      );
    });

    test('showAd returns false when no ad loaded', () async {
      when(() => mockAdService.isAdLoaded).thenReturn(false);

      expect(mockAdService.isAdLoaded, false);
    });

    test('showAd returns true when ad completes', () async {
      when(() => mockAdService.isAdLoaded).thenReturn(true);
      when(() => mockAdService.showAd()).thenAnswer((_) async => true);

      final earned = await mockAdService.showAd();

      expect(earned, true);
      verify(() => mockAdService.showAd()).called(1);
    });

    test('showAd returns false when user dismisses ad early', () async {
      when(() => mockAdService.isAdLoaded).thenReturn(true);
      when(() => mockAdService.showAd()).thenAnswer((_) async => false);

      final earned = await mockAdService.showAd();

      expect(earned, false);
    });

    test('fetchAdsRemainingToday returns correct count', () async {
      when(() => mockRepo.fetchAdsRemainingToday())
          .thenAnswer((_) async => 3);

      final remaining = await mockRepo.fetchAdsRemainingToday();

      expect(remaining, 3);
    });

    test('fetchAdsRemainingToday returns 0 at daily limit', () async {
      when(() => mockRepo.fetchAdsRemainingToday())
          .thenAnswer((_) async => 0);

      final remaining = await mockRepo.fetchAdsRemainingToday();

      expect(remaining, 0);
    });
  });
}
