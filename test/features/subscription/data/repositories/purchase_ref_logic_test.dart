// Tests for the purchaseRef logic in SubscriptionRepository.purchase().
//
// The real implementation calls RC SDK statics (Purchases.purchase) which
// cannot be mocked in unit tests. These tests verify the pure Dart logic:
//   - Real orderId (GPA.xxx) → used as-is, verify-google-purchase is called
//   - Empty orderId (free trial) → skip verify, RC webhook handles credits
//   - GPA validation regex matches only real Google Play order IDs
//
// NOTE: rc- timestamp fallback was removed (security fix). Users could forge
// arbitrary timestamps to repeatedly claim credits. Empty orderId now skips
// the edge function call entirely; RC webhook (INITIAL_PURCHASE event)
// grants credits when Pub/Sub pipeline processes the purchase.
import 'package:flutter_test/flutter_test.dart';

/// Returns the orderId to send to verify-google-purchase, or null when the
/// edge function should be skipped (empty orderId = free trial case).
/// Mirrors logic in SubscriptionRepository.purchase().
String? buildPurchaseRef(String rawToken) {
  return rawToken.isNotEmpty ? rawToken : null;
}

/// GPA validation regex — mirrors isValidPurchaseToken() in edge function.
/// Only accepts real Google Play order IDs; rc- fallback removed for security.
final _gpaRegex = RegExp(r'^GPA\.\d{4}-\d{4}-\d{4}-\d+$');

bool isValidPurchaseToken(String token) {
  return _gpaRegex.hasMatch(token);
}

void main() {
  group('buildPurchaseRef', () {
    test('returns real orderId when transactionIdentifier is non-empty', () {
      const orderId = 'GPA.1234-5678-9012-34567';
      expect(buildPurchaseRef(orderId), equals(orderId));
    });

    test('returns null when transactionIdentifier is empty (free trial — skip verify)', () {
      expect(buildPurchaseRef(''), isNull);
    });

    test('real orderId is consistent across calls', () {
      const orderId = 'GPA.3347-3642-0945-30030';
      expect(buildPurchaseRef(orderId), equals(buildPurchaseRef(orderId)));
    });
  });

  group('isValidPurchaseToken (mirrors edge function validation)', () {
    test('accepts real Google Play order ID format', () {
      expect(isValidPurchaseToken('GPA.1234-5678-9012-34567'), isTrue);
      expect(isValidPurchaseToken('GPA.3347-3642-0945-30030'), isTrue);
      expect(isValidPurchaseToken('GPA.3382-8927-4180-53692'), isTrue);
    });

    test('rejects fake/arbitrary strings', () {
      expect(isValidPurchaseToken('fake-1'), isFalse);
      expect(isValidPurchaseToken('exploit-abc'), isFalse);
      expect(isValidPurchaseToken(''), isFalse);
      expect(isValidPurchaseToken('free-credits'), isFalse);
    });

    test('rejects GPA with wrong digit groups', () {
      expect(isValidPurchaseToken('GPA.123-456-789-0'), isFalse);
      expect(isValidPurchaseToken('GPA.12345-6789-0123-45678'), isFalse);
    });

    test('rejects rc- fallback tokens (removed: security risk)', () {
      // These were previously accepted but removed to prevent credit forgery.
      // Users could generate unique timestamps to repeatedly claim credits.
      expect(isValidPurchaseToken('rc-artio_ultra_monthly-1773322872759'), isFalse);
      expect(isValidPurchaseToken('rc-artio_pro_monthly-1773300000000'), isFalse);
    });

    test('real orderId from buildPurchaseRef passes validation', () {
      const orderId = 'GPA.3347-3642-0945-30030';
      final ref = buildPurchaseRef(orderId);
      expect(ref, isNotNull);
      expect(isValidPurchaseToken(ref!), isTrue);
    });

    test('null result from buildPurchaseRef means skip edge function call', () {
      // Empty orderId (free trial) → null → do NOT call verify-google-purchase
      expect(buildPurchaseRef(''), isNull);
    });
  });
}
