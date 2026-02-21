/// Constants related to image generation.
library;

/// Template ID sentinel for non-template (free-text) generations.
///
/// Used when the user creates images from scratch via the Create flow,
/// as opposed to using a predefined template from the template engine.
const kFreeTextTemplateId = 'free-text';

/// Request timeout for generation operations (in seconds).
///
/// Must match the Edge Function's polling window (60 attempts * 2s = 120s).
const kGenerationRequestTimeoutSeconds = 120;

/// Validates a generation prompt.
///
/// Returns null if valid, or an error message if invalid.
String? validateGenerationPrompt(String rawPrompt, {required int maxLength}) {
  final trimmed = rawPrompt.trim();
  if (trimmed.length < 3) {
    return 'Prompt must be at least 3 characters';
  }
  if (trimmed.length > maxLength) {
    return 'Prompt must be at most $maxLength characters';
  }
  return null;
}
