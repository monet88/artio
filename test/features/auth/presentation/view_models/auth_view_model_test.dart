import 'package:artio/features/auth/presentation/state/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../core/fixtures/fixtures.dart';

void main() {
  group('AuthViewModel', () {
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

        final results = states.map((state) => state.map(
          initial: (_) => 'initial',
          authenticating: (_) => 'authenticating',
          authenticated: (_) => 'authenticated',
          unauthenticated: (_) => 'unauthenticated',
          error: (_) => 'error',
        )).toList();

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
  });
}
