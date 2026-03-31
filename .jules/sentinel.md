
## 2024-05-22 - Restrict URL Schemes
**Vulnerability:** Arbitrary schemes like `javascript:` and `file:` were allowed by `launchUrlSafely` and `launchInAppUrl`.
**Learning:** By default, Dart's `Uri.parse()` combined with Flutter's `url_launcher` does not restrict url schemes. A malicious URL string injected via an input field, remote database, or intent could execute arbitrary code or navigate local directories.
**Prevention:** Always restrict accepted schemes before launching them using `url_launcher` (e.g., verifying `scheme == 'http'` or `scheme == 'https'`).
