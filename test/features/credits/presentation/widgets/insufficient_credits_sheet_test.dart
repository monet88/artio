import 'package:artio/core/services/rewarded_ad_service.dart';
import 'package:artio/features/auth/presentation/state/auth_state.dart';
import 'package:artio/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:artio/features/credits/data/repositories/credit_repository.dart';
import 'package:artio/features/credits/presentation/widgets/insufficient_credits_sheet.dart';
import 'package:artio/features/subscription/data/repositories/subscription_repository.dart';
import 'package:artio/features/subscription/domain/entities/subscription_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCreditRepository extends Mock implements CreditRepository {}

class MockSubscriptionRepository extends Mock
    implements SubscriptionRepository {}

class MockRewardedAdService extends Mock implements RewardedAdService {}

class _FakeAuthViewModel extends AuthViewModel {
  @override
  AuthState build() => const AuthState.unauthenticated();
}

void main() {
  late MockCreditRepository mockCreditRepo;
  late MockSubscriptionRepository mockSubRepo;
  late MockRewardedAdService mockAdService;

  setUp(() {
    mockCreditRepo = MockCreditRepository();
    mockSubRepo = MockSubscriptionRepository();
    mockAdService = MockRewardedAdService();
  });

  Widget buildWidget({
    int currentBalance = 2,
    int requiredCredits = 5,
    SubscriptionStatus subStatus = const SubscriptionStatus(),
    int adsRemaining = 5,
    bool adLoaded = false,
  }) {
    when(() => mockSubRepo.getStatus()).thenAnswer((_) async => subStatus);
    when(
      () => mockCreditRepo.fetchAdsRemainingToday(),
    ).thenAnswer((_) async => adsRemaining);
    when(() => mockAdService.isAdLoaded).thenReturn(adLoaded);

    return ProviderScope(
      overrides: [
        subscriptionRepositoryProvider.overrideWithValue(mockSubRepo),
        creditRepositoryProvider.overrideWithValue(mockCreditRepo),
        rewardedAdServiceProvider.overrideWithValue(mockAdService),
        authViewModelProvider.overrideWith(_FakeAuthViewModel.new),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: InsufficientCreditsSheet(
              currentBalance: currentBalance,
              requiredCredits: requiredCredits,
            ),
          ),
        ),
      ),
    );
  }

  group('InsufficientCreditsSheet', () {
    testWidgets('shows credit deficit info', (tester) async {
      await tester.pumpWidget(buildWidget(requiredCredits: 10));
      await tester.pumpAndSettle();

      expect(find.text('Not enough credits'), findsOneWidget);
      expect(find.textContaining('costs 10 credits'), findsOneWidget);
      expect(find.textContaining('only have 2'), findsOneWidget);
    });

    testWidgets('free user sees Upgrade to Premium button', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Upgrade to Premium'), findsOneWidget);
    });

    testWidgets('subscriber sees Manage Subscription button', (tester) async {
      await tester.pumpWidget(
        buildWidget(
          subStatus: const SubscriptionStatus(tier: 'pro', isActive: true),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Manage Subscription'), findsOneWidget);
      expect(find.text('Upgrade to Premium'), findsNothing);
    });

    testWidgets('shows Dismiss button', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Dismiss'), findsOneWidget);
    });

    testWidgets('shows ad limit reached when no ads remaining', (tester) async {
      await tester.pumpWidget(buildWidget(adsRemaining: 0));
      await tester.pumpAndSettle();

      expect(find.text('Daily ad limit reached'), findsOneWidget);
    });
  });
}
