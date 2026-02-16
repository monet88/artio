import 'dart:async';
import 'dart:io';

/// Retries [action] with exponential backoff on transient errors.
///
/// Only retries on [SocketException] and [TimeoutException] by default.
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
  if (error is SocketException || error is TimeoutException) return true;
  final msg = error.toString().toLowerCase();
  return msg.contains('timeout') ||
      msg.contains('socket') ||
      msg.contains('connection');
}
