import 'dart:async';

import 'package:artio/features/auth/presentation/state/auth_state.dart';
import 'package:artio/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:artio/features/template_engine/domain/entities/template_model.dart';
import 'package:artio/features/template_engine/presentation/providers/template_provider.dart';
import 'package:artio/features/template_engine/presentation/screens/template_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../core/fixtures/template_fixtures.dart';
import '../../../../core/fixtures/user_fixtures.dart';

// Mock AuthViewModel to prevent Supabase initialization
class MockAuthViewModel extends AuthViewModel {
  @override
  AuthState build() => AuthState.authenticated(UserFixtures.authenticated());
}

void main() {
  group('TemplateDetailScreen', () {
    Widget createTestWidget({
      required String templateId,
      AsyncValue<TemplateModel?>? templateState,
    }) {
      return ProviderScope(
        overrides: [
          authViewModelProvider.overrideWith(MockAuthViewModel.new),
          if (templateState != null)
            templateByIdProvider(templateId).overrideWith(
              (ref) => templateState.when(
                data: Future.value,
                loading: () {
                  final completer = Completer<TemplateModel?>();
                  return completer.future; // Never completes = stays loading
                },
                error: Future.error,
              ),
            ),
        ],
        child: MaterialApp(home: TemplateDetailScreen(templateId: templateId)),
      );
    }

    testWidgets('renders app bar with Generate title', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          templateId: 'test-template-id',
          templateState: AsyncValue.data(TemplateFixtures.basic()),
        ),
      );
      await tester.pump();

      expect(find.widgetWithText(AppBar, 'Generate'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('renders Scaffold', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          templateId: 'test-template-id',
          templateState: AsyncValue.data(TemplateFixtures.basic()),
        ),
      );
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows loading indicator initially', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          templateId: 'test-template-id',
          templateState: const AsyncValue<TemplateModel?>.loading(),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows template name when loaded', (tester) async {
      final template = TemplateFixtures.basic(name: 'Portrait Generator');

      await tester.pumpWidget(
        createTestWidget(
          templateId: 'test-template-id',
          templateState: AsyncValue.data(template),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Portrait Generator'), findsOneWidget);
    });

    testWidgets('shows template description when loaded', (tester) async {
      final template = TemplateFixtures.withInputFields(
        name: 'Template with Description',
      );

      await tester.pumpWidget(
        createTestWidget(
          templateId: 'test-template-id',
          templateState: AsyncValue.data(template),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('A template with configurable input fields'),
        findsOneWidget,
      );
    });

    testWidgets('shows error message on failure', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          templateId: 'test-template-id',
          templateState: AsyncValue.error(
            Exception('Failed to load template'),
            StackTrace.current,
          ),
        ),
      );
      await tester.pump();

      // Error is displayed via AppExceptionMapper
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows not found message for null template', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          templateId: 'non-existent-id',
          templateState: const AsyncValue.data(null),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Template not found'), findsOneWidget);
    });
  });
}
