import 'dart:async';

import 'package:artio/core/exceptions/app_exception.dart';
import 'package:artio/features/auth/presentation/state/auth_state.dart';
import 'package:artio/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:artio/features/subscription/data/repositories/subscription_repository.dart';
import 'package:artio/features/subscription/domain/entities/subscription_package.dart';
import 'package:artio/features/subscription/domain/entities/subscription_status.dart';
import 'package:artio/features/subscription/domain/repositories/i_subscription_repository.dart';
import 'package:artio/features/subscription/presentation/screens/paywall_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../core/fixtures/fixtures.dart';

class MockSubscriptionRepository extends Mock
    implements ISubscriptionRepository, SubscriptionRepository {}

class MockAuthViewModel extends AuthViewModel {
  @override
  AuthState build() => AuthState.authenticated(UserFixtures.authenticated());
}

SubscriptionPackage _pkg({
  required String identifier,
  required double price,
  String? priceString,
}) => SubscriptionPackage(
  identifier: identifier,
  priceString: priceString ?? '\$$price',
  price: price,
  nativePackage: Object(),
);

void main() {
  setUpAll(() {
    registerFallbackValue(
      const SubscriptionPackage(
        identifier: 'fallback',
        priceString: r'$0.00',
        price: 0,
        nativePackage: Object(),
      ),
    );
  });

  group('PaywallScreen', () {
    late MockSubscriptionRepository mockRepo;

    setUp(() {
      mockRepo = MockSubscriptionRepository();
    });

    Widget buildWidget({
      SubscriptionStatus status = const SubscriptionStatus(),
      bool offeringsError = false,
      Completer<List<SubscriptionPackage>>? offeringsCompleter,
    }) {
      when(() => mockRepo.getStatus()).thenAnswer((_) async => status);
      when(() => mockRepo.getOfferings()).thenAnswer((_) async {
        if (offeringsCompleter != null) {
          return offeringsCompleter.future;
        }
        if (offeringsError) throw Exception('Network error');
        return [];
      });

      return ProviderScope(
        overrides: [
          authViewModelProvider.overrideWith(MockAuthViewModel.new),
          subscriptionRepositoryProvider.overrideWith((_) => mockRepo),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const PaywallScreen(),
                  ),
                ),
                child: const Text('Open Paywall'),
              ),
            ),
          ),
        ),
      );
    }

    /// Pumps the widget, taps 'Open Paywall', and settles to navigate.
    Future<void> pumpPaywall(
      WidgetTester tester, {
      SubscriptionStatus status = const SubscriptionStatus(),
      bool offeringsError = false,
      Completer<List<SubscriptionPackage>>? offeringsCompleter,
    }) async {
      await tester.pumpWidget(
        buildWidget(
          status: status,
          offeringsError: offeringsError,
          offeringsCompleter: offeringsCompleter,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open Paywall'));
      await tester.pumpAndSettle();
    }

    testWidgets('shows loading indicator while offerings load', (tester) async {
      final completer = Completer<List<SubscriptionPackage>>();

      await tester.pumpWidget(buildWidget(offeringsCompleter: completer));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open Paywall'));
      // Advance route transition without settling (would wait for completer)
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete to avoid pending future warning
      completer.complete([]);
      await tester.pumpAndSettle();
    });

    testWidgets('shows error state with retry button when offerings fail', (
      tester,
    ) async {
      await pumpPaywall(tester, offeringsError: true);

      expect(find.text('Unable to load subscription options'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('shows Free tier card when offerings load empty', (
      tester,
    ) async {
      await pumpPaywall(tester);

      expect(
        find.text('Free plan: 10 welcome credits + earn more by watching ads'),
        findsOneWidget,
      );
    });

    testWidgets('shows "Unlock Premium" hero title', (tester) async {
      await pumpPaywall(tester);

      expect(find.text('Unlock Premium'), findsOneWidget);
    });

    testWidgets('shows Restore button', (tester) async {
      await pumpPaywall(tester);

      expect(find.text('Restore'), findsOneWidget);
    });

    testWidgets('subscribe CTA asks user to select a plan when none selected', (
      tester,
    ) async {
      await pumpPaywall(tester);

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Select a plan above'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('restore shows "No previous purchases found" when inactive', (
      tester,
    ) async {
      when(
        () => mockRepo.restore(),
      ).thenAnswer((_) async => const SubscriptionStatus());

      await pumpPaywall(tester);

      await tester.tap(find.text('Restore'));
      await tester.pumpAndSettle();

      expect(
        find.text('No previous purchases found for this account.'),
        findsOneWidget,
      );
    });

    testWidgets('restore shows "Purchases restored!" when active', (
      tester,
    ) async {
      when(() => mockRepo.restore()).thenAnswer(
        (_) async => const SubscriptionStatus(isActive: true, tier: 'pro'),
      );

      await pumpPaywall(tester);

      await tester.tap(find.text('Restore'));
      await tester.pumpAndSettle();

      expect(find.text('✅ Purchases restored!'), findsOneWidget);
    });

    testWidgets('restore shows error snackbar when restore throws', (
      tester,
    ) async {
      when(() => mockRepo.restore()).thenThrow(Exception('Restore failed'));

      await pumpPaywall(tester);

      await tester.tap(find.text('Restore'));
      await tester.pumpAndSettle();

      expect(find.text('Restore failed. Please try again.'), findsOneWidget);
    });
  });

  group('auto-select recommended plan', () {
    late MockSubscriptionRepository mockRepo;

    setUp(() {
      mockRepo = MockSubscriptionRepository();
    });

    testWidgets(
      'auto-selects non-pro (ultra) plan when both pro and ultra available',
      (tester) async {
        final proMonthly = _pkg(identifier: 'artio_pro_monthly', price: 9.99);
        final ultraMonthly =
            _pkg(identifier: 'artio_ultra_monthly', price: 19.99);

        when(mockRepo.getStatus)
            .thenAnswer((_) async => const SubscriptionStatus());
        when(mockRepo.getOfferings)
            .thenAnswer((_) async => [proMonthly, ultraMonthly]);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              subscriptionRepositoryProvider.overrideWith((_) => mockRepo),
            ],
            child: const MaterialApp(home: PaywallScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Ultra (non-pro) is recommended → CTA should be active (Subscribe Now)
        expect(find.text('Subscribe Now'), findsOneWidget);
      },
    );

    testWidgets(
      'falls back to first package (pro) when all packages are pro',
      (tester) async {
        final proMonthly = _pkg(identifier: 'artio_pro_monthly', price: 9.99);
        final proYearly = _pkg(identifier: 'artio_pro_yearly', price: 79.99);

        when(mockRepo.getStatus)
            .thenAnswer((_) async => const SubscriptionStatus());
        when(mockRepo.getOfferings)
            .thenAnswer((_) async => [proMonthly, proYearly]);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              subscriptionRepositoryProvider.overrideWith((_) => mockRepo),
            ],
            child: const MaterialApp(home: PaywallScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // All pro → falls back to packages.first → CTA should be active
        expect(find.text('Subscribe Now'), findsOneWidget);
      },
    );
  });

  group('_handlePurchase', () {
    late MockSubscriptionRepository mockRepo;

    const ultraMonthly = SubscriptionPackage(
      identifier: 'artio_ultra_monthly',
      priceString: r'$19.99',
      price: 19.99,
      nativePackage: Object(),
    );

    setUp(() {
      mockRepo = MockSubscriptionRepository();
      when(() => mockRepo.getStatus())
          .thenAnswer((_) async => const SubscriptionStatus());
      when(() => mockRepo.getOfferings())
          .thenAnswer((_) async => [ultraMonthly]);
    });

    Widget buildPurchaseWidget() => ProviderScope(
          overrides: [
            authViewModelProvider.overrideWith(MockAuthViewModel.new),
            subscriptionRepositoryProvider.overrideWith((_) => mockRepo),
          ],
          child: const MaterialApp(home: PaywallScreen()),
        );

    testWidgets(
      'cancelled purchase shows no snackbar',
      (tester) async {
        when(() => mockRepo.purchase(any())).thenThrow(
          const AppException.payment(
            message: 'Cancelled by user',
            code: 'user_cancelled',
          ),
        );

        await tester.pumpWidget(buildPurchaseWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Subscribe Now'));
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsNothing);
      },
    );

    testWidgets(
      'non-cancel purchase error shows error snackbar',
      (tester) async {
        when(() => mockRepo.purchase(any())).thenThrow(
          const AppException.network(message: 'No internet connection'),
        );

        await tester.pumpWidget(buildPurchaseWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Subscribe Now'));
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsOneWidget);
      },
    );

    testWidgets(
      'purchase succeeds but subscription inactive shows warning snackbar',
      (tester) async {
        when(() => mockRepo.purchase(any()))
            .thenAnswer((_) async => const SubscriptionStatus());

        await tester.pumpWidget(buildPurchaseWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Subscribe Now'));
        await tester.pumpAndSettle();

        expect(
          find.text('Purchase processed. If credits are missing, tap Restore.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'purchase succeeds and active shows success snackbar',
      (tester) async {
        when(() => mockRepo.purchase(any())).thenAnswer(
          (_) async => const SubscriptionStatus(isActive: true, tier: 'ultra'),
        );

        // PaywallScreen calls Navigator.pop() on success — push it onto a
        // navigator stack so pop() returns to the parent instead of
        // destroying the route (which would dismiss the SnackBar).
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authViewModelProvider.overrideWith(MockAuthViewModel.new),
              subscriptionRepositoryProvider.overrideWith((_) => mockRepo),
            ],
            child: MaterialApp(
              home: Builder(
                builder: (context) => Scaffold(
                  body: ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const PaywallScreen(),
                      ),
                    ),
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Subscribe Now'));
        await tester.pumpAndSettle();

        expect(
          find.text('🎉 Subscription activated! Welcome to Premium.'),
          findsOneWidget,
        );
      },
    );
  });

  group('savingsPercent', () {
    final proMonthly = _pkg(identifier: 'artio_pro_monthly', price: 9.99);
    final proYearly = _pkg(identifier: 'artio_pro_yearly', price: 79.99);
    final ultraMonthly = _pkg(identifier: 'artio_ultra_monthly', price: 19.99);
    final ultraYearly = _pkg(identifier: 'artio_ultra_yearly', price: 159.99);
    final unknownYearly = _pkg(identifier: 'artio_legacy_yearly', price: 49.99);

    test('returns correct savings % for pro yearly vs monthly', () {
      final all = [proMonthly, proYearly];
      final result = savingsPercent(proYearly, all);
      // (9.99*12 - 79.99) / (9.99*12) * 100
      // = (119.88 - 79.99) / 119.88 * 100
      // = 39.89 / 119.88 * 100 ≈ 33.27 → rounds to 33
      expect(result, equals(33));
    });

    test('returns correct savings % for ultra yearly vs monthly', () {
      final all = [ultraMonthly, ultraYearly];
      final result = savingsPercent(ultraYearly, all);
      // (19.99*12 - 159.99) / (19.99*12) * 100
      // = (239.88 - 159.99) / 239.88 * 100
      // = 79.89 / 239.88 * 100 ≈ 33.30 → rounds to 33
      expect(result, equals(33));
    });

    test('returns null for monthly package (not yearly)', () {
      final all = [proMonthly, proYearly];
      expect(savingsPercent(proMonthly, all), isNull);
    });

    test('returns null when no monthly counterpart exists', () {
      // Only yearly in list — no monthly to compare against
      expect(savingsPercent(proYearly, [proYearly]), isNull);
    });

    test(
      'returns null for unknown tier even if identifier contains yearly',
      () {
        final all = [unknownYearly];
        expect(savingsPercent(unknownYearly, all), isNull);
      },
    );

    test('returns null when yearly price >= monthly*12 (no real savings)', () {
      // yearly priced at more than 12 months
      final expensiveYearly = _pkg(identifier: 'artio_pro_yearly', price: 200);
      final all = [proMonthly, expensiveYearly];
      expect(savingsPercent(expensiveYearly, all), isNull);
    });

    testWidgets(
      '"Save X%" badge is shown for yearly plan with monthly counterpart',
      (tester) async {
        final mockRepo = MockSubscriptionRepository();
        when(
          mockRepo.getStatus,
        ).thenAnswer((_) async => const SubscriptionStatus());
        when(
          mockRepo.getOfferings,
        ).thenAnswer((_) async => [proMonthly, proYearly]);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              subscriptionRepositoryProvider.overrideWith((_) => mockRepo),
            ],
            child: const MaterialApp(home: PaywallScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.textContaining('Save '), findsAtLeastNWidgets(1));
      },
    );

    testWidgets('no "Save X%" badge when only monthly packages are available', (
      tester,
    ) async {
      final mockRepo = MockSubscriptionRepository();
      when(
        mockRepo.getStatus,
      ).thenAnswer((_) async => const SubscriptionStatus());
      when(
        mockRepo.getOfferings,
      ).thenAnswer((_) async => [proMonthly, ultraMonthly]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            subscriptionRepositoryProvider.overrideWith((_) => mockRepo),
          ],
          child: const MaterialApp(home: PaywallScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Save '), findsNothing);
    });

    testWidgets('no crash when offerings list is empty', (tester) async {
      final mockRepo = MockSubscriptionRepository();
      when(
        mockRepo.getStatus,
      ).thenAnswer((_) async => const SubscriptionStatus());
      when(mockRepo.getOfferings).thenAnswer((_) async => []);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            subscriptionRepositoryProvider.overrideWith((_) => mockRepo),
          ],
          child: const MaterialApp(home: PaywallScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Should render without throwing
      expect(find.byType(PaywallScreen), findsOneWidget);
      expect(find.textContaining('Save '), findsNothing);
    });
  });
}
