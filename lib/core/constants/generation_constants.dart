/// Constants related to image generation.
library;

/// Template ID sentinel for non-template (free-text) generations.
///
/// Used when the user creates images from scratch via the Create flow,
/// as opposed to using a predefined template from the template engine.
const kFreeTextTemplateId = 'free-text';

/// Edge Function request timeout (seconds). Must match Edge Function's
/// `POLL_MAX_ATTEMPTS * POLL_INTERVAL_MS` (60 × 2 000 ms = 120 s).
const kGenerationRequestTimeoutSeconds = 120;
