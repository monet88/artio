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
function getTierInfo(productId: string): { tier: string; credits: number } | null {
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

    // Verify webhook auth header
    const authHeader = req.headers.get("Authorization");
    if (!authHeader || authHeader !== `Bearer ${REVENUECAT_WEBHOOK_SECRET}`) {
        console.error("[revenuecat-webhook] Invalid or missing authorization header");
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
        const eventId: string = event.id;
        const appUserId: string = event.app_user_id;
        const productId: string = event.product_id ?? "";

        console.log(
            `[revenuecat-webhook] Event: ${eventType}, id: ${eventId}, user: ${appUserId}, product: ${productId}`
        );

        const supabase = getSupabaseClient();

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
                const { error: statusErr } = await supabase.rpc("update_subscription_status", {
                    p_user_id: appUserId,
                    p_is_premium: true,
                    p_tier: tierInfo.tier,
                    p_expires_at: expiresAt,
                });
                if (statusErr) {
                    console.error("[revenuecat-webhook] update_subscription_status error:", statusErr);
                }

                // Grant credits (idempotent via event_id)
                const { error: creditErr } = await supabase.rpc("grant_subscription_credits", {
                    p_user_id: appUserId,
                    p_amount: tierInfo.credits,
                    p_description: `${tierInfo.tier} subscription — initial purchase`,
                    p_reference_id: eventId,
                });
                if (creditErr) {
                    console.error("[revenuecat-webhook] grant_subscription_credits error:", creditErr);
                }

                console.log(
                    `[revenuecat-webhook] INITIAL_PURCHASE: ${tierInfo.tier}, ${tierInfo.credits} credits for ${appUserId}`
                );
                break;
            }

            case "RENEWAL": {
                const tierInfo = getTierInfo(productId);
                if (!tierInfo) {
                    console.warn(`[revenuecat-webhook] Unknown product for renewal: ${productId}`);
                    break;
                }

                const expiresAt = event.expiration_at_ms
                    ? new Date(event.expiration_at_ms).toISOString()
                    : null;

                // Extend subscription expiry
                const { error: statusErr } = await supabase.rpc("update_subscription_status", {
                    p_user_id: appUserId,
                    p_is_premium: true,
                    p_tier: tierInfo.tier,
                    p_expires_at: expiresAt,
                });
                if (statusErr) {
                    console.error("[revenuecat-webhook] update_subscription_status error:", statusErr);
                }

                // Grant credits (idempotent via event_id)
                const { error: creditErr } = await supabase.rpc("grant_subscription_credits", {
                    p_user_id: appUserId,
                    p_amount: tierInfo.credits,
                    p_description: `${tierInfo.tier} subscription — renewal`,
                    p_reference_id: eventId,
                });
                if (creditErr) {
                    console.error("[revenuecat-webhook] grant_subscription_credits error:", creditErr);
                }

                console.log(
                    `[revenuecat-webhook] RENEWAL: ${tierInfo.tier}, ${tierInfo.credits} credits for ${appUserId}`
                );
                break;
            }

            case "CANCELLATION": {
                // User cancelled — they keep access until expiry, just log
                console.log(
                    `[revenuecat-webhook] CANCELLATION: user ${appUserId} cancelled, access continues until expiry`
                );
                break;
            }

            case "EXPIRATION": {
                // Subscription expired — remove premium status
                const { error: statusErr } = await supabase.rpc("update_subscription_status", {
                    p_user_id: appUserId,
                    p_is_premium: false,
                    p_tier: null,
                    p_expires_at: null,
                });
                if (statusErr) {
                    console.error("[revenuecat-webhook] update_subscription_status error:", statusErr);
                }

                console.log(
                    `[revenuecat-webhook] EXPIRATION: removed premium for ${appUserId}`
                );
                break;
            }

            case "PRODUCT_CHANGE": {
                const tierInfo = getTierInfo(productId);
                if (!tierInfo) {
                    console.warn(`[revenuecat-webhook] Unknown product for change: ${productId}`);
                    break;
                }

                const expiresAt = event.expiration_at_ms
                    ? new Date(event.expiration_at_ms).toISOString()
                    : null;

                // Update tier
                const { error: statusErr } = await supabase.rpc("update_subscription_status", {
                    p_user_id: appUserId,
                    p_is_premium: true,
                    p_tier: tierInfo.tier,
                    p_expires_at: expiresAt,
                });
                if (statusErr) {
                    console.error("[revenuecat-webhook] update_subscription_status error:", statusErr);
                }

                console.log(
                    `[revenuecat-webhook] PRODUCT_CHANGE: ${appUserId} → ${tierInfo.tier}`
                );
                break;
            }

            case "BILLING_ISSUES_DETECTED": {
                console.warn(
                    `[revenuecat-webhook] BILLING_ISSUES_DETECTED for ${appUserId} (product: ${productId})`
                );
                break;
            }

            default: {
                console.log(
                    `[revenuecat-webhook] Unhandled event type: ${eventType}`
                );
            }
        }

        // Always return 200 to prevent RevenueCat retries
        return new Response(JSON.stringify({ ok: true }), {
            status: 200,
            headers: { "Content-Type": "application/json" },
        });
    } catch (error) {
        console.error("[revenuecat-webhook] Unexpected error:", error);
        // Still return 200 to prevent retries — we'll investigate via logs
        return new Response(
            JSON.stringify({
                ok: true,
                warning: "Processed with errors — see logs",
            }),
            {
                status: 200,
                headers: { "Content-Type": "application/json" },
            }
        );
    }
});
