import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const REVENUECAT_WEBHOOK_SECRET = Deno.env.get("REVENUECAT_WEBHOOK_SECRET")!;

function getSupabaseClient() {
  return createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
    auth: { persistSession: false },
  });
}

/** Map product ID prefix to tier and monthly credit amount. */
function getTierInfo(
  productId: string,
): { tier: string; credits: number } | null {
  if (productId.startsWith("artio_ultra_")) {
    return { tier: "ultra", credits: 500 };
  }
  if (productId.startsWith("artio_pro_")) {
    return { tier: "pro", credits: 200 };
  }
  return null;
}

Deno.serve(async (req) => {
  // Only accept POST
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { "Content-Type": "application/json" },
    });
  }

  // H1: Guard against empty-string secret (env var set to "" bypasses auth otherwise)
  if (!REVENUECAT_WEBHOOK_SECRET) {
    console.error("[revenuecat-webhook] REVENUECAT_WEBHOOK_SECRET is not set");
    return new Response(JSON.stringify({ error: "Server misconfigured" }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }

  // Verify webhook auth header (no early-exit XOR comparison — length and bytes both checked).
  // crypto.subtle.timingSafeEqual is not available in Supabase Edge Runtime.
  const authHeader = req.headers.get("Authorization");
  const expectedAuth = `Bearer ${REVENUECAT_WEBHOOK_SECRET}`;
  const encoder = new TextEncoder();
  const a = encoder.encode(authHeader ?? "");
  const b = encoder.encode(expectedAuth);
  let diff = a.length ^ b.length;
  const len = Math.min(a.length, b.length);
  for (let i = 0; i < len; i++) diff |= a[i] ^ b[i];
  const authValid = authHeader !== null && diff === 0;
  if (!authValid) {
    console.error(
      "[revenuecat-webhook] Invalid or missing authorization header",
    );
    return new Response(JSON.stringify({ error: "Unauthorized" }), {
      status: 401,
      headers: { "Content-Type": "application/json" },
    });
  }

  try {
    const body = await req.json();
    const event = body.event;

    if (!event) {
      console.warn("[revenuecat-webhook] No event in body");
      return new Response(JSON.stringify({ ok: true }), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    }

    const eventType: string = event.type;
    const appUserId: string = event.app_user_id;
    const productId: string = event.product_id ?? "";
    // RC events should include 'id' (UUID) but sandbox may omit it.
    // Fall back to transaction_id (GPA.xxx) so p_reference_id is never null
    // — a null reference_id causes grant_subscription_credits to throw.
    const eventId: string =
      event.id ??
      event.transaction_id ??
      `${appUserId}-${eventType}-${event.event_timestamp_ms ?? Date.now()}`;

    console.log(
      `[revenuecat-webhook] Event: ${eventType}, id: ${eventId}, user: ${appUserId}, product: ${productId}`,
    );

    const supabase = getSupabaseClient();

    // Soft-validate: warn if app_user_id is not linked to any profile
    const { data: profile } = await supabase
      .from("profiles")
      .select("id")
      .eq("revenuecat_app_user_id", appUserId)
      .maybeSingle();

    if (!profile) {
      console.error(
        JSON.stringify({
          level: "error",
          source: "revenuecat-webhook",
          event_type: eventType,
          event_id: eventId,
          app_user_id: appUserId,
          product_id: productId,
          message: "User not linked. Returning 500 for retry.",
        }),
      );
      return new Response(
        JSON.stringify({ error: "User not linked", retryable: true }),
        {
          status: 500,
          headers: { "Content-Type": "application/json" },
        },
      );
    }

    const userId = profile.id;

    switch (eventType) {
      case "INITIAL_PURCHASE": {
        const tierInfo = getTierInfo(productId);
        if (!tierInfo) {
          console.warn(`[revenuecat-webhook] Unknown product: ${productId}`);
          break;
        }

        const expiresAt = event.expiration_at_ms
          ? new Date(event.expiration_at_ms).toISOString()
          : null;

        // Update subscription status
        const { error: statusErr } = await supabase.rpc(
          "update_subscription_status",
          {
            p_user_id: userId,
            p_is_premium: true,
            p_tier: tierInfo.tier,
            p_expires_at: expiresAt,
          },
        );
        if (statusErr) {
          console.error(
            "[revenuecat-webhook] update_subscription_status error:",
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

        // Grant credits (idempotent via event_id).
        // p_check_recent_grant=true moves the 25-day guard inside the RPC, under an
        // advisory lock, eliminating the TOCTOU race with verify-google-purchase
        // (which uses a different reference_id format so ON CONFLICT alone won't dedup).
        const { data: grantResult, error: creditErr } = await supabase.rpc(
          "grant_subscription_credits",
          {
            p_user_id: userId,
            p_amount: tierInfo.credits,
            p_description: `${tierInfo.tier} subscription — initial purchase`,
            p_reference_id: eventId,
            p_check_recent_grant: true,
          },
        );
        if (creditErr) {
          console.error(
            "[revenuecat-webhook] grant_subscription_credits error:",
            creditErr,
          );
          return new Response(
            JSON.stringify({ error: "Failed to grant credits" }),
            {
              status: 500,
              headers: { "Content-Type": "application/json" },
            },
          );
        }

        if (grantResult?.granted === false) {
          console.log(
            `[revenuecat-webhook] INITIAL_PURCHASE: credits already granted this cycle for ${userId} — skipping duplicate (reason: ${grantResult?.reason})`,
          );
          break;
        }

        console.log(
          `[revenuecat-webhook] INITIAL_PURCHASE: ${tierInfo.tier}, ${tierInfo.credits} credits for ${appUserId}`,
        );
        break;
      }

      case "RENEWAL": {
        const tierInfo = getTierInfo(productId);
        if (!tierInfo) {
          console.warn(
            `[revenuecat-webhook] Unknown product for renewal: ${productId}`,
          );
          break;
        }

        const expiresAt = event.expiration_at_ms
          ? new Date(event.expiration_at_ms).toISOString()
          : null;

        // Extend subscription expiry
        const { error: statusErr } = await supabase.rpc(
          "update_subscription_status",
          {
            p_user_id: userId,
            p_is_premium: true,
            p_tier: tierInfo.tier,
            p_expires_at: expiresAt,
          },
        );
        if (statusErr) {
          console.error(
            "[revenuecat-webhook] update_subscription_status error:",
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

        // Grant credits (idempotent via event_id — no 25-day rate-limit check needed here.
        // RENEWAL events have unique eventIds; grant_subscription_credits deduplicates via
        // reference_id = eventId, so RC retries of the same event are safe.)
        const { data: grantResult, error: creditErr } = await supabase.rpc(
          "grant_subscription_credits",
          {
            p_user_id: userId,
            p_amount: tierInfo.credits,
            p_description: `${tierInfo.tier} subscription — renewal`,
            p_reference_id: eventId,
            p_check_recent_grant: false,
          },
        );
        if (creditErr) {
          console.error(
            "[revenuecat-webhook] grant_subscription_credits error:",
            creditErr,
          );
          return new Response(
            JSON.stringify({ error: "Failed to grant credits" }),
            {
              status: 500,
              headers: { "Content-Type": "application/json" },
            },
          );
        }

        if (grantResult?.granted === false) {
          console.log(
            `[revenuecat-webhook] RENEWAL: credits already granted for ${userId} — skipping duplicate (reason: ${grantResult?.reason})`,
          );
          break;
        }

        console.log(
          `[revenuecat-webhook] RENEWAL: ${tierInfo.tier}, ${tierInfo.credits} credits for ${appUserId}`,
        );
        break;
      }

      case "CANCELLATION": {
        // User cancelled — they keep access until expiry, just log
        console.log(
          `[revenuecat-webhook] CANCELLATION: user ${appUserId} cancelled, access continues until expiry`,
        );
        break;
      }

      case "EXPIRATION": {
        // Subscription expired — remove premium status
        const { error: statusErr } = await supabase.rpc(
          "update_subscription_status",
          {
            p_user_id: userId,
            p_is_premium: false,
            p_tier: "free", // explicit 'free' — RPC does SET subscription_tier = p_tier, so null would write NULL (not default)
            p_expires_at: null,
          },
        );
        if (statusErr) {
          console.error(
            "[revenuecat-webhook] update_subscription_status error:",
            statusErr,
          );
          // Return 500 so RC retries — user must not remain premium after expiry.
          return new Response(
            JSON.stringify({
              error: "Failed to downgrade subscription status",
            }),
            { status: 500, headers: { "Content-Type": "application/json" } },
          );
        }

        console.log(
          `[revenuecat-webhook] EXPIRATION: removed premium for ${appUserId}`,
        );
        break;
      }

      case "PRODUCT_CHANGE": {
        const newProductId = event.new_product_id ?? productId;
        const tierInfo = getTierInfo(newProductId);
        if (!tierInfo) {
          console.error(
            `[revenuecat-webhook] Unknown product for PRODUCT_CHANGE: ${newProductId} — returning 500 so RC retries`,
          );
          // Return 500: unknown product on a tier change could mean the user switched
          // to a free/unrecognised plan. Retrying gives ops a chance to add the product
          // mapping before the user's tier gets stuck at their old premium tier.
          return new Response(
            JSON.stringify({ error: `Unknown product: ${newProductId}` }),
            { status: 500, headers: { "Content-Type": "application/json" } },
          );
        }

        const expiresAt = event.expiration_at_ms
          ? new Date(event.expiration_at_ms).toISOString()
          : null;

        // Update tier
        const { error: statusErr } = await supabase.rpc(
          "update_subscription_status",
          {
            p_user_id: userId,
            p_is_premium: true,
            p_tier: tierInfo.tier,
            p_expires_at: expiresAt,
          },
        );
        if (statusErr) {
          console.error(
            "[revenuecat-webhook] update_subscription_status error:",
            statusErr,
          );
          // Return 500 so RC retries — user must not stay on wrong tier.
          return new Response(
            JSON.stringify({ error: "Failed to update subscription status" }),
            { status: 500, headers: { "Content-Type": "application/json" } },
          );
        }

        console.log(
          `[revenuecat-webhook] PRODUCT_CHANGE: ${appUserId} → ${tierInfo.tier}`,
        );
        break;
      }

      case "BILLING_ISSUES_DETECTED": {
        console.warn(
          `[revenuecat-webhook] BILLING_ISSUES_DETECTED for ${appUserId} (product: ${productId})`,
        );
        break;
      }

      default: {
        console.log(`[revenuecat-webhook] Unhandled event type: ${eventType}`);
      }
    }

    // Return 200 for successfully processed or non-critical events.
    // Any RPC failure in a critical handler (INITIAL_PURCHASE, RENEWAL, EXPIRATION, PRODUCT_CHANGE)
    // returns 500 above — those paths never reach here.
    return new Response(JSON.stringify({ ok: true }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("[revenuecat-webhook] Unexpected error:", error);
    // Return 500 so RevenueCat retries — credit granting is idempotent via reference_id
    return new Response(JSON.stringify({ error: "Internal server error" }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
