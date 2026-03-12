// Tests for the purchaseRef fallback logic in SubscriptionRepository.purchase().
//
// The real implementation calls RC SDK statics (Purchases.purchase) which
// cannot be mocked in unit tests. These tests verify the pure Dart logic:
//   - Real orderId (GPA.xxx) → used as-is
//   - Empty orderId (free trial) → timestamp fallback format
//   - Fallback token format matches GPA validation regex in edge function
import 'package:flutter_test/flutter_test.dart';

/// Extracted pure logic from SubscriptionRepository.purchase()
/// so it can be tested without RC SDK dependencies.
String buildPurchaseRef(String rawToken, String productId, int timestampMs) {
  return rawToken.isNotEmpty
      ? rawToken
      : 'rc-$productId-$timestampMs';
}

/// GPA validation regex — mirrors isValidPurchaseToken() in edge function.
final _gpaRegex = RegExp(r'^GPA\.\d{4}-\d{4}-\d{4}-\d+$');
final _fallbackRegex =
    RegExp(r'^rc-artio_(ultra|pro)_[a-z]+-\d{10,13}$');

bool isValidPurchaseToken(String token) {
  return _gpaRegex.hasMatch(token) || _fallbackRegex.hasMatch(token);
}

void main() {
  group('buildPurchaseRef', () {
    test('uses real orderId when transactionIdentifier is non-empty', () {
      const orderId = 'GPA.1234-5678-9012-34567';
      final ref = buildPurchaseRef(orderId, 'artio_ultra_monthly', 0);
      expect(ref, equals(orderId));
    });

    test('uses timestamp fallback when transactionIdentifier is empty', () {
      const productId = 'artio_ultra_monthly';
      const ts = 1773322872759;
      final ref = buildPurchaseRef('', productId, ts);
      expect(ref, equals('rc-artio_ultra_monthly-1773322872759'));
    });

    test('fallback format uses productId correctly for pro tier', () {
      const productId = 'artio_pro_monthly';
      const ts = 1773300000000;
      final ref = buildPurchaseRef('', productId, ts);
      expect(ref, startsWith('rc-artio_pro_monthly-'));
      expect(ref, equals('rc-artio_pro_monthly-1773300000000'));
    });

    test('real orderId is never replaced even when fallback timestamp differs',
        () {
      const orderId = 'GPA.3347-3642-0945-30030';
      final ref1 = buildPurchaseRef(orderId, 'artio_ultra_monthly', 111);
      final ref2 = buildPurchaseRef(orderId, 'artio_ultra_monthly', 999);
      expect(ref1, equals(ref2));
      expect(ref1, equals(orderId));
    });
  });

  group('isValidPurchaseToken (mirrors edge function validation)', () {
    test('accepts real Google Play order ID format', () {
      expect(isValidPurchaseToken('GPA.1234-5678-9012-34567'), isTrue);
      expect(isValidPurchaseToken('GPA.3347-3642-0945-30030'), isTrue);
      expect(isValidPurchaseToken('GPA.3382-8927-4180-53692'), isTrue);
    });

    test('accepts rc- fallback token for ultra tier', () {
      expect(
        isValidPurchaseToken('rc-artio_ultra_monthly-1773322872759'),
        isTrue,
      );
    });

    test('accepts rc- fallback token for pro tier', () {
      expect(
        isValidPurchaseToken('rc-artio_pro_monthly-1773300000000'),
        isTrue,
      );
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

    test('rejects rc- token with unknown tier', () {
      expect(
        isValidPurchaseToken('rc-artio_gold_monthly-1773322872759'),
        isFalse,
      );
    });

    test('fallback from buildPurchaseRef passes validation', () {
      const productId = 'artio_ultra_monthly';
      const ts = 1773322872759;
      final ref = buildPurchaseRef('', productId, ts);
      expect(isValidPurchaseToken(ref), isTrue);
    });

    test('real orderId from buildPurchaseRef passes validation', () {
      const orderId = 'GPA.3347-3642-0945-30030';
      final ref = buildPurchaseRef(orderId, 'artio_ultra_monthly', 0);
      expect(isValidPurchaseToken(ref), isTrue);
    });
  });
}
