import '../../exceptions/app_exception.dart';

/// Maps [AppException] variants to user-friendly messages.
///
/// Usage:
/// ```dart
/// asyncValue.when(
///   error: (e, _) => Text(AppExceptionMapper.toUserMessage(e)),
///   // ...
/// )
/// ```
class AppExceptionMapper {
  AppExceptionMapper._(); // Private constructor, static methods only

  /// Converts an error to a user-displayable message.
  ///
  /// Handles all [AppException] variants with appropriate messages.
  /// Non-AppException errors get a generic fallback.
  static String toUserMessage(Object error) {
    if (error is! AppException) {
      return 'An unexpected error occurred. Please try again.';
    }

    return switch (error) {
      NetworkException(:final message, :final statusCode) =>
        _networkMessage(message, statusCode),
      AuthException(:final message) =>
        _authMessage(message),
      StorageException(:final message) =>
        message,
      PaymentException(:final message) =>
        _paymentMessage(message),
      GenerationException(:final message) =>
        message,
      UnknownException() =>
        'Something went wrong. Please try again.',
    };
  }

  static String _networkMessage(String message, int? statusCode) {
    return switch (statusCode) {
      404 => 'The requested resource was not found.',
      401 => 'Your session has expired. Please sign in again.',
      403 => 'You don\'t have permission for this action.',
      429 => 'Too many requests. Please wait a moment.',
      int status when status >= 500 && status < 600 => 'Server error. Please try again later.',
      _ => 'Connection error. Check your internet and try again.',
    };
  }

  static String _authMessage(String message) {
    final lower = message.toLowerCase();

    if (lower.contains('invalid') && lower.contains('credentials') ||
        lower.contains('invalid login credentials')) {
      return 'Invalid email or password.';
    }
    if (lower.contains('email') && lower.contains('taken') ||
        lower.contains('already registered')) {
      return 'This email is already registered. Try signing in.';
    }
    if (lower.contains('weak password') || lower.contains('password') && lower.contains('short')) {
      return 'Password must be at least 6 characters.';
    }
    if (lower.contains('rate limit') || lower.contains('too many')) {
      return 'Too many attempts. Please wait and try again.';
    }

    return 'Authentication failed. Please try again.';
  }

  static String _paymentMessage(String message) {
    final lower = message.toLowerCase();

    if (lower.contains('cancelled') || lower.contains('canceled')) {
      return 'Payment was cancelled.';
    }
    if (lower.contains('declined')) {
      return 'Payment was declined. Please try another method.';
    }

    return 'Payment could not be processed. Please try again.';
  }
}
