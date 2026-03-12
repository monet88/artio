// supabase/functions/verify-google-purchase/index.ts
//
// Called by the Flutter app immediately after a successful Purchases.purchase().
// The RC SDK validates the purchase on-device against Google Play, so we trust
// the client claim. We use the orderId (GPA.xxx) — the only token exposed by
// purchases_flutter — as an idempotency key to prevent double-grants.
//
// NOTE: purchases_flutter 9.x StoreTransaction.transactionIdentifier on Android
// returns the orderId (GPA.xxx), NOT the purchaseToken. The Google Play Developer
// API requires the purchaseToken (not orderId), so we cannot do server-side GP
// validation here. RC server-side validation via webhook handles that separately.
//
// SECURITY CONTRACT (understand before modifying):
//   - purchaseToken (orderId) is CLIENT-SUPPLIED and only validated by format (GPA regex).
//     We cannot verify it corresponds to a real purchase by this specific user.
//   - productId is CLIENT-SUPPLIED and determines the credit amount granted (500 or 200).
//     A user with a real GPA token could claim a higher tier than they purchased.
//   - Mitigations in place:
//       1. GPA format validation blocks obviously fake tokens.
//       2. 25-day per-user rate limit prevents farming via unique fabricated tokens.
//       3. RC webhook is the authoritative credit source — when Pub/Sub pipeline
//          is confirmed stable, credit grants here should be removed entirely.
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

/** Map product ID prefix → tier name + credits */
function getTierInfo(
  productId: string,
): { tier: string; credits: number } | null {
  if (productId.startsWith("artio_ultra_"))
    return { tier: "ultra", credits: 500 };
  if (productId.startsWith("artio_pro_")) return { tier: "pro", credits: 200 };
  return null;
}

/**
 * Validate purchaseToken format to prevent fake/exploited grants.
 * Only accepts real Google Play order IDs (GPA.XXXX-XXXX-XXXX-XXXXX).
 * Timestamp-based fallback tokens (rc-...) were removed because any
 * authenticated user could forge them with arbitrary timestamps to
 * repeatedly claim credits.
 */
function isValidPurchaseToken(token: string): boolean {
  // Real Google Play order ID: GPA.digits-digits-digits-digits
  return /^GPA\.\d{4}-\d{4}-\d{4}-\d+$/.test(token);
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { "Content-Type": "application/json" },
    });
  }

  // Authenticate user via JWT
  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return new Response(JSON.stringify({ error: "Missing authorization" }), {
      status: 401,
      headers: { "Content-Type": "application/json" },
    });
  }

  const userClient = createClient(
    SUPABASE_URL,
    Deno.env.get("SUPABASE_ANON_KEY")!,
    {
      auth: { persistSession: false },
      global: { headers: { Authorization: authHeader } },
    },
  );
  const {
    data: { user },
    error: authError,
  } = await userClient.auth.getUser();
  if (authError || !user) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), {
      status: 401,
      headers: { "Content-Type": "application/json" },
    });
  }

  // Parse request body
  // purchaseToken = orderId (GPA.xxx) from StoreTransaction.transactionIdentifier
  // productId = store product identifier (e.g. "artio_pro_monthly")
  let purchaseToken: string;
  let productId: string;
  try {
    const body = (await req.json()) as {
      purchaseToken?: string;
      productId?: string;
    };
    purchaseToken = body.purchaseToken ?? "";
    productId = body.productId ?? "";
    if (!purchaseToken || !productId) throw new Error("missing fields");
  } catch {
    return new Response(
      JSON.stringify({
        error: "Body must include purchaseToken and productId",
      }),
      {
        status: 400,
        headers: { "Content-Type": "application/json" },
      },
    );
  }

  // Validate purchaseToken format — blocks fake/crafted tokens
  if (!isValidPurchaseToken(purchaseToken)) {
    console.warn(
      `[verify-google-purchase] Invalid purchaseToken format: "${purchaseToken}" for user ${user.id}`,
    );
    return new Response(
      JSON.stringify({ error: "Invalid purchaseToken format" }),
      {
        status: 400,
        headers: { "Content-Type": "application/json" },
      },
    );
  }

  const tierInfo = getTierInfo(productId);
  if (!tierInfo) {
    console.warn(
      `[verify-google-purchase] Unknown productId: ${productId} for user ${user.id}`,
    );
    return new Response(
      JSON.stringify({ error: `Unknown productId: ${productId}` }),
      {
        status: 400,
        headers: { "Content-Type": "application/json" },
      },
    );
  }

  try {
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
      auth: { persistSession: false },
    });

    // Note: update_subscription_status is intentionally omitted here.
    // productId is client-supplied, so setting tier from it before verifying
    // ownership would allow tier escalation (e.g., claiming ultra with a pro token).
    // The RC webhook fires within seconds and sets the authoritative tier+expiry.

    // Rate-limit check: prevent credit farming via fabricated GPA-format tokens.
    // An attacker who knows the regex could call this endpoint repeatedly with
    // unique fake tokens (each new reference_id bypasses ON CONFLICT dedup).
    // Guard: if the user already received subscription credits in the past 25 days,
    // skip the grant — they are still within their active billing cycle.
    const cutoff = new Date(
      Date.now() - 25 * 24 * 60 * 60 * 1000,
    ).toISOString();
    const { data: recentGrants, error: grantCheckErr } = await supabase
      .from("credit_transactions")
      .select("id")
      .eq("user_id", user.id)
      .eq("type", "subscription_credit")
      .gt("created_at", cutoff)
      .limit(1);

    if (grantCheckErr) {
      console.error(
        "[verify-google-purchase] grant check error:",
        grantCheckErr,
      );
      // Fail-closed: rate-limit check is a security control.
      // A transient DB error must not silently bypass it and grant credits.
      return new Response(
        JSON.stringify({ error: "Failed to verify credit grant eligibility" }),
        { status: 500, headers: { "Content-Type": "application/json" } },
      );
    }

    const alreadyGranted = (recentGrants?.length ?? 0) > 0;

    let creditsGranted = 0;
    if (alreadyGranted) {
      console.log(
        `[verify-google-purchase] Credits already granted this cycle for ${user.id} — skipping`,
      );
    } else {
      // Grant credits — idempotent via purchaseToken (orderId GPA.xxx).
      // If RC webhook later fires with the same orderId as transaction_id,
      // grant_subscription_credits will deduplicate via reference_id.
      const referenceId = `gp-${purchaseToken}`;
      const { error: creditErr } = await supabase.rpc(
        "grant_subscription_credits",
        {
          p_user_id: user.id,
          p_amount: tierInfo.credits,
          p_description: `${tierInfo.tier} subscription — Google Play purchase`,
          p_reference_id: referenceId,
        },
      );
      if (creditErr) {
        console.error(
          "[verify-google-purchase] grant_subscription_credits error:",
          creditErr,
        );
        // credits: 0 — do not report credits as granted when RPC failed.
        // Subscription status is already updated; user can contact support
        // or wait for RC webhook to grant credits.
      } else {
        creditsGranted = tierInfo.credits;
        console.log(
          `[verify-google-purchase] Granted ${user.id}: tier=${tierInfo.tier}, ${creditsGranted} credits, ref=${referenceId}`,
        );
      }
    }

    return new Response(
      JSON.stringify({
        verified: true,
        tier: tierInfo.tier,
        credits: creditsGranted,
        credits_already_granted: alreadyGranted,
      }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" },
      },
    );
  } catch (err) {
    console.error("[verify-google-purchase] Unexpected error:", err);
    return new Response(JSON.stringify({ error: "Internal server error" }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
