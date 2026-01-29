import 'package:flutter_test/flutter_test.dart';
import 'package:artio/exceptions/app_exception.dart';
import 'package:artio/core/utils/app_exception_mapper.dart';

void main() {
  group('AppExceptionMapper', () {
    group('toUserMessage', () {
      test('returns generic message for non-AppException errors', () {
        final error = Exception('Some random error');

        final message = AppExceptionMapper.toUserMessage(error);

        expect(message, 'An unexpected error occurred. Please try again.');
      });

      test('returns generic message for UnknownException', () {
        const error = UnknownException(message: 'Unknown error');

        final message = AppExceptionMapper.toUserMessage(error);

        expect(message, 'Something went wrong. Please try again.');
      });

      test('returns StorageException message directly', () {
        const error = StorageException(message: 'Storage quota exceeded');

        final message = AppExceptionMapper.toUserMessage(error);

        expect(message, 'Storage quota exceeded');
      });

      test('returns GenerationException message directly', () {
        const error = GenerationException(message: 'API timeout');

        final message = AppExceptionMapper.toUserMessage(error);

        expect(message, 'API timeout');
      });
    });

    group('NetworkException mapping', () {
      test('maps 404 to "not found" message', () {
        const error = NetworkException(
          message: 'Not found',
          statusCode: 404,
        );

        final message = AppExceptionMapper.toUserMessage(error);

        expect(message, 'The requested resource was not found.');
      });

      test('maps 401 to "session expired" message', () {
        const error = NetworkException(
          message: 'Unauthorized',
          statusCode: 401,
        );

        final message = AppExceptionMapper.toUserMessage(error);

        expect(message, 'Your session has expired. Please sign in again.');
      });

      test('maps 403 to "permission denied" message', () {
        const error = NetworkException(
          message: 'Forbidden',
          statusCode: 403,
        );

        final message = AppExceptionMapper.toUserMessage(error);

        expect(message, 'You don\'t have permission for this action.');
      });

      test('maps 429 to "rate limit" message', () {
        const error = NetworkException(
          message: 'Too many requests',
          statusCode: 429,
        );

        final message = AppExceptionMapper.toUserMessage(error);

        expect(message, 'Too many requests. Please wait a moment.');
      });

      test('maps 500+ to "server error" message', () {
        const error = NetworkException(
          message: 'Internal server error',
          statusCode: 500,
        );

        final message = AppExceptionMapper.toUserMessage(error);

        expect(message, 'Server error. Please try again later.');

        const error503 = NetworkException(
          message: 'Service unavailable',
          statusCode: 503,
        );

        final message503 = AppExceptionMapper.toUserMessage(error503);

        expect(message503, 'Server error. Please try again later.');
      });

      test('maps network errors without status code to "connection error"', () {
        const error = NetworkException(
          message: 'Network error',
          statusCode: null,
        );

        final message = AppExceptionMapper.toUserMessage(error);

        expect(message, 'Connection error. Check your internet and try again.');
      });

      test('maps other status codes to "connection error"', () {
        const error = NetworkException(
          message: 'Some error',
          statusCode: 418,
        );

        final message = AppExceptionMapper.toUserMessage(error);

        expect(message, 'Connection error. Check your internet and try again.');
      });
    });

    group('AuthException mapping', () {
      test('maps "invalid credentials" to friendly message', () {
        const error = AuthException(message: 'Invalid login credentials');

        final message = AppExceptionMapper.toUserMessage(error);

        expect(message, 'Invalid email or password.');
      });

      test('maps "email already taken" to friendly message', () {
        const error = AuthException(message: 'Email already taken');

        final message = AppExceptionMapper.toUserMessage(error);

        expect(message, 'This email is already registered. Try signing in.');
      });

      test('maps unknown auth errors to generic auth message', () {
        const error = AuthException(message: 'Password is too weak');

        final message = AppExceptionMapper.toUserMessage(error);

        expect(message, 'Authentication failed. Please try again.');
      });

      test('maps "rate limit" auth errors to friendly message', () {
        const error = AuthException(message: 'Rate limit exceeded');

        final message = AppExceptionMapper.toUserMessage(error);

        expect(message, 'Too many attempts. Please wait and try again.');
      });

      test('maps unknown auth errors to generic auth message', () {
        const error = AuthException(message: 'Some auth error');

        final message = AppExceptionMapper.toUserMessage(error);

        expect(message, 'Authentication failed. Please try again.');
      });
    });

    group('PaymentException mapping', () {
      test('maps "cancelled" payment to friendly message', () {
        const error = PaymentException(message: 'Payment cancelled by user');

        final message = AppExceptionMapper.toUserMessage(error);

        expect(message, 'Payment was cancelled.');
      });

      test('maps "declined" payment to friendly message', () {
        const error = PaymentException(message: 'Card declined');

        final message = AppExceptionMapper.toUserMessage(error);

        expect(message, 'Payment was declined. Please try another method.');
      });

      test('maps unknown payment errors to generic payment message', () {
        const error = PaymentException(message: 'Payment processing failed');

        final message = AppExceptionMapper.toUserMessage(error);

        expect(message, 'Payment could not be processed. Please try again.');
      });
    });
  });
}
