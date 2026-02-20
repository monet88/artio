import 'package:artio/core/exceptions/app_exception.dart';
import 'package:artio/core/providers/supabase_provider.dart';
import 'package:artio/core/services/rewarded_ad_service.dart';
import 'package:artio/features/credits/data/repositories/credit_repository.dart';
import 'package:artio/features/credits/presentation/providers/ad_reward_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockCreditRepository extends Mock implements CreditRepository {}

class MockRewardedAdService extends Mock implements RewardedAdService {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

void main() {
  late MockCreditRepository mockRepo;
  late MockRewardedAdService mockAdService;
  late MockSupabaseClient mockSupabase;
  late MockGoTrueClient mockAuth;
  late MockUser mockUser;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockCreditRepository();
    mockAdService = MockRewardedAdService();
    mockSupabase = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockUser = MockUser();

    when(() => mockRepo.fetchAdsRemainingToday())
        .thenAnswer((_) async => 8);
    when(() => mockSupabase.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.id).thenReturn('user-123');

    container = ProviderContainer(
      overrides: [
        creditRepositoryProvider.overrideWithValue(mockRepo),
        rewardedAdServiceProvider.overrideWithValue(mockAdService),
        supabaseClientProvider.overrideWithValue(mockSupabase),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('AdRewardNotifier', () {
    test('build() returns ads remaining from repository', () async {
      final remaining = await container.read(adRewardNotifierProvider.future);
      expect(remaining, 8);
      verify(() => mockRepo.fetchAdsRemainingToday()).called(1);
    });

    group('watchAdAndReward', () {
      test('throws when no ad is loaded', () async {
        // Wait for initial build
        await container.read(adRewardNotifierProvider.future);

        when(() => mockAdService.isAdLoaded).thenReturn(false);

        final notifier =
            container.read(adRewardNotifierProvider.notifier);

        await expectLater(
          notifier.watchAdAndReward(),
          throwsA(isA<AppException>()),
        );
      });

      test('throws when user dismisses ad early', () async {
        await container.read(adRewardNotifierProvider.future);

        when(() => mockAdService.isAdLoaded).thenReturn(true);
        when(() => mockRepo.requestAdNonce())
            .thenAnswer((_) async => 'nonce-abc');
        when(() => mockAdService.setServerSideVerification(
              userId: any(named: 'userId'),
              customData: any(named: 'customData'),
            )).thenAnswer((_) async {});
        when(() => mockAdService.showAd()).thenAnswer((_) async => false);

        final notifier =
            container.read(adRewardNotifierProvider.notifier);

        await expectLater(
          notifier.watchAdAndReward(),
          throwsA(isA<AppException>()),
        );

        verify(() => mockRepo.requestAdNonce()).called(1);
        verify(() => mockAdService.showAd()).called(1);
      });

      test('awards credits and returns result on success', () async {
        await container.read(adRewardNotifierProvider.future);

        when(() => mockAdService.isAdLoaded).thenReturn(true);
        when(() => mockRepo.requestAdNonce())
            .thenAnswer((_) async => 'nonce-abc');
        when(() => mockAdService.setServerSideVerification(
              userId: any(named: 'userId'),
              customData: any(named: 'customData'),
            )).thenAnswer((_) async {});
        when(() => mockAdService.showAd()).thenAnswer((_) async => true);
        when(() => mockRepo.rewardAdCredits(nonce: 'nonce-abc')).thenAnswer(
          (_) async =>
              (creditsAwarded: 5, newBalance: 55, adsRemaining: 7),
        );
        // After invalidation, build() is called again
        when(() => mockRepo.fetchAdsRemainingToday())
            .thenAnswer((_) async => 7);

        final notifier =
            container.read(adRewardNotifierProvider.notifier);

        final result = await notifier.watchAdAndReward();

        expect(result.creditsAwarded, 5);
        expect(result.newBalance, 55);
        expect(result.adsRemaining, 7);

        verify(() => mockRepo.requestAdNonce()).called(1);
        verify(() => mockAdService.setServerSideVerification(
              userId: 'user-123',
              customData: 'nonce-abc',
            )).called(1);
        verify(() => mockAdService.showAd()).called(1);
        verify(() => mockRepo.rewardAdCredits(nonce: 'nonce-abc')).called(1);
      });

      test('propagates server error from rewardAdCredits', () async {
        await container.read(adRewardNotifierProvider.future);

        when(() => mockAdService.isAdLoaded).thenReturn(true);
        when(() => mockRepo.requestAdNonce())
            .thenAnswer((_) async => 'nonce-abc');
        when(() => mockAdService.setServerSideVerification(
              userId: any(named: 'userId'),
              customData: any(named: 'customData'),
            )).thenAnswer((_) async {});
        when(() => mockAdService.showAd()).thenAnswer((_) async => true);
        when(() => mockRepo.rewardAdCredits(nonce: 'nonce-abc')).thenThrow(
          const AppException.payment(
            message: 'Daily ad limit reached (10/day)',
            code: 'daily_limit_reached',
          ),
        );

        final notifier =
            container.read(adRewardNotifierProvider.notifier);

        await expectLater(
          notifier.watchAdAndReward(),
          throwsA(isA<PaymentException>()),
        );
      });
    });
  });
}
