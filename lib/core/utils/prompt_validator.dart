import 'package:artio/core/constants/app_constants.dart';
import 'package:artio/core/exceptions/app_exception.dart';

/// Minimum prompt length (trimmed).
const kMinPromptLength = 3;

/// Maximum prompt length (trimmed). Alias for [AppConstants.maxPromptLength].
const kMaxPromptLength = AppConstants.maxPromptLength;

/// Validates a raw generation prompt and returns the trimmed version.
///
/// Throws [AppException.generation] with a user-friendly message if invalid.
String validateGenerationPrompt(String rawPrompt) {
  final trimmed = rawPrompt.trim();
  if (trimmed.length < kMinPromptLength) {
    throw const AppException.generation(
      message: 'Prompt must be at least $kMinPromptLength characters',
    );
  }
  if (trimmed.length > kMaxPromptLength) {
    throw const AppException.generation(
      message: 'Prompt must be at most $kMaxPromptLength characters',
    );
  }
  return trimmed;
}
