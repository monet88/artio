import 'package:flutter/foundation.dart';

/// Lightweight content moderation service.
///
/// Checks prompts against a block-list of sensitive keywords before
/// submitting to AI generation. This provides a basic safety layer
/// required by Apple App Store guideline 3.1.3(b) for AI-generated content.
///
/// ## Limitations
/// This is a client-side first pass only. Server-side moderation via KIE.ai
/// or a dedicated moderation API should be added for production hardening.
class ContentModerationService {
  ContentModerationService._();

  /// Singleton instance.
  // ignore: prefer_constructors_over_static_methods
  static final ContentModerationService instance = ContentModerationService._();

  /// Checks a prompt for inappropriate content.
  ///
  /// Returns `null` if the prompt passes moderation.
  /// Returns an error message string if the prompt is rejected.
  String? checkPrompt(String prompt) {
    if (prompt.trim().isEmpty) return null;

    final lower = prompt.toLowerCase();
    for (final keyword in _blockedKeywords) {
      if (lower.contains(keyword)) {
        return 'Your prompt contains content that is not allowed. '
            'Please revise and try again.';
      }
    }
    return null; // Passed
  }

  /// Sanitises a prompt by trimming whitespace.
  /// Does not alter content — only normalises.
  String sanitise(String prompt) => prompt.trim();
}

/// Block-list of keywords that violate content policies.
/// Covers Apple guideline 3.1.3(b) minimum requirements.
///
/// This list is intentionally conservative — it blocks clear violations
/// without over-filtering legitimate artistic prompts.
const List<String> _blockedKeywords = [
  // Sexual / NSFW
  'nude', 'naked', 'nsfw', 'pornography', 'pornographic', 'explicit sex',
  'hentai', 'erotic', 'genitals', 'penis', 'vagina', 'breasts naked',

  // Violence / Gore
  'gore', 'decapitation', 'mutilation', 'dismember', 'snuff',
  'torture porn', 'graphic violence',

  // Hate speech
  'racial slur', 'ethnic cleansing', 'white supremacy', 'nazi propaganda',

  // Illegal content
  'child abuse', 'child pornography', 'csam', 'minor sexual',

  // Self-harm
  'suicide how to', 'self harm instructions', 'how to cut yourself',
];

/// Convenience top-level getter for use in providers.
ContentModerationService get contentModerationService =>
    ContentModerationService.instance;

// Suppress unused import warning in non-debug builds.
// ignore: unused_element
bool get _isDebug => kDebugMode;
