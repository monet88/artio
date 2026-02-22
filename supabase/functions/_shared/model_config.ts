// ⚠️ SYNC: Must match lib/core/constants/ai_models.dart
// Shared model configuration for Edge Functions

/**
 * Server-side authoritative model costs.
 * Each key is a model ID, value is the credit cost per generation.
 *
 * Pricing rule: Artio credit = KIE credit × 2
 * - KIE costs (at current resolution/quality settings):
 *   imagen4=8, imagen4-fast=4, imagen4-ultra=12, nano-banana-edit=4,
 *   nano-banana-pro=18(1K), flux-2/flex=14(1K), flux-2/pro=5(1K),
 *   gpt-image=4(medium)
 * - Gemini: free Google API quota → kept as-is
 * - Seedream: TBD (not on KIE pricing page)
 */
export const MODEL_CREDIT_COSTS: Record<string, number> = {
    "google/imagen4": 16,          // KIE: 8 × 2
    "google/imagen4-fast": 8,      // KIE: 4 × 2
    "google/imagen4-ultra": 24,    // KIE: 12 × 2
    "google/nano-banana-edit": 8,  // KIE: 4 × 2
    "nano-banana-pro": 36,         // KIE: 18 × 2 (1K resolution)
    "flux-2/flex-text-to-image": 28,   // KIE: 14 × 2 (1K)
    "flux-2/flex-image-to-image": 28,  // KIE: 14 × 2 (1K)
    "flux-2/pro-text-to-image": 10,    // KIE: 5 × 2 (1K)
    "flux-2/pro-image-to-image": 10,   // KIE: 5 × 2 (1K)
    "gpt-image/1.5-text-to-image": 8,  // KIE: 4 × 2 (medium quality)
    "gpt-image/1.5-image-to-image": 8, // KIE: 4 × 2 (medium quality)
    "seedream/4.5-text-to-image": 8,   // TBD — kept as-is
    "seedream/4.5-edit": 10,           // TBD — kept as-is
    "gemini-3-pro-image-preview": 15,  // Free Google API quota
    "gemini-2.5-flash-image": 8,       // Free Google API quota
    "imagen-4.0-generate-001": 16,     // Gemini native: same as KIE imagen4
    "imagen-4.0-ultra-generate-001": 24, // Gemini native: same as KIE imagen4-ultra
    "imagen-4.0-fast-generate-001": 8, // Gemini native: same as KIE imagen4-fast
};

/**
 * Models that require a premium subscription.
 * ⚠️ SYNC: Must match isPremium: true entries in ai_models.dart
 */
export const PREMIUM_MODELS = [
    "google/imagen4-ultra",
    "flux-2/pro-text-to-image",
    "flux-2/pro-image-to-image",
    "gpt-image/1.5-text-to-image",
    "gpt-image/1.5-image-to-image",
    "gemini-3-pro-image-preview",
    "imagen-4.0-ultra-generate-001",
] as const;

/** Check if a model requires premium subscription. */
export function isPremiumModel(modelId: string): boolean {
    return (PREMIUM_MODELS as readonly string[]).includes(modelId);
}

/** Get the credit cost for a model. Returns undefined if model is unknown. */
export function getModelCreditCost(modelId: string): number | undefined {
    return MODEL_CREDIT_COSTS[modelId];
}
