/// Simple email validation with TLD check.
///
/// Validates that the email:
/// - Contains exactly one `@`
/// - Has a non-empty local part before `@`
/// - Has a domain with at least one `.` (TLD check)
/// - TLD is at least 2 characters
class EmailValidator {
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Returns null if valid, error message if invalid.
  static String? validate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }
}
