import 'dart:async';

import 'package:artio/core/exceptions/app_exception.dart';
import 'package:artio/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthChangeEvent, AuthState;

import '../../../../core/fixtures/user_fixtures.dart';

// Mock the interface, NOT the implementation
class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  group('IAuthRepository', () {
    group('signInWithEmail', () {
      test('returns UserModel on successful sign in', () async {
        final expectedUser = UserFixtures.authenticated(
          id: 'user-123',
          email: 'test@example.com',
        );

        when(
          () => mockAuthRepository.signInWithEmail(
            'test@example.com',
            'password123',
          ),
        ).thenAnswer((_) async => expectedUser);

        final result = await mockAuthRepository.signInWithEmail(
          'test@example.com',
          'password123',
        );

        expect(result, equals(expectedUser));
        expect(result.email, equals('test@example.com'));
        verify(
          () => mockAuthRepository.signInWithEmail(
            'test@example.com',
            'password123',
          ),
        ).called(1);
      });

      test('throws AppException on invalid credentials', () async {
        when(
          () => mockAuthRepository.signInWithEmail(
            'test@example.com',
            'wrongpassword',
          ),
        ).thenThrow(
          const AppException.auth(message: 'Invalid login credentials'),
        );

        expect(
          () => mockAuthRepository.signInWithEmail(
            'test@example.com',
            'wrongpassword',
          ),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('signUpWithEmail', () {
      test('returns UserModel on successful sign up', () async {
        final expectedUser = UserFixtures.authenticated(
          id: 'new-user-456',
          email: 'newuser@example.com',
        );

        when(
          () => mockAuthRepository.signUpWithEmail(
            'newuser@example.com',
            'password123',
          ),
        ).thenAnswer((_) async => expectedUser);

        final result = await mockAuthRepository.signUpWithEmail(
          'newuser@example.com',
          'password123',
        );

        expect(result, equals(expectedUser));
        expect(result.id, equals('new-user-456'));
      });

      test('throws AppException when user already exists', () async {
        when(
          () => mockAuthRepository.signUpWithEmail(
            'existing@example.com',
            'password123',
          ),
        ).thenThrow(
          const AppException.auth(message: 'User already registered'),
        );

        expect(
          () => mockAuthRepository.signUpWithEmail(
            'existing@example.com',
            'password123',
          ),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('signOut', () {
      test('completes without error', () async {
        when(() => mockAuthRepository.signOut()).thenAnswer((_) async {});

        await expectLater(mockAuthRepository.signOut(), completes);

        verify(() => mockAuthRepository.signOut()).called(1);
      });
    });

    group('getCurrentUserWithProfile', () {
      test('returns UserModel when user is authenticated', () async {
        final expectedUser = UserFixtures.authenticated();

        when(
          () => mockAuthRepository.getCurrentUserWithProfile(),
        ).thenAnswer((_) async => expectedUser);

        final result = await mockAuthRepository.getCurrentUserWithProfile();

        expect(result, isNotNull);
        expect(result, equals(expectedUser));
      });

      test('returns null when user is not authenticated', () async {
        when(
          () => mockAuthRepository.getCurrentUserWithProfile(),
        ).thenAnswer((_) async => null);

        final result = await mockAuthRepository.getCurrentUserWithProfile();

        expect(result, isNull);
      });
    });

    group('refreshCurrentUser', () {
      test('returns refreshed UserModel', () async {
        final expectedUser = UserFixtures.authenticated(credits: 50);

        when(
          () => mockAuthRepository.refreshCurrentUser(),
        ).thenAnswer((_) async => expectedUser);

        final result = await mockAuthRepository.refreshCurrentUser();

        expect(result.credits, equals(50));
      });

      test('throws AppException when no user is authenticated', () async {
        when(
          () => mockAuthRepository.refreshCurrentUser(),
        ).thenThrow(const AppException.auth(message: 'No authenticated user'));

        expect(
          () => mockAuthRepository.refreshCurrentUser(),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('resetPassword', () {
      test('completes without error', () async {
        when(
          () => mockAuthRepository.resetPassword('test@example.com'),
        ).thenAnswer((_) async {});

        await expectLater(
          mockAuthRepository.resetPassword('test@example.com'),
          completes,
        );

        verify(
          () => mockAuthRepository.resetPassword('test@example.com'),
        ).called(1);
      });
    });

    group('onAuthStateChange', () {
      test('emits auth state changes', () async {
        final controller = StreamController<AuthState>();

        when(
          () => mockAuthRepository.onAuthStateChange,
        ).thenAnswer((_) => controller.stream);

        final stream = mockAuthRepository.onAuthStateChange;

        // Emit a mock auth state
        const mockAuthState = AuthState(AuthChangeEvent.signedIn, null);
        controller.add(mockAuthState);

        await expectLater(stream, emits(mockAuthState));

        await controller.close();
      });
    });

    group('signInWithGoogle', () {
      test('completes OAuth flow', () async {
        when(
          () => mockAuthRepository.signInWithGoogle(),
        ).thenAnswer((_) async {});

        await expectLater(mockAuthRepository.signInWithGoogle(), completes);
      });
    });

    group('signInWithApple', () {
      test('completes OAuth flow', () async {
        when(
          () => mockAuthRepository.signInWithApple(),
        ).thenAnswer((_) async {});

        await expectLater(mockAuthRepository.signInWithApple(), completes);
      });
    });
  });
}
