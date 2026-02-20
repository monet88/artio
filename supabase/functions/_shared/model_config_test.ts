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

// ── Consistency checks ──

Deno.test("all premium models have credit costs defined", () => {
    for (const id of PREMIUM_MODELS) {
        const cost = MODEL_CREDIT_COSTS[id];
        assertEquals(typeof cost, "number", `Premium model ${id} missing credit cost`);
    }
});

Deno.test("MODEL_CREDIT_COSTS has 16 entries (matches Dart ai_models.dart)", () => {
    assertEquals(Object.keys(MODEL_CREDIT_COSTS).length, 16);
});

Deno.test("PREMIUM_MODELS has 7 entries (matches Dart ai_models.dart)", () => {
    assertEquals(PREMIUM_MODELS.length, 7);
});
