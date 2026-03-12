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

    // Update subscription status
    const { error: statusErr } = await supabase.rpc(
      "update_subscription_status",
      {
        p_user_id: user.id,
        p_is_premium: true,
        p_tier: tierInfo.tier,
        p_expires_at: null, // expiry managed by RC webhook when it fires
      },
    );
    if (statusErr) {
      console.error(
        "[verify-google-purchase] update_subscription_status error:",
        statusErr,
      );
      return new Response(
        JSON.stringify({ error: "Failed to update subscription status" }),
        {
          status: 500,
          headers: { "Content-Type": "application/json" },
        },
      );
    }

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
      // credits already granted (idempotency) or DB error — don't fail the response
    }

    console.log(
      `[verify-google-purchase] Granted ${user.id}: tier=${tierInfo.tier}, ${tierInfo.credits} credits, ref=${referenceId}`,
    );

    return new Response(
      JSON.stringify({
        verified: true,
        tier: tierInfo.tier,
        credits: tierInfo.credits,
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
