import 'package:flutter_test/flutter_test.dart';
import 'package:artio/features/auth/domain/entities/user_model.dart';
import '../../../../core/fixtures/fixtures.dart';

void main() {
  group('UserModel', () {
    group('creation', () {
      test('creates instance with required fields', () {
        const user = UserModel(id: '123', email: 'test@example.com');
        
        expect(user.id, '123');
        expect(user.email, 'test@example.com');
      });

      test('creates instance with all fields', () {
        final now = DateTime.now();
        final user = UserModel(
          id: '123',
          email: 'test@example.com',
          displayName: 'Test User',
          avatarUrl: 'https://example.com/avatar.png',
          credits: 100,
          isPremium: true,
          premiumExpiresAt: now,
          createdAt: now,
        );

        expect(user.id, '123');
        expect(user.email, 'test@example.com');
        expect(user.displayName, 'Test User');
        expect(user.avatarUrl, 'https://example.com/avatar.png');
        expect(user.credits, 100);
        expect(user.isPremium, true);
        expect(user.premiumExpiresAt, now);
        expect(user.createdAt, now);
      });

      test('has correct default values', () {
        const user = UserModel(id: '123', email: 'test@example.com');

        expect(user.displayName, isNull);
        expect(user.avatarUrl, isNull);
        expect(user.credits, 0);
        expect(user.isPremium, false);
        expect(user.premiumExpiresAt, isNull);
        expect(user.createdAt, isNull);
      });
    });

    group('JSON serialization', () {
      test('serializes to JSON correctly', () {
        const user = UserModel(
          id: '123',
          email: 'test@example.com',
          displayName: 'Test User',
          credits: 50,
          isPremium: true,
        );

        final json = user.toJson();

        expect(json['id'], '123');
        expect(json['email'], 'test@example.com');
        expect(json['displayName'], 'Test User');
        expect(json['credits'], 50);
        expect(json['isPremium'], true);
      });

      test('deserializes from JSON correctly', () {
        final json = {
          'id': '456',
          'email': 'json@example.com',
          'displayName': 'JSON User',
          'credits': 25,
          'isPremium': false,
        };

        final user = UserModel.fromJson(json);

        expect(user.id, '456');
        expect(user.email, 'json@example.com');
        expect(user.displayName, 'JSON User');
        expect(user.credits, 25);
        expect(user.isPremium, false);
      });

      test('handles null optional fields in JSON', () {
        final json = {
          'id': '789',
          'email': 'minimal@example.com',
        };

        final user = UserModel.fromJson(json);

        expect(user.id, '789');
        expect(user.email, 'minimal@example.com');
        expect(user.displayName, isNull);
        expect(user.avatarUrl, isNull);
      });

      test('roundtrip serialization preserves data', () {
        final original = UserFixtures.authenticated();
        final json = original.toJson();
        final restored = UserModel.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.email, original.email);
        expect(restored.displayName, original.displayName);
        expect(restored.credits, original.credits);
        expect(restored.isPremium, original.isPremium);
      });
    });

    group('copyWith', () {
      test('creates new instance with updated email', () {
        const original = UserModel(id: '123', email: 'old@example.com');
        final updated = original.copyWith(email: 'new@example.com');

        expect(updated.email, 'new@example.com');
        expect(updated.id, '123');
        expect(original.email, 'old@example.com');
      });

      test('creates new instance with updated credits', () {
        const original = UserModel(id: '123', email: 'test@example.com', credits: 10);
        final updated = original.copyWith(credits: 100);

        expect(updated.credits, 100);
        expect(original.credits, 10);
      });

      test('preserves unchanged fields', () {
        final original = UserFixtures.premium();
        final updated = original.copyWith(displayName: 'New Name');

        expect(updated.displayName, 'New Name');
        expect(updated.id, original.id);
        expect(updated.email, original.email);
        expect(updated.isPremium, original.isPremium);
        expect(updated.credits, original.credits);
      });
    });

    group('equality', () {
      test('equal instances have same hashCode', () {
        const user1 = UserModel(id: '123', email: 'test@example.com');
        const user2 = UserModel(id: '123', email: 'test@example.com');

        expect(user1, equals(user2));
        expect(user1.hashCode, equals(user2.hashCode));
      });

      test('different instances are not equal', () {
        const user1 = UserModel(id: '123', email: 'test@example.com');
        const user2 = UserModel(id: '456', email: 'test@example.com');

        expect(user1, isNot(equals(user2)));
      });

      test('instances with different fields are not equal', () {
        const user1 = UserModel(id: '123', email: 'test@example.com', credits: 10);
        const user2 = UserModel(id: '123', email: 'test@example.com', credits: 20);

        expect(user1, isNot(equals(user2)));
      });
    });

    group('fixtures', () {
      test('authenticated fixture creates valid user', () {
        final user = UserFixtures.authenticated();

        expect(user.id, isNotEmpty);
        expect(user.email, isNotEmpty);
        expect(user.displayName, isNotNull);
      });

      test('guest fixture creates guest user', () {
        final user = UserFixtures.guest();

        expect(user.id, 'guest-user-id');
        expect(user.credits, 0);
        expect(user.isPremium, false);
      });

      test('premium fixture creates premium user', () {
        final user = UserFixtures.premium();

        expect(user.isPremium, true);
        expect(user.premiumExpiresAt, isNotNull);
        expect(user.credits, greaterThan(0));
      });

      test('noCredits fixture creates user without credits', () {
        final user = UserFixtures.noCredits();

        expect(user.credits, 0);
        expect(user.isPremium, false);
      });
    });
  });
}
