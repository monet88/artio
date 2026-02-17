/// Safely parses a [DateTime] from [value], returning [fallback] on failure.
///
/// Handles null, empty strings, and invalid date formats without throwing.
DateTime? safeParseDateTime(dynamic value, {DateTime? fallback}) {
  if (value == null) return fallback;
  try {
    return DateTime.parse(value.toString());
  } on FormatException catch (_) {
    return fallback;
  }
}
