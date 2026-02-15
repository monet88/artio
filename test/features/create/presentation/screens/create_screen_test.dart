import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:artio/features/auth/presentation/state/auth_state.dart';
import 'package:artio/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:artio/features/create/presentation/create_screen.dart';
import 'package:artio/features/template_engine/domain/entities/generation_job_model.dart';
import 'package:artio/features/create/presentation/view_models/create_view_model.dart';
import '../../../../core/helpers/helpers.dart';

/// Stub AuthViewModel that returns [AuthState.unauthenticated()] without
/// touching Supabase.
class _StubAuthViewModel extends AuthViewModel {
  @override
  AuthState build() => const AuthState.unauthenticated();
}

/// Stub CreateViewModel that returns an initial [AsyncData(null)] state.
class _StubCreateViewModel extends CreateViewModel {
  @override
  AsyncValue<GenerationJobModel?> build() => const AsyncData(null);
}

void main() {
  /// Common overrides that prevent Supabase from being called.
  final testOverrides = <Override>[
    authViewModelProvider.overrideWith(() => _StubAuthViewModel()),
    createViewModelProvider.overrideWith(() => _StubCreateViewModel()),
  ];

  group('CreateScreen', () {
    testWidgets('renders create screen with core UI elements',
        (tester) async {
      await tester.pumpApp(
        const CreateScreen(),
        overrides: testOverrides,
      );
      await tester.pumpAndSettle();

      // Screen renders
      expect(find.byType(CreateScreen), findsOneWidget);

      // Has title in AppBar
      expect(find.text('Create'), findsOneWidget);

      // Has prompt section
      expect(find.text('Prompt'), findsOneWidget);

      // Has generate button
      expect(find.text('Generate'), findsOneWidget);
    });

    testWidgets('generate button disabled when prompt is empty',
        (tester) async {
      await tester.pumpApp(
        const CreateScreen(),
        overrides: testOverrides,
      );
      await tester.pumpAndSettle();

      // Find the FilledButton and verify it's disabled
      final generateButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Generate'),
      );
      expect(generateButton.onPressed, isNull);
    });

    testWidgets('does not show prompt error before user interaction',
        (tester) async {
      await tester.pumpApp(
        const CreateScreen(),
        overrides: testOverrides,
      );
      await tester.pumpAndSettle();

      // Should NOT show error text on initial render
      expect(
        find.text('Prompt must be at least 3 characters'),
        findsNothing,
      );
    });
  });
}
