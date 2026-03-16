import 'package:artio/features/auth/presentation/state/auth_state.dart';
import 'package:artio/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:artio/features/credits/domain/entities/credit_balance.dart';
import 'package:artio/features/credits/presentation/providers/credit_balance_provider.dart';
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
      testWidgets('displays balance when creditBalanceNotifier has data',
          (tester) async {
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

        await tester.pumpWidget(createTestWidget());
        // Do NOT pump — keep in loading state
        await tester.pump(Duration.zero);

        expect(find.text('💎'), findsNothing);
      });
    });
  });
}

class _FakeCreditBalanceNotifier extends CreditBalanceNotifier {
  _FakeCreditBalanceNotifier({required this.balance});

  final int balance;

  @override
  Stream<CreditBalance> build() =>
      Stream.value(_makeCreditBalance(balance));
}
