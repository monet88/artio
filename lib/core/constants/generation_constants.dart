/// Constants related to image generation.
library;

import 'package:artio/core/constants/app_constants.dart';
import 'package:artio/core/exceptions/app_exception.dart';

/// Template ID sentinel for non-template (free-text) generations.
///
/// Used when the user creates images from scratch via the Create flow,
/// as opposed to using a predefined template from the template engine.
const kFreeTextTemplateId = 'free-text';

/// Minimum prompt length (trimmed).
const kMinPromptLength = 3;

/// Maximum prompt length (trimmed). Alias for [AppConstants.maxPromptLength].
const kMaxPromptLength = AppConstants.maxPromptLength;

/// Edge Function request timeout (seconds). Must match Edge Function's
/// `POLL_MAX_ATTEMPTS * POLL_INTERVAL_MS` (60 × 2 000 ms = 120 s).
const kGenerationRequestTimeoutSeconds = 120;

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
