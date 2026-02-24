import 'dart:async';

import 'package:artio/features/subscription/data/repositories/subscription_repository.dart';
import 'package:artio/features/subscription/domain/entities/subscription_package.dart';
import 'package:artio/features/subscription/domain/entities/subscription_status.dart';
import 'package:artio/features/subscription/presentation/screens/paywall_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSubscriptionRepository extends Mock
    implements SubscriptionRepository {}

void main() {
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
        overrides: [subscriptionRepositoryProvider.overrideWithValue(mockRepo)],
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
}
