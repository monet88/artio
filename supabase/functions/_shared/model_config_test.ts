import { assertEquals } from "jsr:@std/assert";
import {
    MODEL_CREDIT_COSTS,
    PREMIUM_MODELS,
    isPremiumModel,
    getModelCreditCost,
} from "./model_config.ts";

// ── isPremiumModel ──

Deno.test("isPremiumModel returns true for all premium models", () => {
    const expected = [
        "google/imagen4-ultra",
        "google/pro-image-to-image",
        "flux-2/pro-text-to-image",
        "flux-2/pro-image-to-image",
        "gpt-image/1.5-text-to-image",
        "gpt-image/1.5-image-to-image",
        "gemini-3-pro-image-preview",
    ];
    for (const id of expected) {
        assertEquals(isPremiumModel(id), true, `${id} should be premium`);
    }
});

Deno.test("isPremiumModel returns false for free models", () => {
    const freeModels = [
        "google/imagen4",
        "google/imagen4-fast",
        "flux-2/flex-text-to-image",
        "seedream/4.5-text-to-image",
        "gemini-2.5-flash-image",
    ];
    for (const id of freeModels) {
        assertEquals(isPremiumModel(id), false, `${id} should NOT be premium`);
    }
});

Deno.test("isPremiumModel returns false for unknown model", () => {
    assertEquals(isPremiumModel("nonexistent/model"), false);
});

// ── getModelCreditCost ──

Deno.test("getModelCreditCost returns correct costs", () => {
    assertEquals(getModelCreditCost("google/imagen4"), 6);
    assertEquals(getModelCreditCost("google/imagen4-fast"), 4);
    assertEquals(getModelCreditCost("google/imagen4-ultra"), 12);
    assertEquals(getModelCreditCost("flux-2/pro-text-to-image"), 16);
    assertEquals(getModelCreditCost("gpt-image/1.5-text-to-image"), 15);
    assertEquals(getModelCreditCost("gemini-3-pro-image-preview"), 15);
});

Deno.test("getModelCreditCost returns undefined for unknown model", () => {
    assertEquals(getModelCreditCost("nonexistent/model"), undefined);
});

// ── Sync validation: exact model IDs must match Dart ai_models.dart ──
// ⚠️ If these fail, update BOTH ai_models.dart AND model_config.ts

Deno.test("PREMIUM_MODELS matches Dart ai_models.dart premium IDs", () => {
    const dartPremiumIds = [
        "google/imagen4-ultra",
        "google/pro-image-to-image",
        "flux-2/pro-text-to-image",
        "flux-2/pro-image-to-image",
        "gpt-image/1.5-text-to-image",
        "gpt-image/1.5-image-to-image",
        "gemini-3-pro-image-preview",
    ];
    const tsPremiumIds = [...PREMIUM_MODELS].sort();
    const expected = [...dartPremiumIds].sort();
    assertEquals(tsPremiumIds, expected, "PREMIUM_MODELS drift detected — sync with ai_models.dart");
});

Deno.test("MODEL_CREDIT_COSTS keys match Dart ai_models.dart model IDs", () => {
    const dartModelIds = [
        "google/imagen4",
        "google/imagen4-fast",
        "google/imagen4-ultra",
        "google/nano-banana-edit",
        "nano-banana-pro",
        "google/pro-image-to-image",
        "flux-2/flex-text-to-image",
        "flux-2/flex-image-to-image",
        "flux-2/pro-text-to-image",
        "flux-2/pro-image-to-image",
        "gpt-image/1.5-text-to-image",
        "gpt-image/1.5-image-to-image",
        "seedream/4.5-text-to-image",
        "seedream/4.5-edit",
        "gemini-3-pro-image-preview",
        "gemini-2.5-flash-image",
    ];
    const tsModelIds = Object.keys(MODEL_CREDIT_COSTS).sort();
    const expected = [...dartModelIds].sort();
    assertEquals(tsModelIds, expected, "MODEL_CREDIT_COSTS drift detected — sync with ai_models.dart");
});

Deno.test("MODEL_CREDIT_COSTS values match Dart ai_models.dart creditCost", () => {
    // id → creditCost from Dart ai_models.dart
    const dartCosts: Record<string, number> = {
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
    for (const [id, expectedCost] of Object.entries(dartCosts)) {
        assertEquals(
            MODEL_CREDIT_COSTS[id],
            expectedCost,
            `Credit cost mismatch for ${id}: TS=${MODEL_CREDIT_COSTS[id]} vs Dart=${expectedCost}`,
        );
    }
});
