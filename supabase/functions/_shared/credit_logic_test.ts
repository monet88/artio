import { assertEquals } from "jsr:@std/assert";
import { checkAndDeductCredits, refundCreditsOnFailure } from "./credit_logic.ts";

// ── Mock Supabase client factory ──

function createMockSupabase(rpcResults: Array<{ data: unknown; error: unknown }>) {
    let callIndex = 0;
    return {
        rpc: (_fn: string, _params: Record<string, unknown>) => {
            const result = rpcResults[callIndex] ?? { data: null, error: null };
            callIndex++;
            return Promise.resolve(result);
        },
    };
}

// ── checkAndDeductCredits ──

Deno.test("checkAndDeductCredits returns success when RPC succeeds", async () => {
    const supabase = createMockSupabase([{ data: true, error: null }]);
    const result = await checkAndDeductCredits(supabase, "user-1", 10, "job-1");
    assertEquals(result, { success: true });
});

Deno.test("checkAndDeductCredits returns insufficient credits when RPC returns false", async () => {
    const supabase = createMockSupabase([{ data: false, error: null }]);
    const result = await checkAndDeductCredits(supabase, "user-1", 10, "job-1");
    assertEquals(result.success, false);
    assertEquals(result.error, "Insufficient credits");
});

Deno.test("checkAndDeductCredits returns error when RPC fails", async () => {
    const supabase = createMockSupabase([{ data: null, error: { message: "DB error" } }]);
    const result = await checkAndDeductCredits(supabase, "user-1", 10, "job-1");
    assertEquals(result.success, false);
    assertEquals(result.error, "Credit check failed");
});

// ── refundCreditsOnFailure ──

Deno.test("refundCreditsOnFailure succeeds on first attempt", async () => {
    const supabase = createMockSupabase([{ data: null, error: null }]);
    const result = await refundCreditsOnFailure(supabase, "user-1", 10, "job-1", 3);
    assertEquals(result, { success: true, attempts: 1 });
});

Deno.test("refundCreditsOnFailure retries and succeeds on 2nd attempt", async () => {
    const supabase = createMockSupabase([
        { data: null, error: { message: "transient error" } }, // fail
        { data: null, error: null },                            // succeed
    ]);
    // Use maxRetries=2 and reduce delay by overriding — but since we can't
    // override delay easily, just use maxRetries=2 (backoff will be 2s max)
    const result = await refundCreditsOnFailure(supabase, "user-1", 10, "job-1", 2);
    assertEquals(result, { success: true, attempts: 2 });
});

Deno.test("refundCreditsOnFailure exhausts retries and returns failure", async () => {
    const supabase = createMockSupabase([
        { data: null, error: { message: "error 1" } },
        { data: null, error: { message: "error 2" } },
    ]);
    const result = await refundCreditsOnFailure(supabase, "user-1", 10, "job-1", 2);
    assertEquals(result.success, false);
    assertEquals(result.attempts, 2);
});

Deno.test("refundCreditsOnFailure handles thrown exceptions", async () => {
    let callCount = 0;
    const supabase = {
        rpc: (_fn: string, _params: Record<string, unknown>) => {
            callCount++;
            if (callCount === 1) throw new Error("network error");
            return Promise.resolve({ data: null, error: null });
        },
    };
    const result = await refundCreditsOnFailure(supabase, "user-1", 10, "job-1", 2);
    assertEquals(result, { success: true, attempts: 2 });
});
