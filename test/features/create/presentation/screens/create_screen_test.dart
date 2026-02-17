import 'package:artio/features/auth/domain/entities/user_model.dart';
import 'package:artio/features/auth/presentation/state/auth_state.dart';
import 'package:artio/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:artio/features/create/presentation/create_screen.dart';
import 'package:artio/features/create/presentation/view_models/create_view_model.dart';
import 'package:artio/features/template_engine/domain/entities/generation_job_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../core/helpers/helpers.dart';

/// Stub AuthViewModel configurable auth state without touching Supabase.
class _StubAuthViewModel extends AuthViewModel {
  _StubAuthViewModel(this._state);

  final AuthState _state;

  @override
  AuthState build() => _state;
}

/// Stub CreateViewModel that returns an initial [AsyncData(null)] state.
class _StubCreateViewModel extends CreateViewModel {
  @override
  AsyncValue<GenerationJobModel?> build() => const AsyncData(null);
}

class _FailedCreateViewModel extends CreateViewModel {
  @override
  AsyncValue<GenerationJobModel?> build() =>
      const AsyncData(GenerationJobModel(
        id: 'job-failed',
        userId: 'user-1',
        templateId: 'free-text',
        prompt: 'A prompt',
        status: JobStatus.failed,
        errorMessage: 'Provider failed',
      ));
}

void main() {
  List<Override> buildOverrides({
    AuthState authState = const AuthState.unauthenticated(),
    CreateViewModel? createViewModel,
  }) {
    return <Override>[
      authViewModelProvider.overrideWith(() => _StubAuthViewModel(authState)),
      createViewModelProvider
          .overrideWith(() => createViewModel ?? _StubCreateViewModel()),
    ];
  }

  group('CreateScreen', () {
    testWidgets('renders create screen with core UI elements',
        (tester) async {
      await tester.pumpApp(
        const CreateScreen(),
        overrides: buildOverrides(),
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
        overrides: buildOverrides(),
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
        overrides: buildOverrides(),
      );
      await tester.pumpAndSettle();

      // Should NOT show error text on initial render
      expect(
        find.text('Prompt must be at least 3 characters'),
        findsNothing,
      );
      expect(
        find.text('Prompt must be at most 1000 characters'),
        findsNothing,
      );
    });

    testWidgets('shows auth gate bottom sheet for unauthenticated generate',
        (tester) async {
      await tester.pumpApp(
        const CreateScreen(),
        overrides: buildOverrides(),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).first,
        'Generate this image',
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Generate'));
      await tester.tap(find.widgetWithText(FilledButton, 'Generate'));
      await tester.pumpAndSettle();

      expect(find.text('Sign in to create'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('shows failed job feedback snackbar', (tester) async {
      const authenticatedState = AuthState.authenticated(
        UserModel(
          id: 'user-1',
          email: 'user@example.com',
        ),
      );

      await tester.pumpApp(
        const CreateScreen(),
        overrides: buildOverrides(
          authState: authenticatedState,
          createViewModel: _FailedCreateViewModel(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Provider failed'), findsOneWidget);
    });
  });
}
