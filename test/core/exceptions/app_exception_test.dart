import 'package:artio/core/exceptions/app_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppException', () {
    group('NetworkException', () {
      test('stores message and optional statusCode', () {
        const e =
            AppException.network(message: 'timeout', statusCode: 504);
        expect(e.message, 'timeout');
        expect((e as NetworkException).statusCode, 504);
      });

      test('statusCode defaults to null', () {
        const e = AppException.network(message: 'offline');
        expect((e as NetworkException).statusCode, isNull);
      });
    });

    group('AuthException', () {
      test('stores message and optional code', () {
        const e = AppException.auth(
          message: 'Invalid token',
          code: 'invalid_token',
        );
        expect(e.message, 'Invalid token');
        expect((e as AuthException).code, 'invalid_token');
      });
    });

    group('StorageException', () {
      test('stores message only', () {
        const e = AppException.storage(message: 'Disk full');
        expect(e.message, 'Disk full');
      });
    });

    group('PaymentException', () {
      test('stores message and optional code', () {
        const e = AppException.payment(
          message: 'Purchase cancelled',
          code: 'user_cancelled',
        );
        expect(e.message, 'Purchase cancelled');
        expect((e as PaymentException).code, 'user_cancelled');
      });
    });

    group('GenerationException', () {
      test('stores message and optional jobId', () {
        const e = AppException.generation(
          message: 'Generation failed',
          jobId: 'job-123',
        );
        expect(e.message, 'Generation failed');
        expect((e as GenerationException).jobId, 'job-123');
      });
    });

    group('UnknownException', () {
      test('stores message and optional originalError', () {
        final inner = FormatException('bad');
        final e = AppException.unknown(
          message: 'Unexpected',
          originalError: inner,
        );
        expect(e.message, 'Unexpected');
        expect((e as UnknownException).originalError, inner);
      });
    });

    group('pattern matching', () {
      test('when matches correct variant', () {
        const exception = AppException.payment(
          message: 'fail',
          code: 'test',
        );

        final result = switch (exception) {
          NetworkException() => 'network',
          AuthException() => 'auth',
          StorageException() => 'storage',
          PaymentException() => 'payment',
          GenerationException() => 'generation',
          UnknownException() => 'unknown',
        };

        expect(result, 'payment');
      });

      test('all variants are valid Exception instances', () {
        final exceptions = <AppException>[
          const AppException.network(message: 'n'),
          const AppException.auth(message: 'a'),
          const AppException.storage(message: 's'),
          const AppException.payment(message: 'p'),
          const AppException.generation(message: 'g'),
          const AppException.unknown(message: 'u'),
        ];

        for (final e in exceptions) {
          expect(e, isA<Exception>());
          expect(e.message, isNotEmpty);
        }
      });
    });

    group('equality', () {
      test('same type and fields are equal', () {
        const a = AppException.network(message: 'err', statusCode: 500);
        const b = AppException.network(message: 'err', statusCode: 500);
        expect(a, equals(b));
      });

      test('different types are not equal', () {
        const a = AppException.network(message: 'err');
        const b = AppException.auth(message: 'err');
        expect(a, isNot(equals(b)));
      });
    });
  });
}
