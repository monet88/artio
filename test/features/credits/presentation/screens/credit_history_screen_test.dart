import 'package:artio/features/credits/domain/entities/credit_balance.dart';
import 'package:artio/features/credits/domain/entities/credit_transaction.dart';
import 'package:artio/features/credits/presentation/providers/credit_balance_provider.dart';
import 'package:artio/features/credits/presentation/providers/credit_history_provider.dart';
import 'package:artio/features/credits/presentation/screens/credit_history_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../core/helpers/pump_app.dart';

void main() {
  group('CreditHistoryScreen #59 – total balance header', () {
    testWidgets('shows Current Balance header with credit count', (
      tester,
    ) async {
      await tester.pumpApp(
        const CreditHistoryScreen(),
        overrides: [
          creditHistoryProvider().overrideWith((_) async => [_tx()]),
          creditBalanceNotifierProvider.overrideWith(_FakeBalance150.new),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.text('Current Balance'), findsOneWidget);
      expect(find.text('150 credits'), findsOneWidget);
    });

    testWidgets('shows transactions list below balance header', (tester) async {
      await tester.pumpApp(
        const CreditHistoryScreen(),
        overrides: [
          creditHistoryProvider().overrideWith(
            (_) async => [
              _tx(type: 'welcome_bonus', amount: 50),
              _tx(type: 'generation', amount: -10),
            ],
          ),
          creditBalanceNotifierProvider.overrideWith(_FakeBalance150.new),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.text('Current Balance'), findsOneWidget);
      expect(find.text('Welcome Bonus'), findsOneWidget);
      expect(find.text('Image Generated'), findsOneWidget);
    });

    testWidgets('shows empty state below header when no transactions', (
      tester,
    ) async {
      await tester.pumpApp(
        const CreditHistoryScreen(),
        overrides: [
          creditHistoryProvider().overrideWith(
            (_) async => <CreditTransaction>[],
          ),
          creditBalanceNotifierProvider.overrideWith(_FakeBalance150.new),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.text('Current Balance'), findsOneWidget);
      expect(find.text('No Transactions Yet'), findsOneWidget);
    });
  });
}

CreditTransaction _tx({String type = 'generation', int amount = -5}) =>
    CreditTransaction(
      id: 'txn-${DateTime.now().millisecondsSinceEpoch}',
      userId: 'test-user',
      type: type,
      amount: amount,
      createdAt: DateTime(2024, 3, 9),
    );

class _FakeBalance150 extends CreditBalanceNotifier {
  @override
  Stream<CreditBalance> build() => Stream.value(
    CreditBalance(userId: 'test-user', balance: 150, updatedAt: DateTime(2024)),
  );
}
