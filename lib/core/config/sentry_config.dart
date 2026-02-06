import 'package:sentry_flutter/sentry_flutter.dart';

import 'env_config.dart';

class SentryConfig {
  static Future<void> init() async {
    if (EnvConfig.environment != 'production') return;

    await SentryFlutter.init(
      (options) {
        options.dsn = EnvConfig.sentryDsn;
        options.tracesSampleRate = 0;
        options.attachStacktrace = true;
        options.environment = 'production';
      },
    );
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
