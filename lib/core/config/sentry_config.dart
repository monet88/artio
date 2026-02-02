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

  static void captureException(dynamic exception, {StackTrace? stackTrace}) {
    if (EnvConfig.environment == 'production') {
      Sentry.captureException(exception, stackTrace: stackTrace);
    }
  }
}
