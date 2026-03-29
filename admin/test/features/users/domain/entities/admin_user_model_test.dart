import 'package:artio_admin/features/users/domain/entities/admin_user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdminUserModel', () {
    group('fromJson', () {
      test('parses all required fields', () {
        final model = AdminUserModel.fromJson(_fullJson());

        expect(model.id, 'user-uuid-123');
        expect(model.email, 'test@example.com');
        expect(model.displayName, 'Test User');
        expect(model.role, 'user');
        expect(model.isPremium, true);
        expect(model.subscriptionTier, 'pro');
        expect(model.creditBalance, 150);
        expect(model.isBanned, false);
        expect(model.createdAt, isNotNull);
      });

      test('defaults isBanned to false when absent', () {
        final json = _minimalJson();
        json.remove('is_banned');
        expect(AdminUserModel.fromJson(json).isBanned, false);
      });

      test('defaults creditBalance to 0 when absent', () {
        final json = _minimalJson();
        json.remove('credit_balance');
        expect(AdminUserModel.fromJson(json).creditBalance, 0);
      });

      test('defaults isPremium to false when absent', () {
        final json = _minimalJson();
        json.remove('is_premium');
        expect(AdminUserModel.fromJson(json).isPremium, false);
      });

      test('displayName is null when absent', () {
        final json = _minimalJson();
        json.remove('display_name');
        expect(AdminUserModel.fromJson(json).displayName, isNull);
      });
    });

    group('tierBadgeLabel', () {
      test('returns tier when set', () {
        final model = AdminUserModel.fromJson(_minimalJson()
          ..['subscription_tier'] = 'ultra');
        expect(model.tierBadgeLabel, 'ULTRA');
      });

      test('returns FREE when tier is null', () {
        final json = _minimalJson();
        json.remove('subscription_tier');
        expect(AdminUserModel.fromJson(json).tierBadgeLabel, 'FREE');
      });
    });
  });
}

// -- Helpers --

Map<String, dynamic> _minimalJson() => {
  'id': 'user-uuid-123',
  'email': 'test@example.com',
  'role': 'user',
  'is_premium': false,
  'credit_balance': 0,
  'is_banned': false,
  'created_at': '2026-01-01T00:00:00.000Z',
};

Map<String, dynamic> _fullJson() => {
  'id': 'user-uuid-123',
  'email': 'test@example.com',
  'display_name': 'Test User',
  'role': 'user',
  'is_premium': true,
  'subscription_tier': 'pro',
  'credit_balance': 150,
  'is_banned': false,
  'created_at': '2026-01-01T00:00:00.000Z',
  'updated_at': '2026-03-01T00:00:00.000Z',
};
