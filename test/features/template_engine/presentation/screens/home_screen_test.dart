import 'dart:async';

import 'package:artio/features/auth/presentation/state/auth_state.dart';
import 'package:artio/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:artio/features/credits/domain/entities/credit_balance.dart';
import 'package:artio/features/credits/presentation/providers/credit_balance_provider.dart';
import 'package:artio/features/subscription/domain/entities/subscription_status.dart';
import 'package:artio/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:artio/features/template_engine/data/repositories/template_repository.dart';
import 'package:artio/features/template_engine/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../core/fixtures/fixtures.dart';

// Mock classes
class MockTemplateRepository extends Mock implements TemplateRepository {}

// Mock AuthViewModel that doesn't require Supabase
class MockAuthViewModel extends AuthViewModel {
  @override
  AuthState build() => AuthState.authenticated(UserFixtures.authenticated());
}

CreditBalance _makeCreditBalance(int balance) => CreditBalance(
  userId: 'test-user',
  balance: balance,
  updatedAt: DateTime(2025),
);

void main() {
  group('HomeScreen', () {
    late MockTemplateRepository mockTemplateRepository;

    setUp(() {
      mockTemplateRepository = MockTemplateRepository();
    });

    Widget createTestWidget({List<Override>? overrides}) {
      return ProviderScope(
        overrides: [
          authViewModelProvider.overrideWith(MockAuthViewModel.new),
          templateRepositoryProvider.overrideWithValue(mockTemplateRepository),
          ...?overrides,
        ],
        child: const MaterialApp(home: HomeScreen()),
      );
    }

    group('renders', () {
      testWidgets('displays HomeScreen with greeting header', (tester) async {
        when(
          () => mockTemplateRepository.fetchTemplates(),
        ).thenAnswer((_) async => []);

        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // HomeScreen should render with greeting text instead of AppBar title
        expect(find.byType(HomeScreen), findsOneWidget);
        // Redesigned — greeting text like "Good morning/afternoon/evening"
        expect(find.text('Discover Templates'), findsOneWidget);
      });

      testWidgets('shows loading state initially', (tester) async {
        when(
          () => mockTemplateRepository.fetchTemplates(),
        ).thenAnswer((_) async => []);

        await tester.pumpWidget(createTestWidget());

        // Initial pump shows loading state
        expect(find.byType(HomeScreen), findsOneWidget);

        await tester.pumpAndSettle();
      });

      testWidgets('displays templates when loaded', (tester) async {
        final templates = TemplateFixtures.list(count: 3);
        when(
          () => mockTemplateRepository.fetchTemplates(),
        ).thenAnswer((_) async => templates);

        await tester.pumpWidget(createTestWidget());
        await tester.pump(const Duration(seconds: 1));

        // Should display template content
        expect(find.byType(HomeScreen), findsOneWidget);
      });

      testWidgets('displays empty state when no templates', (tester) async {
        when(
          () => mockTemplateRepository.fetchTemplates(),
        ).thenAnswer((_) async => []);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Should still render HomeScreen
        expect(find.byType(HomeScreen), findsOneWidget);
      });
    });

    group('error handling', () {
      testWidgets('displays error message when fetch fails', (tester) async {
        when(
          () => mockTemplateRepository.fetchTemplates(),
        ).thenThrow(Exception('Network error'));

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Should show error state
        expect(find.byType(HomeScreen), findsOneWidget);
      });
    });

    group('credit chip', () {
      testWidgets('displays balance when creditBalanceNotifier has data', (
        tester,
      ) async {
        when(
          () => mockTemplateRepository.fetchTemplates(),
        ).thenAnswer((_) async => []);

        await tester.pumpWidget(
          createTestWidget(
            overrides: [
              creditBalanceNotifierProvider.overrideWith(
                () => _FakeCreditBalanceNotifier(balance: 42),
              ),
            ],
          ),
        );
        await tester.pump();

        expect(find.text('42'), findsOneWidget);
        expect(find.text('💎'), findsOneWidget);
      });

      testWidgets('chip is hidden while balance is loading', (tester) async {
        when(
          () => mockTemplateRepository.fetchTemplates(),
        ).thenAnswer((_) async => []);

        await tester.pumpWidget(
          createTestWidget(
            overrides: [
              creditBalanceNotifierProvider.overrideWith(
                _NeverLoadingCreditBalanceNotifier.new,
              ),
            ],
          ),
        );
        // Single pump — stays in loading state because Completer never completes
        await tester.pump(Duration.zero);

        expect(find.text('💎'), findsNothing);
      });
    });

    group('_LowCreditBanner', () {
      testWidgets(
        'shows banner when balance < 20 and user is not a subscriber',
        (tester) async {
          when(
            () => mockTemplateRepository.fetchTemplates(),
          ).thenAnswer((_) async => []);

          await tester.pumpWidget(
            createTestWidget(
              overrides: [
                creditBalanceNotifierProvider.overrideWith(
                  () => _FakeCreditBalanceNotifier(balance: 5),
                ),
                subscriptionNotifierProvider.overrideWith(
                  () => _FakeSubscriptionNotifier(isActive: false),
                ),
              ],
            ),
          );
          await tester.pump();

          expect(find.text('⚡'), findsOneWidget);
          expect(find.text('Upgrade'), findsOneWidget);
          expect(find.textContaining('Only 5 credits left'), findsOneWidget);
        },
      );

      testWidgets(
        'hides banner when user is a subscriber even if balance < 20',
        (tester) async {
          when(
            () => mockTemplateRepository.fetchTemplates(),
          ).thenAnswer((_) async => []);

          await tester.pumpWidget(
            createTestWidget(
              overrides: [
                creditBalanceNotifierProvider.overrideWith(
                  () => _FakeCreditBalanceNotifier(balance: 5),
                ),
                subscriptionNotifierProvider.overrideWith(
                  () => _FakeSubscriptionNotifier(isActive: true),
                ),
              ],
            ),
          );
          await tester.pump();

          expect(find.text('⚡'), findsNothing);
          expect(find.text('Upgrade'), findsNothing);
        },
      );

      testWidgets('hides banner when balance >= 20', (tester) async {
        when(
          () => mockTemplateRepository.fetchTemplates(),
        ).thenAnswer((_) async => []);

        await tester.pumpWidget(
          createTestWidget(
            overrides: [
              creditBalanceNotifierProvider.overrideWith(
                () => _FakeCreditBalanceNotifier(balance: 20),
              ),
              subscriptionNotifierProvider.overrideWith(
                () => _FakeSubscriptionNotifier(isActive: false),
              ),
            ],
          ),
        );
        await tester.pump();

        expect(find.text('⚡'), findsNothing);
        expect(find.text('Upgrade'), findsNothing);
      });

      testWidgets('hides banner when balance is null (loading)', (
        tester,
      ) async {
        when(
          () => mockTemplateRepository.fetchTemplates(),
        ).thenAnswer((_) async => []);

        await tester.pumpWidget(
          createTestWidget(
            overrides: [
              creditBalanceNotifierProvider.overrideWith(
                _NeverLoadingCreditBalanceNotifier.new,
              ),
              subscriptionNotifierProvider.overrideWith(
                () => _FakeSubscriptionNotifier(isActive: false),
              ),
            ],
          ),
        );
        // Single pump — stays in loading state because Completer never completes
        await tester.pump(Duration.zero);

        expect(find.text('⚡'), findsNothing);
        expect(find.text('Upgrade'), findsNothing);
      });

      testWidgets('hides banner while subscription is loading', (tester) async {
        when(
          () => mockTemplateRepository.fetchTemplates(),
        ).thenAnswer((_) async => []);

        await tester.pumpWidget(
          createTestWidget(
            overrides: [
              // Low balance (5) so banner would appear if the loading guard
              // were removed — guarantees the guard is actually exercised.
              creditBalanceNotifierProvider.overrideWith(
                () => _FakeCreditBalanceNotifier(balance: 5),
              ),
              subscriptionNotifierProvider.overrideWith(
                _NeverLoadingSubscriptionNotifier.new,
              ),
            ],
          ),
        );
        // Single pump — stays in AsyncLoading because Completer never completes
        await tester.pump(Duration.zero);

        expect(find.text('⚡'), findsNothing);
        expect(find.text('Upgrade'), findsNothing);
      });
    });
  });
}

class _FakeCreditBalanceNotifier extends CreditBalanceNotifier {
  _FakeCreditBalanceNotifier({required this.balance});

  final int balance;

  @override
  Stream<CreditBalance> build() => Stream.value(_makeCreditBalance(balance));
}

class _NeverLoadingCreditBalanceNotifier extends CreditBalanceNotifier {
  @override
  Stream<CreditBalance> build() {
    // Completer that never completes → provider stays in AsyncLoading forever
    final completer = Completer<CreditBalance>();
    return completer.future.asStream();
  }
}

class _NeverLoadingSubscriptionNotifier extends SubscriptionNotifier {
  @override
  Future<SubscriptionStatus> build() {
    // Completer that never completes → provider stays in AsyncLoading forever
    return Completer<SubscriptionStatus>().future;
  }
}

class _FakeSubscriptionNotifier extends SubscriptionNotifier {
  _FakeSubscriptionNotifier({required this.isActive});

  final bool isActive;

  @override
  Future<SubscriptionStatus> build() async =>
      SubscriptionStatus(isActive: isActive);
}
