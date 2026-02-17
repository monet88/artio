import 'dart:async';
import 'dart:io';

import '../exceptions/app_exception.dart';

/// Retries [action] with exponential backoff on transient errors.
///
/// Only retries on [SocketException], [TimeoutException], and
/// [AppException.network] with status codes 408, 429, or 5xx.
Future<T> retry<T>(
  Future<T> Function() action, {
  int maxAttempts = 3,
  Duration initialDelay = const Duration(seconds: 1),
  bool Function(Object error)? retryIf,
}) async {
  for (var attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await action();
    } catch (e) {
      final shouldRetry = retryIf?.call(e) ?? _isTransient(e);
      if (!shouldRetry || attempt == maxAttempts) rethrow;
      await Future<void>.delayed(initialDelay * (1 << (attempt - 1)));
    }
  }
  throw StateError('Unreachable');
}

bool _isTransient(Object error) {
  if (error is SocketException || error is TimeoutException || error is HandshakeException) return true;
  if (error is AppException) {
    return error.mapOrNull(
          network: (e) {
            final code = e.statusCode;
            if (code == null) return true;
            return code == 408 || code == 429 || (code >= 500 && code < 600);
          },
        ) ??
        false;
  }
  return false;
}
