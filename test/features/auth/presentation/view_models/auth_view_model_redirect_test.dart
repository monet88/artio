import 'dart:async';

import 'package:artio/features/auth/data/repositories/auth_repository.dart';
import 'package:artio/features/auth/domain/entities/user_model.dart';
import 'package:artio/features/auth/presentation/state/auth_state.dart';
import 'package:artio/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase
    show AuthState;

import '../../../../core/fixtures/fixtures.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('AuthViewModel.redirect', () {
    late _MockAuthRepository mockAuthRepo;
    late StreamController<supabase.AuthState> authStreamController;
    late ProviderContainer container;

    setUp(() {
      mockAuthRepo = _MockAuthRepository();
      authStreamController = StreamController<supabase.AuthState>.broadcast();
      when(() => mockAuthRepo.onAuthStateChange)
          .thenAnswer((_) => authStreamController.stream);
    });

    tearDown(() {
      container.dispose();
      authStreamController.close();
    });

    /// Creates a container and waits for the auth check to settle.
    Future<AuthViewModel> createSettledNotifier({
      UserModel? returningUser,
    }) async {
      when(() => mockAuthRepo.getCurrentUserWithProfile())
          .thenAnswer((_) async => returningUser);

      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepo),
        ],
      );

      // Listen to keep the provider alive and read state changes.
      final sub = container.listen(authViewModelProvider, (_, __) {});

      // Wait for _checkAuthentication to complete.
      // The build() calls _checkAuthentication asynchronously.
      // We pump until the state is no longer initial/authenticating.
      for (var i = 0; i < 20; i++) {
        await Future<void>.delayed(Duration.zero);
        final state = container.read(authViewModelProvider);
        if (state is! AuthStateInitial && state is! AuthStateAuthenticating) {
          break;
        }
      }

      sub.close();
      return container.read(authViewModelProvider.notifier);
    }

    group('when unauthenticated', () {
      test('splash redirects to /home', () async {
        final notifier = await createSettledNotifier(returningUser: null);
        expect(notifier.redirect(currentPath: '/'), '/home');
      });

      test('allows access to /home (no redirect)', () async {
        final notifier = await createSettledNotifier(returningUser: null);
        expect(notifier.redirect(currentPath: '/home'), isNull);
      });

      test('allows access to /create (no redirect)', () async {
        final notifier = await createSettledNotifier(returningUser: null);
        expect(notifier.redirect(currentPath: '/create'), isNull);
      });

      test('allows access to /settings (no redirect)', () async {
        final notifier = await createSettledNotifier(returningUser: null);
        expect(notifier.redirect(currentPath: '/settings'), isNull);
      });

      test('allows access to /gallery (no redirect)', () async {
        final notifier = await createSettledNotifier(returningUser: null);
        expect(notifier.redirect(currentPath: '/gallery'), isNull);
      });

      test('allows access to /login (no redirect)', () async {
        final notifier = await createSettledNotifier(returningUser: null);
        expect(notifier.redirect(currentPath: '/login'), isNull);
      });
    });

    group('when authenticated', () {
      test('splash redirects to /home', () async {
        final notifier = await createSettledNotifier(
          returningUser: UserFixtures.authenticated(),
        );
        expect(notifier.redirect(currentPath: '/'), '/home');
      });

      test('/login redirects to /home', () async {
        final notifier = await createSettledNotifier(
          returningUser: UserFixtures.authenticated(),
        );
        expect(notifier.redirect(currentPath: '/login'), '/home');
      });

      test('/register redirects to /home', () async {
        final notifier = await createSettledNotifier(
          returningUser: UserFixtures.authenticated(),
        );
        expect(notifier.redirect(currentPath: '/register'), '/home');
      });

      test('/forgot-password redirects to /home', () async {
        final notifier = await createSettledNotifier(
          returningUser: UserFixtures.authenticated(),
        );
        expect(
            notifier.redirect(currentPath: '/forgot-password'), '/home');
      });

      test('allows access to /home (no redirect)', () async {
        final notifier = await createSettledNotifier(
          returningUser: UserFixtures.authenticated(),
        );
        expect(notifier.redirect(currentPath: '/home'), isNull);
      });

      test('allows access to /create (no redirect)', () async {
        final notifier = await createSettledNotifier(
          returningUser: UserFixtures.authenticated(),
        );
        expect(notifier.redirect(currentPath: '/create'), isNull);
      });
    });

    group('when authenticating (initial/loading)', () {
      test('returns null for any route during auth check', () {
        // Don't let _checkAuthentication complete
        when(() => mockAuthRepo.getCurrentUserWithProfile())
            .thenAnswer((_) => Completer<UserModel?>().future);

        container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepo),
          ],
        );

        container.listen(authViewModelProvider, (_, __) {});
        final notifier = container.read(authViewModelProvider.notifier);

        // State is initial or authenticating — redirect should return null
        expect(notifier.redirect(currentPath: '/'), isNull);
        expect(notifier.redirect(currentPath: '/home'), isNull);
        expect(notifier.redirect(currentPath: '/login'), isNull);
      });
    });

    group('isLoggedIn getter', () {
      test('returns true when authenticated', () async {
        final notifier = await createSettledNotifier(
          returningUser: UserFixtures.authenticated(),
        );
        expect(notifier.isLoggedIn, isTrue);
      });

      test('returns false when unauthenticated', () async {
        final notifier = await createSettledNotifier(returningUser: null);
        expect(notifier.isLoggedIn, isFalse);
      });
    });
  });
}
