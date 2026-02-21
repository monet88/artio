import 'package:artio/core/config/env_config.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SentryConfig {
  static Future<void> init() async {
    if (EnvConfig.environment != 'production') return;

    await SentryFlutter.init((options) {
      options
        ..dsn = EnvConfig.sentryDsn
        ..tracesSampleRate = 0
        ..attachStacktrace = true
        ..environment = 'production';
    });
  }

  static Future<void> captureException(
    dynamic exception, {
    StackTrace? stackTrace,
  }) async {
    if (EnvConfig.environment != 'production') {
      return;
    }
    await Sentry.captureException(exception, stackTrace: stackTrace);
  }
}
