import 'dart:io';

import 'package:artio/core/exceptions/app_exception.dart';
import 'package:artio/core/utils/retry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('retry', () {
    test('HandshakeException triggers retry', () async {
      var callCount = 0;
      final result = await retry(() async {
        callCount++;
        if (callCount < 3) {
          throw const HandshakeException('TLS error');
        }
        return 'success';
      }, initialDelay: const Duration(milliseconds: 1));

      expect(result, 'success');
      expect(callCount, 3);
    });

    test('AppException.network with statusCode 429 triggers retry', () async {
      var callCount = 0;
      final result = await retry(() async {
        callCount++;
        if (callCount < 2) {
          throw const AppException.network(
            message: 'Rate limited',
            statusCode: 429,
          );
        }
        return 'ok';
      }, initialDelay: const Duration(milliseconds: 1));

      expect(result, 'ok');
      expect(callCount, 2);
    });

    test('AppException.generation does NOT trigger retry', () async {
      var callCount = 0;
      await expectLater(
        retry(() async {
          callCount++;
          throw const AppException.generation(message: 'Gen failed');
        }, initialDelay: const Duration(milliseconds: 1)),
        throwsA(isA<AppException>()),
      );

      // Should be called only once — no retry
      expect(callCount, 1);
    });

    test('max attempts limit reached rethrows last error', () async {
      var callCount = 0;
      await expectLater(
        retry(
          () async {
            callCount++;
            throw const SocketException('Connection refused');
          },
          maxAttempts: 2,
          initialDelay: const Duration(milliseconds: 1),
        ),
        throwsA(isA<SocketException>()),
      );

      expect(callCount, 2);
    });
  });
}
