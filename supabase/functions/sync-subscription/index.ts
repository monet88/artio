import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const REVENUECAT_SECRET_KEY = Deno.env.get("REVENUECAT_SECRET_KEY")!;

const RC_PROJECT_ID = "proj7a945f6d";

/** Map RevenueCat entitlement ID → tier name + monthly credits. */
const ENTITLEMENT_MAP: Record<string, { tier: string; credits: number }> = {
    "entl0aba27660b": { tier: "ultra", credits: 500 },
    "entl2665d1fa2e": { tier: "pro", credits: 200 },
};

function getSupabaseClient() {
    return createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
        auth: { persistSession: false },
    });
}

Deno.serve(async (req) => {
    if (req.method !== "POST") {
        return new Response(JSON.stringify({ error: "Method not allowed" }), {
            status: 405,
            headers: { "Content-Type": "application/json" },
        });
    }

    // Verify user JWT — get authenticated user ID from Supabase auth
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
        return new Response(JSON.stringify({ error: "Missing authorization" }), {
            status: 401,
            headers: { "Content-Type": "application/json" },
        });
    }

    // Use anon client to verify JWT
    const userClient = createClient(
        SUPABASE_URL,
        Deno.env.get("SUPABASE_ANON_KEY")!,
        { auth: { persistSession: false }, global: { headers: { Authorization: authHeader } } },
    );
    const { data: { user }, error: authError } = await userClient.auth.getUser();
    if (authError || !user) {
        return new Response(JSON.stringify({ error: "Unauthorized" }), {
            status: 401,
            headers: { "Content-Type": "application/json" },
        });
    }

    try {
        const supabase = getSupabaseClient();
        const userId = user.id;

        // 1. Get revenuecat_app_user_id from profile
        const { data: profile, error: profileErr } = await supabase
            .from("profiles")
            .select("revenuecat_app_user_id")
            .eq("id", userId)
            .maybeSingle();

        if (profileErr || !profile?.revenuecat_app_user_id) {
            console.error("[sync-subscription] Profile not found or RC ID missing:", userId);
            return new Response(JSON.stringify({ error: "Profile not linked to RevenueCat" }), {
                status: 400,
                headers: { "Content-Type": "application/json" },
            });
        }

        const rcUserId = profile.revenuecat_app_user_id;

        // 2. Fetch active entitlements from RevenueCat V2 API
        const rcRes = await fetch(
            `https://api.revenuecat.com/v2/projects/${RC_PROJECT_ID}/customers/${rcUserId}/active_entitlements`,
            {
                headers: {
                    "Authorization": `Bearer ${REVENUECAT_SECRET_KEY}`,
                    "Content-Type": "application/json",
                },
            },
        );

        if (!rcRes.ok) {
            const body = await rcRes.text();
            console.error("[sync-subscription] RevenueCat API error:", rcRes.status, body);
            return new Response(JSON.stringify({ error: "RevenueCat API error" }), {
                status: 502,
                headers: { "Content-Type": "application/json" },
            });
        }

        const rcData = await rcRes.json() as {
            items: Array<{ entitlement_id: string; expires_at: number }>;
        };

        // 3. Determine highest tier from active entitlements
        // Priority: ultra > pro > free
        let resolvedTier: string | null = null;
        let resolvedCredits = 0;
        let resolvedExpiresAt: string | null = null;

        // Check ultra first, then pro
        const tierPriority = ["entl0aba27660b", "entl2665d1fa2e"];
        for (const entitlementId of tierPriority) {
            const match = rcData.items.find((e) => e.entitlement_id === entitlementId);
            if (match) {
                const info = ENTITLEMENT_MAP[entitlementId];
                resolvedTier = info.tier;
                resolvedCredits = info.credits;
                resolvedExpiresAt = match.expires_at
                    ? new Date(match.expires_at).toISOString()
                    : null;
                break;
            }
        }

        const isPremium = resolvedTier !== null;

        // 4. Update subscription status in profiles
        const { error: statusErr } = await supabase.rpc("update_subscription_status", {
            p_user_id: userId,
            p_is_premium: isPremium,
            p_tier: resolvedTier,
            p_expires_at: resolvedExpiresAt,
        });

        if (statusErr) {
            console.error("[sync-subscription] update_subscription_status error:", statusErr);
            return new Response(JSON.stringify({ error: "Failed to update subscription status" }), {
                status: 500,
                headers: { "Content-Type": "application/json" },
            });
        }

        // 5. Grant credits if active subscription AND not already granted this billing period
        if (isPremium && resolvedCredits > 0) {
            const billingPeriodStart = new Date();
            billingPeriodStart.setDate(billingPeriodStart.getDate() - 30);

            const { data: existing } = await supabase
                .from("credit_transactions")
                .select("id")
                .eq("user_id", userId)
                .eq("type", "subscription")
                .gte("created_at", billingPeriodStart.toISOString())
                .maybeSingle();

            if (!existing) {
                const referenceId = `rc-sync-${userId}-${resolvedExpiresAt ?? "unlimited"}`;
                const { error: creditErr } = await supabase.rpc("grant_subscription_credits", {
                    p_user_id: userId,
                    p_amount: resolvedCredits,
                    p_description: `${resolvedTier} subscription — sync`,
                    p_reference_id: referenceId,
                });

                if (creditErr) {
                    console.error("[sync-subscription] grant_subscription_credits error:", creditErr);
                    // Non-fatal: subscription status already updated
                }
            }
        }

        console.log(
            `[sync-subscription] Synced user ${userId}: tier=${resolvedTier ?? "free"}, premium=${isPremium}`
        );

        return new Response(
            JSON.stringify({
                ok: true,
                tier: resolvedTier,
                is_premium: isPremium,
                expires_at: resolvedExpiresAt,
            }),
            { status: 200, headers: { "Content-Type": "application/json" } },
        );
    } catch (error) {
        console.error("[sync-subscription] Unexpected error:", error);
        return new Response(JSON.stringify({ error: "Internal server error" }), {
            status: 500,
            headers: { "Content-Type": "application/json" },
        });
    }
});
