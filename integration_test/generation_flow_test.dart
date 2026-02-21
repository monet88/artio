import 'package:artio/features/auth/domain/entities/user_model.dart';
import 'package:artio/features/auth/presentation/state/auth_state.dart';
import 'package:artio/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:artio/features/template_engine/data/repositories/template_repository.dart';
import 'package:artio/features/template_engine/presentation/screens/home_screen.dart';
import 'package:artio/features/template_engine/presentation/screens/template_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTemplateRepository extends Mock implements TemplateRepository {}

class MockAuthViewModel extends AuthViewModel {
  @override
  AuthState build() => AuthState.authenticated(
    UserModel(
      id: 'test-user-id',
      email: 'test@example.com',
      createdAt: DateTime.now(),
    ),
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Generation Flow Integration Tests', () {
    late MockTemplateRepository mockRepository;

    setUp(() {
      mockRepository = MockTemplateRepository();
    });

    Widget createTestWidget({Widget? home}) {
      return ProviderScope(
        overrides: [
          authViewModelProvider.overrideWith(MockAuthViewModel.new),
          templateRepositoryProvider.overrideWithValue(mockRepository),
        ],
        child: MaterialApp(
          title: 'Artio Test',
          theme: ThemeData.light(useMaterial3: true),
          home: home ?? const HomeScreen(),
        ),
      );
    }

    testWidgets('home screen displays templates section', (tester) async {
      when(() => mockRepository.fetchTemplates()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Artio'), findsOneWidget);
    });

    testWidgets('template detail screen renders correctly', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          home: const TemplateDetailScreen(templateId: 'test-template'),
        ),
      );

      expect(find.text('Generate'), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('template detail shows loading state', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          home: const TemplateDetailScreen(templateId: 'test-template'),
        ),
      );

      // Initial state shows loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
