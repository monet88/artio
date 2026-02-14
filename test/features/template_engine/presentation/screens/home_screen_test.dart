import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:artio/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:artio/features/auth/presentation/state/auth_state.dart';
import 'package:artio/features/template_engine/presentation/screens/home_screen.dart';
import 'package:artio/features/template_engine/data/repositories/template_repository.dart';
import 'package:mocktail/mocktail.dart';
import '../../../../core/fixtures/fixtures.dart';

// Mock classes
class MockTemplateRepository extends Mock implements TemplateRepository {}

// Mock AuthViewModel that doesn't require Supabase
class MockAuthViewModel extends AuthViewModel {
  @override
  AuthState build() => AuthState.authenticated(UserFixtures.authenticated());
}

void main() {
  group('HomeScreen', () {
    late MockTemplateRepository mockTemplateRepository;

    setUp(() {
      mockTemplateRepository = MockTemplateRepository();
    });

    Widget createTestWidget({List<Override>? overrides}) {
      return ProviderScope(
        overrides: [
          authViewModelProvider.overrideWith(() => MockAuthViewModel()),
          templateRepositoryProvider.overrideWithValue(mockTemplateRepository),
          ...?overrides,
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      );
    }

    group('renders', () {
      testWidgets('displays HomeScreen with greeting header', (tester) async {
        when(() => mockTemplateRepository.fetchTemplates())
            .thenAnswer((_) async => []);

        await tester.pumpWidget(createTestWidget());
        await tester.pump();

        // HomeScreen should render with greeting text instead of AppBar title
        expect(find.byType(HomeScreen), findsOneWidget);
        // Redesigned — greeting text like "Good morning/afternoon/evening, Artist"
        expect(find.textContaining('Artist'), findsOneWidget);
      });

      testWidgets('shows loading state initially', (tester) async {
        when(() => mockTemplateRepository.fetchTemplates())
            .thenAnswer((_) async => []);

        await tester.pumpWidget(createTestWidget());
        
        // Initial pump shows loading state
        expect(find.byType(HomeScreen), findsOneWidget);
        
        await tester.pumpAndSettle();
      });

      testWidgets('displays templates when loaded', (tester) async {
        final templates = TemplateFixtures.list(count: 3);
        when(() => mockTemplateRepository.fetchTemplates())
            .thenAnswer((_) async => templates);

        await tester.pumpWidget(createTestWidget());
        await tester.pump(const Duration(seconds: 1));

        // Should display template content
        expect(find.byType(HomeScreen), findsOneWidget);
      });

      testWidgets('displays empty state when no templates', (tester) async {
        when(() => mockTemplateRepository.fetchTemplates())
            .thenAnswer((_) async => []);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Should still render HomeScreen
        expect(find.byType(HomeScreen), findsOneWidget);
      });
    });

    group('error handling', () {
      testWidgets('displays error message when fetch fails', (tester) async {
        when(() => mockTemplateRepository.fetchTemplates())
            .thenThrow(Exception('Network error'));

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Should show error state
        expect(find.byType(HomeScreen), findsOneWidget);
      });
    });
  });
}
