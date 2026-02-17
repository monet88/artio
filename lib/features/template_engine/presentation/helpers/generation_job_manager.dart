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
  String? _lastErrorSignature;

  /// Default timeout for generation jobs, in minutes.
  static const defaultTimeoutMinutes = 5;

  /// Subscribe to a job stream with timeout and error handling.
  ///
  /// Cancels any existing subscription before starting the new one.
  /// Automatically cancels the subscription when the job reaches a
  /// terminal state (completed or failed).
  void watchJob({
    required Stream<GenerationJobModel> jobStream,
    required void Function(GenerationJobModel) onData,
    required void Function(Object, StackTrace) onError,
    required void Function() onTimeout,
    int timeoutMinutes = defaultTimeoutMinutes,
  }) {
    cancel();

    _timeoutTimer = Timer(
      Duration(minutes: timeoutMinutes),
      () {
        cancel();
        onTimeout();
      },
    );

    _jobSubscription = jobStream.listen(
      (job) {
        onData(job);
        if (job.status == JobStatus.completed ||
            job.status == JobStatus.failed) {
          cancel();
        }
      },
      onError: (Object e, StackTrace st) async {
        await captureOnce(e, st);
        onError(e, st);
        cancel();
      },
    );
  }

  /// Cancel active subscription and timeout timer.
  void cancel() {
    _jobSubscription?.cancel();
    _jobSubscription = null;
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }

  /// Reset all state including error signature.
  void reset() {
    cancel();
    _lastErrorSignature = null;
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
