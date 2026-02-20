// ⚠️ SYNC: Must match lib/core/constants/ai_models.dart
// Shared model configuration for Edge Functions

/**
 * Server-side authoritative model costs.
 * Each key is a model ID, value is the credit cost per generation.
 */
export const MODEL_CREDIT_COSTS: Record<string, number> = {
    "google/imagen4": 6,
    "google/imagen4-fast": 4,
    "google/imagen4-ultra": 12,
    "google/nano-banana-edit": 10,
    "nano-banana-pro": 10,
    "google/pro-image-to-image": 15,
    "flux-2/flex-text-to-image": 8,
    "flux-2/flex-image-to-image": 10,
    "flux-2/pro-text-to-image": 16,
    "flux-2/pro-image-to-image": 20,
    "gpt-image/1.5-text-to-image": 15,
    "gpt-image/1.5-image-to-image": 18,
    "seedream/4.5-text-to-image": 8,
    "seedream/4.5-edit": 10,
    "gemini-3-pro-image-preview": 15,
    "gemini-2.5-flash-image": 8,
};

/**
 * Models that require a premium subscription.
 * ⚠️ SYNC: Must match isPremium: true entries in ai_models.dart
 */
export const PREMIUM_MODELS = [
    "google/imagen4-ultra",
    "google/pro-image-to-image",
    "flux-2/pro-text-to-image",
    "flux-2/pro-image-to-image",
    "gpt-image/1.5-text-to-image",
    "gpt-image/1.5-image-to-image",
    "gemini-3-pro-image-preview",
] as const;

/** Check if a model requires premium subscription. */
export function isPremiumModel(modelId: string): boolean {
    return (PREMIUM_MODELS as readonly string[]).includes(modelId);
}

/** Get the credit cost for a model. Returns undefined if model is unknown. */
export function getModelCreditCost(modelId: string): number | undefined {
    return MODEL_CREDIT_COSTS[modelId];
}
