import 'package:artio/features/credits/domain/entities/credit_balance.dart';
import 'package:artio/features/credits/presentation/providers/credit_balance_provider.dart';
import 'package:artio/features/settings/presentation/widgets/subscription_card.dart';
import 'package:artio/features/subscription/domain/entities/subscription_status.dart';
import 'package:artio/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../core/helpers/pump_app.dart';

void main() {
  group('SubscriptionCard', () {
    final freeOverrides = [
      subscriptionNotifierProvider.overrideWith(_FakeFreeSub.new),
      creditBalanceNotifierProvider.overrideWith(_FakeCreditBalance.new),
    ];

    final premiumOverrides = [
      subscriptionNotifierProvider.overrideWith(_FakePremiumSub.new),
      creditBalanceNotifierProvider.overrideWith(_FakeCreditBalance.new),
    ];

    final errorOverrides = [
      subscriptionNotifierProvider.overrideWith(_FakeErrorSub.new),
      creditBalanceNotifierProvider.overrideWith(_FakeCreditBalance.new),
    ];

    // ── #62: error state should NOT be blank ───────────────────────────────
    group('#62 – error state is not blank', () {
      testWidgets('shows error message on subscription error', (tester) async {
        await tester.pumpApp(
          const SubscriptionCard(isDark: true),
          overrides: errorOverrides,
        );
        await tester.pump();

        expect(
          find.text('Unable to load subscription info. Pull to refresh.'),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });
    });

    // ── #58: plan text should not overflow ─────────────────────────────────
    group('#58 – plan text overflow is handled', () {
      testWidgets('premium tier label renders with ellipsis overflow', (
        tester,
      ) async {
        await tester.pumpApp(
          const SubscriptionCard(isDark: true),
          overrides: premiumOverrides,
        );
        await tester.pumpAndSettle();

        final tierText = find.text('PRO Plan');
        expect(tierText, findsOneWidget);

        final textWidget = tester.widget<Text>(tierText);
        expect(textWidget.overflow, equals(TextOverflow.ellipsis));
      });

      testWidgets('renewal date text renders with ellipsis overflow', (
        tester,
      ) async {
        await tester.pumpApp(
          const SubscriptionCard(isDark: true),
          overrides: premiumOverrides,
        );
        await tester.pumpAndSettle();

        // Find renewal text via substring
        expect(find.textContaining('Renews'), findsOneWidget);
        final renewalWidget = tester.widget<Text>(
          find.textContaining('Renews'),
        );
        expect(renewalWidget.overflow, equals(TextOverflow.ellipsis));
      });
    });

    // ── Free plan display ──────────────────────────────────────────────────
    group('Free plan', () {
      testWidgets('shows Free Plan label and Upgrade button', (tester) async {
        await tester.pumpApp(
          const SubscriptionCard(isDark: true),
          overrides: freeOverrides,
        );
        await tester.pumpAndSettle();

        expect(find.text('Free Plan'), findsOneWidget);
        expect(find.text('Upgrade'), findsOneWidget);
        expect(find.text('42 credits'), findsOneWidget);
      });
    });

    // ── Premium plan display ───────────────────────────────────────────────
    group('Premium plan', () {
      testWidgets('shows tier label, renewal, and Manage button', (
        tester,
      ) async {
        await tester.pumpApp(
          const SubscriptionCard(isDark: true),
          overrides: premiumOverrides,
        );
        await tester.pumpAndSettle();

        expect(find.text('PRO Plan'), findsOneWidget);
        expect(find.text('Manage'), findsOneWidget);
        expect(find.textContaining('Renews'), findsOneWidget);
      });
    });
  });
}

// ── Fakes ──────────────────────────────────────────────────────────────────────

class _FakeFreeSub extends SubscriptionNotifier {
  @override
  Future<SubscriptionStatus> build() async => const SubscriptionStatus();
}

class _FakePremiumSub extends SubscriptionNotifier {
  @override
  Future<SubscriptionStatus> build() async => SubscriptionStatus(
    tier: 'pro',
    isActive: true,
    willRenew: true,
    expiresAt: DateTime(2026, 12, 31),
  );
}

class _FakeErrorSub extends SubscriptionNotifier {
  @override
  Future<SubscriptionStatus> build() async =>
      throw Exception('Subscription error');
}

class _FakeCreditBalance extends CreditBalanceNotifier {
  @override
  Stream<CreditBalance> build() => Stream.value(
    CreditBalance(userId: 'test-user', balance: 42, updatedAt: DateTime(2024)),
  );
}
