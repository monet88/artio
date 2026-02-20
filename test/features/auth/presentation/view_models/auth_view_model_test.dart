import 'dart:async';

import 'package:artio/features/auth/data/repositories/auth_repository.dart';
import 'package:artio/features/auth/domain/entities/user_model.dart';
import 'package:artio/features/auth/presentation/state/auth_state.dart';
import 'package:artio/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase
    show AuthChangeEvent, AuthState, Session;

import '../../../../core/fixtures/fixtures.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('AuthViewModel', () {
    // ── AuthState union tests ──────────────────────────────────────────
    group('AuthState', () {
      test('initial state is AuthStateInitial', () {
        const state = AuthState.initial();
        expect(state, isA<AuthStateInitial>());
      });

      test('authenticating state is AuthStateAuthenticating', () {
        const state = AuthState.authenticating();
        expect(state, isA<AuthStateAuthenticating>());
      });

      test('authenticated state contains user', () {
        final user = UserFixtures.authenticated();
        final state = AuthState.authenticated(user);

        expect(state, isA<AuthStateAuthenticated>());
        state.maybeMap(
          authenticated: (s) => expect(s.user, equals(user)),
          orElse: () => fail('Expected authenticated state'),
        );
      });

      test('unauthenticated state is AuthStateUnauthenticated', () {
        const state = AuthState.unauthenticated();
        expect(state, isA<AuthStateUnauthenticated>());
      });

      test('error state contains message', () {
        const state = AuthState.error('Something went wrong');

        expect(state, isA<AuthStateError>());
        state.maybeMap(
          error: (s) => expect(s.message, 'Something went wrong'),
          orElse: () => fail('Expected error state'),
        );
      });
    });

    group('state transitions', () {
      test('can transition from initial to authenticating', () {
        const initial = AuthState.initial();
        const authenticating = AuthState.authenticating();

        expect(initial, isA<AuthStateInitial>());
        expect(authenticating, isA<AuthStateAuthenticating>());
      });

      test('can transition from authenticating to authenticated', () {
        final user = UserFixtures.authenticated();
        const authenticating = AuthState.authenticating();
        final authenticated = AuthState.authenticated(user);

        expect(authenticating, isA<AuthStateAuthenticating>());
        expect(authenticated, isA<AuthStateAuthenticated>());
      });

      test('can transition from authenticating to error', () {
        const authenticating = AuthState.authenticating();
        const error = AuthState.error('Login failed');

        expect(authenticating, isA<AuthStateAuthenticating>());
        expect(error, isA<AuthStateError>());
      });

      test('can transition from authenticated to unauthenticated', () {
        final user = UserFixtures.authenticated();
        final authenticated = AuthState.authenticated(user);
        const unauthenticated = AuthState.unauthenticated();

        expect(authenticated, isA<AuthStateAuthenticated>());
        expect(unauthenticated, isA<AuthStateUnauthenticated>());
      });
    });

    group('maybeMap', () {
      test('maybeMap handles initial state', () {
        const state = AuthState.initial();
        final result = state.maybeMap(
          initial: (_) => 'initial',
          orElse: () => 'other',
        );
        expect(result, 'initial');
      });

      test('maybeMap handles authenticated state', () {
        final user = UserFixtures.authenticated();
        final state = AuthState.authenticated(user);
        final result = state.maybeMap(
          authenticated: (s) => s.user.email,
          orElse: () => 'other',
        );
        expect(result, user.email);
      });

      test('maybeMap uses orElse for unmatched states', () {
        const state = AuthState.unauthenticated();
        final result = state.maybeMap(
          authenticated: (_) => 'authenticated',
          orElse: () => 'fallback',
        );
        expect(result, 'fallback');
      });
    });

    group('map', () {
      test('map handles all states', () {
        final user = UserFixtures.authenticated();
        final states = [
          const AuthState.initial(),
          const AuthState.authenticating(),
          AuthState.authenticated(user),
          const AuthState.unauthenticated(),
          const AuthState.error('error'),
        ];

        final results = states
            .map((state) => state.map(
                  initial: (_) => 'initial',
                  authenticating: (_) => 'authenticating',
                  authenticated: (_) => 'authenticated',
                  unauthenticated: (_) => 'unauthenticated',
                  error: (_) => 'error',
                ))
            .toList();

        expect(results, [
          'initial',
          'authenticating',
          'authenticated',
          'unauthenticated',
          'error',
        ]);
      });
    });

    group('equality', () {
      test('same states are equal', () {
        const state1 = AuthState.initial();
        const state2 = AuthState.initial();
        expect(state1, equals(state2));
      });

      test('authenticated states with same user are equal', () {
        final user = UserFixtures.authenticated(id: 'user-123');
        final state1 = AuthState.authenticated(user);
        final state2 = AuthState.authenticated(user);
        expect(state1, equals(state2));
      });

      test('different states are not equal', () {
        const state1 = AuthState.initial();
        const state2 = AuthState.unauthenticated();
        expect(state1, isNot(equals(state2)));
      });

      test('error states with different messages are not equal', () {
        const state1 = AuthState.error('Error 1');
        const state2 = AuthState.error('Error 2');
        expect(state1, isNot(equals(state2)));
      });
    });

    // ── Behavioral tests ───────────────────────────────────────────────
    group('signInWithEmail validation', () {
      late _MockAuthRepository mockAuthRepo;
      late StreamController<supabase.AuthState> authStreamController;
      late ProviderContainer container;

      setUp(() {
        mockAuthRepo = _MockAuthRepository();
        authStreamController =
            StreamController<supabase.AuthState>.broadcast();
        when(() => mockAuthRepo.onAuthStateChange)
            .thenAnswer((_) => authStreamController.stream);
        // Let _checkAuthentication settle to unauthenticated
        when(() => mockAuthRepo.getCurrentUserWithProfile())
            .thenAnswer((_) async => null);
      });

      tearDown(() {
        container.dispose();
        authStreamController.close();
      });

      Future<AuthViewModel> createSettledNotifier() async {
        container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepo),
          ],
        );
        container.listen(authViewModelProvider, (_, __) {});
        // Wait for _checkAuthentication to settle
        for (var i = 0; i < 20; i++) {
          await Future<void>.delayed(Duration.zero);
          final state = container.read(authViewModelProvider);
          if (state is! AuthStateInitial &&
              state is! AuthStateAuthenticating) {
            break;
          }
        }
        return container.read(authViewModelProvider.notifier);
      }

      test('empty email sets error state', () async {
        final notifier = await createSettledNotifier();

        await notifier.signInWithEmail('', 'password123');

        final state = container.read(authViewModelProvider);
        expect(state, isA<AuthStateError>());
        expect(
          (state as AuthStateError).message,
          'Email is required',
        );
        verifyNever(
          () => mockAuthRepo.signInWithEmail(any(), any()),
        );
      });

      test('whitespace-only email sets error state', () async {
        final notifier = await createSettledNotifier();

        await notifier.signInWithEmail('   ', 'password123');

        final state = container.read(authViewModelProvider);
        expect(state, isA<AuthStateError>());
        expect(
          (state as AuthStateError).message,
          'Email is required',
        );
        verifyNever(
          () => mockAuthRepo.signInWithEmail(any(), any()),
        );
      });

      test('empty password sets error state', () async {
        final notifier = await createSettledNotifier();

        await notifier.signInWithEmail('test@example.com', '');

        final state = container.read(authViewModelProvider);
        expect(state, isA<AuthStateError>());
        expect(
          (state as AuthStateError).message,
          'Password is required',
        );
        verifyNever(
          () => mockAuthRepo.signInWithEmail(any(), any()),
        );
      });
    });

    group('signUpWithEmail validation', () {
      late _MockAuthRepository mockAuthRepo;
      late StreamController<supabase.AuthState> authStreamController;
      late ProviderContainer container;

      setUp(() {
        mockAuthRepo = _MockAuthRepository();
        authStreamController =
            StreamController<supabase.AuthState>.broadcast();
        when(() => mockAuthRepo.onAuthStateChange)
            .thenAnswer((_) => authStreamController.stream);
        when(() => mockAuthRepo.getCurrentUserWithProfile())
            .thenAnswer((_) async => null);
      });

      tearDown(() {
        container.dispose();
        authStreamController.close();
      });

      Future<AuthViewModel> createSettledNotifier() async {
        container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepo),
          ],
        );
        container.listen(authViewModelProvider, (_, __) {});
        for (var i = 0; i < 20; i++) {
          await Future<void>.delayed(Duration.zero);
          final state = container.read(authViewModelProvider);
          if (state is! AuthStateInitial &&
              state is! AuthStateAuthenticating) {
            break;
          }
        }
        return container.read(authViewModelProvider.notifier);
      }

      test('empty email sets error state', () async {
        final notifier = await createSettledNotifier();

        await notifier.signUpWithEmail('', 'password123');

        final state = container.read(authViewModelProvider);
        expect(state, isA<AuthStateError>());
        expect(
          (state as AuthStateError).message,
          'Email is required',
        );
        verifyNever(
          () => mockAuthRepo.signUpWithEmail(any(), any()),
        );
      });

      test('short password sets error state', () async {
        final notifier = await createSettledNotifier();

        await notifier.signUpWithEmail('test@example.com', '12345');

        final state = container.read(authViewModelProvider);
        expect(state, isA<AuthStateError>());
        expect(
          (state as AuthStateError).message,
          'Password must be at least 6 characters',
        );
        verifyNever(
          () => mockAuthRepo.signUpWithEmail(any(), any()),
        );
      });

      test('empty password sets error state', () async {
        final notifier = await createSettledNotifier();

        await notifier.signUpWithEmail('test@example.com', '');

        final state = container.read(authViewModelProvider);
        expect(state, isA<AuthStateError>());
        expect(
          (state as AuthStateError).message,
          'Password is required',
        );
        verifyNever(
          () => mockAuthRepo.signUpWithEmail(any(), any()),
        );
      });
    });

    group('signInWithGoogle OAuth timeout', () {
      test('sets error after 3-minute timeout', () {
        fakeAsync((async) {
          final mockAuthRepo = _MockAuthRepository();
          final authStreamController =
              StreamController<supabase.AuthState>.broadcast();
          when(() => mockAuthRepo.onAuthStateChange)
              .thenAnswer((_) => authStreamController.stream);
          when(() => mockAuthRepo.getCurrentUserWithProfile())
              .thenAnswer((_) async => null);
          // signInWithGoogle never completes
          when(() => mockAuthRepo.signInWithGoogle())
              .thenAnswer((_) => Completer<void>().future);

          final container = ProviderContainer(
            overrides: [
              authRepositoryProvider.overrideWithValue(mockAuthRepo),
            ],
          );
          container.listen(authViewModelProvider, (_, __) {});

          // Let _checkAuthentication settle
          async.elapse(const Duration(milliseconds: 100));

          final notifier =
              container.read(authViewModelProvider.notifier);

          // Trigger Google sign in
          notifier.signInWithGoogle();
          async.elapse(Duration.zero);

          // Verify authenticating state
          expect(
            container.read(authViewModelProvider),
            isA<AuthStateAuthenticating>(),
          );

          // Advance past 3-minute timeout
          async.elapse(const Duration(minutes: 3));

          // Verify error state
          final state = container.read(authViewModelProvider);
          expect(state, isA<AuthStateError>());
          expect(
            (state as AuthStateError).message,
            'Sign in timed out. Please try again.',
          );

          container.dispose();
          authStreamController.close();
        });
      });

      test('cancels timer on auth state change', () {
        fakeAsync((async) {
          final mockAuthRepo = _MockAuthRepository();
          final authStreamController =
              StreamController<supabase.AuthState>.broadcast();
          when(() => mockAuthRepo.onAuthStateChange)
              .thenAnswer((_) => authStreamController.stream);
          when(() => mockAuthRepo.getCurrentUserWithProfile())
              .thenAnswer((_) async => null);
          when(() => mockAuthRepo.signInWithGoogle())
              .thenAnswer((_) => Completer<void>().future);

          final container = ProviderContainer(
            overrides: [
              authRepositoryProvider.overrideWithValue(mockAuthRepo),
            ],
          );
          container.listen(authViewModelProvider, (_, __) {});

          // Let _checkAuthentication settle
          async.elapse(const Duration(milliseconds: 100));

          final notifier =
              container.read(authViewModelProvider.notifier);

          notifier.signInWithGoogle();
          async.elapse(Duration.zero);

          // Simulate auth state change (user signs in via OAuth callback)
          final user = UserFixtures.authenticated();
          when(() => mockAuthRepo.getCurrentUserWithProfile())
              .thenAnswer((_) async => user);

          // Push auth event — this cancels the timer
          authStreamController.add(
            supabase.AuthState(
              supabase.AuthChangeEvent.signedIn,
              _FakeSession(),
            ),
          );
          async.elapse(const Duration(milliseconds: 100));

          // Advance past 3-minute mark — should NOT trigger timeout
          async.elapse(const Duration(minutes: 3));

          // State should be authenticated, not error
          expect(
            container.read(authViewModelProvider),
            isA<AuthStateAuthenticated>(),
          );

          container.dispose();
          authStreamController.close();
        });
      });
    });
  });
}

/// Fake [supabase.Session] for triggering auth state changes in tests.
class _FakeSession extends Fake implements supabase.Session {}
