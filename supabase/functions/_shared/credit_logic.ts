// Shared credit deduction/refund logic for Edge Functions
import type { SupabaseClient } from "jsr:@supabase/supabase-js@2";

/**
 * Checks user credits and deducts if sufficient.
 * Uses the `deduct_credits` RPC which atomically validates + deducts.
 */
export async function checkAndDeductCredits(
  supabase: SupabaseClient,
  userId: string,
  amount: number,
  jobId: string
): Promise<{ success: boolean; error?: string }> {
  const { data, error } = await supabase.rpc("deduct_credits", {
    p_user_id: userId,
    p_amount: amount,
    p_description: "Image generation",
    p_reference_id: jobId,
  });

  if (error) {
    console.error(`[${jobId}] Credit deduction RPC error:`, error);
    return { success: false, error: "Credit check failed" };
  }

  // deduct_credits returns boolean: true = success, false = insufficient
  if (data === false) {
    return { success: false, error: "Insufficient credits" };
  }

  return { success: true };
}

/**
 * Refunds credits with exponential backoff retry.
 * Logs [CRITICAL] if all retries exhausted — requires manual intervention.
 */
export async function refundCreditsOnFailure(
  supabase: SupabaseClient,
  userId: string,
  amount: number,
  jobId: string,
  maxRetries: number = 3
): Promise<{ success: boolean; attempts: number }> {
  let lastError: unknown = null;

  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      const { error } = await supabase.rpc("refund_credits", {
        p_user_id: userId,
        p_amount: amount,
        p_description: "Generation failed — refund",
        p_reference_id: jobId,
      });

      if (error) {
        lastError = error;
        console.error(`[${jobId}] Credit refund RPC error (attempt ${attempt}/${maxRetries}):`, error);
      } else {
        console.log(`[${jobId}] Refunded ${amount} credits (attempt ${attempt})`);
        return { success: true, attempts: attempt };
      }
    } catch (err) {
      lastError = err;
      console.error(`[${jobId}] Credit refund exception (attempt ${attempt}/${maxRetries}):`, err);
    }

    // Exponential backoff before next retry
    if (attempt < maxRetries) {
      const delayMs = Math.pow(2, attempt) * 1000;
      await new Promise((resolve) => setTimeout(resolve, delayMs));
    }
  }

  // All retries exhausted — CRITICAL: requires manual intervention
  console.error(
    `[CRITICAL] Credit refund failed after ${maxRetries} attempts. ` +
    `userId=${userId}, amount=${amount}, jobId=${jobId}, lastError=`,
    lastError
  );
  return { success: false, attempts: maxRetries };
}
