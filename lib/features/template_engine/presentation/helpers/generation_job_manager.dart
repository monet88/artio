import 'dart:async';
import 'package:artio/core/config/sentry_config.dart';
import 'package:artio/features/create/presentation/view_models/create_view_model.dart' show CreateViewModel;
import 'package:artio/features/template_engine/domain/entities/generation_job_model.dart';
import 'package:artio/features/template_engine/presentation/view_models/generation_view_model.dart' show GenerationViewModel;

/// Manages generation job subscriptions, timeouts, and error capture.
///
/// Shared between [CreateViewModel] and [GenerationViewModel] to eliminate
/// duplicated stream handling, timeout, and Sentry error capture logic.
class GenerationJobManager {
  StreamSubscription<GenerationJobModel>? _jobSubscription;
  Timer? _timeoutTimer;
  Timer? _retryTimer;
  String? _lastErrorSignature;
  int _retryCount = 0;

  /// Maximum retry attempts on stream errors before giving up.
  static const maxRetries = 3;

  /// Base delay between retries in milliseconds (multiplied by attempt number).
  static const retryDelayMs = 2000;

  /// Default timeout for generation jobs, in minutes.
  static const defaultTimeoutMinutes = 5;

  // Stored arguments for resubscription on retry.
  Stream<GenerationJobModel>? _lastJobStream;
  void Function(GenerationJobModel)? _lastOnData;
  void Function(Object, StackTrace)? _lastOnError;
  void Function()? _lastOnTimeout;
  int _lastTimeoutMinutes = defaultTimeoutMinutes;

  /// Subscribe to a job stream with timeout and error handling.
  ///
  /// Cancels any existing subscription before starting the new one.
  /// Automatically cancels the subscription when the job reaches a
  /// terminal state (completed or failed).
  /// Retries up to [maxRetries] times on stream errors with backoff.
  void watchJob({
    required Stream<GenerationJobModel> jobStream,
    required void Function(GenerationJobModel) onData,
    required void Function(Object, StackTrace) onError,
    required void Function() onTimeout,
    int timeoutMinutes = defaultTimeoutMinutes,
  }) {
    cancel();

    // Store for potential retry
    _lastJobStream = jobStream;
    _lastOnData = onData;
    _lastOnError = onError;
    _lastOnTimeout = onTimeout;
    _lastTimeoutMinutes = timeoutMinutes;
    _retryCount = 0;

    _startListening(jobStream, onData, onError, onTimeout, timeoutMinutes);
  }

  void _startListening(
    Stream<GenerationJobModel> jobStream,
    void Function(GenerationJobModel) onData,
    void Function(Object, StackTrace) onError,
    void Function() onTimeout,
    int timeoutMinutes,
  ) {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(
      Duration(minutes: timeoutMinutes),
      () {
        cancel();
        onTimeout();
      },
    );

    _jobSubscription?.cancel();
    _jobSubscription = jobStream.listen(
      (job) {
        // Successful data resets retry count
        _retryCount = 0;
        onData(job);
        if (job.status == JobStatus.completed ||
            job.status == JobStatus.failed) {
          cancel();
        }
      },
      onError: (Object e, StackTrace st) async {
        if (_retryCount < maxRetries) {
          _retryCount++;
          final delay = retryDelayMs * _retryCount;
          // ignore: avoid_print
          print(
            '[GenerationJobManager] Stream error, retrying '
            '($_retryCount/$maxRetries) in ${delay}ms...',
          );
          _jobSubscription?.cancel();
          _jobSubscription = null;
          _retryTimer = Timer(Duration(milliseconds: delay), () {
            _startListening(jobStream, onData, onError, onTimeout, timeoutMinutes);
          });
        } else {
          await captureOnce(e, st);
          onError(e, st);
          cancel();
        }
      },
    );
  }

  /// Cancel active subscription and timeout timer.
  void cancel() {
    _jobSubscription?.cancel();
    _jobSubscription = null;
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  /// Reset all state including error signature and retry count.
  void reset() {
    cancel();
    _lastErrorSignature = null;
    _retryCount = 0;
    _lastJobStream = null;
    _lastOnData = null;
    _lastOnError = null;
    _lastOnTimeout = null;
  }

  /// Clear current error dedup signature for a new generation attempt.
  void resetErrorDedup() {
    _lastErrorSignature = null;
  }

  /// Capture error to Sentry, deduplicating by error signature.
  ///
  /// Prevents the same error from being reported to Sentry multiple times
  /// within the same generation session.
  Future<void> captureOnce(Object error, StackTrace? stackTrace) async {
    final signature = '${error.runtimeType}:$error';
    if (_lastErrorSignature == signature) return;
    _lastErrorSignature = signature;
    await SentryConfig.captureException(error, stackTrace: stackTrace);
  }
}
