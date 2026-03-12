import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const REVENUECAT_SECRET_KEY = Deno.env.get("REVENUECAT_SECRET_KEY")!;

const RC_PROJECT_ID = Deno.env.get("REVENUECAT_PROJECT_ID");
if (!RC_PROJECT_ID)
  throw new Error("REVENUECAT_PROJECT_ID env var is required");

/** Map RevenueCat entitlement ID → tier name + monthly credits. */
const ENTITLEMENT_MAP: Record<string, { tier: string; credits: number }> = {
  entl0aba27660b: { tier: "ultra", credits: 500 },
  entl2665d1fa2e: { tier: "pro", credits: 200 },
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

  try {
    const supabase = getSupabaseClient();
    const userId = user.id;

    // 1. Get revenuecat_app_user_id + current premium state from profile
    const { data: profile, error: profileErr } = await supabase
      .from("profiles")
      .select("revenuecat_app_user_id, is_premium, updated_at")
      .eq("id", userId)
      .maybeSingle();

    // Fall back to userId directly — RC app user ID is always set to
    // Supabase user ID via Purchases.logIn(userId) in auth flow.
    const rcUserId = profile?.revenuecat_app_user_id ?? userId;

    if (profileErr) {
      console.error(
        "[sync-subscription] Profile fetch error:",
        userId,
        profileErr,
      );
    } else if (!profile?.revenuecat_app_user_id) {
      console.warn(
        "[sync-subscription] revenuecat_app_user_id missing, using userId as fallback:",
        userId,
      );
    }

    // 2. Fetch active entitlements from RevenueCat V2 API (8s timeout)
    const rcController = new AbortController();
    const rcTimeout = setTimeout(() => rcController.abort(), 8000);
    let rcRes: Response;
    try {
      rcRes = await fetch(
        `https://api.revenuecat.com/v2/projects/${RC_PROJECT_ID}/customers/${rcUserId}/active_entitlements`,
        {
          headers: {
            Authorization: `Bearer ${REVENUECAT_SECRET_KEY}`,
            "Content-Type": "application/json",
          },
          signal: rcController.signal,
        },
      );
    } finally {
      clearTimeout(rcTimeout);
    }

    if (!rcRes.ok) {
      const body = await rcRes.text();
      console.error(
        "[sync-subscription] RevenueCat API error:",
        rcRes.status,
        body,
      );
      return new Response(JSON.stringify({ error: "RevenueCat API error" }), {
        status: 502,
        headers: { "Content-Type": "application/json" },
      });
    }

    const rcData = (await rcRes.json()) as {
      // RC V2 API returns expires_at as ISO 8601 string or null (lifetime)
      items: Array<{ entitlement_id: string; expires_at: string | null }>;
    };

    // 3. Determine highest tier from active entitlements
    // Priority: ultra > pro > free
    let resolvedTier: string | null = null;
    let resolvedExpiresAt: string | null = null;

    // Check ultra first, then pro
    const tierPriority = ["entl0aba27660b", "entl2665d1fa2e"];
    for (const entitlementId of tierPriority) {
      const match = rcData.items.find(
        (e) => e.entitlement_id === entitlementId,
      );
      if (match) {
        const info = ENTITLEMENT_MAP[entitlementId];
        resolvedTier = info.tier;
        resolvedExpiresAt = match.expires_at
          ? new Date(match.expires_at).toISOString()
          : null;
        break;
      }
    }

    const isPremium = resolvedTier !== null;

    // GUARD: If RC returns no active entitlements, check whether we should downgrade.
    // Race condition: verify-google-purchase sets is_premium=true immediately after purchase,
    // but RC may not yet know about the purchase (Pub/Sub latency, usually <5s).
    // To avoid immediately undoing a successful purchase, skip downgrade within 5 minutes
    // of the profile being set premium. After 5 minutes, trust RC as authoritative.
    if (!isPremium) {
      const profileUpdatedAt = profile?.updated_at
        ? new Date(profile.updated_at)
        : null;
      const fiveMinutesAgo = new Date(Date.now() - 5 * 60 * 1000);
      const isRecentlyUpdated =
        profile?.is_premium === true &&
        profileUpdatedAt !== null &&
        profileUpdatedAt > fiveMinutesAgo;

      if (isRecentlyUpdated) {
        console.warn(
          `[sync-subscription] RC returned 0 entitlements for ${userId} but profile was updated < 5min ago — skipping (RC processing in flight)`,
        );
        return new Response(
          JSON.stringify({
            synced: false,
            reason: "rc_processing_in_flight",
            message:
              "RC has no active entitlements but profile is recent. Skipping to avoid race condition.",
          }),
          { status: 200, headers: { "Content-Type": "application/json" } },
        );
      }

      // Profile not recently updated — RC is authoritative. Downgrade user.
      console.warn(
        `[sync-subscription] RC returned 0 entitlements for ${userId} — downgrading`,
      );
      const { error: downgradeErr } = await supabase.rpc(
        "update_subscription_status",
        {
          p_user_id: userId,
          p_is_premium: false,
          p_tier: null,
          p_expires_at: null,
        },
      );
      if (downgradeErr) {
        console.error("[sync-subscription] downgrade error:", downgradeErr);
        return new Response(
          JSON.stringify({ error: "Failed to downgrade subscription status" }),
          { status: 500, headers: { "Content-Type": "application/json" } },
        );
      }
      return new Response(
        JSON.stringify({
          synced: true,
          is_premium: false,
          reason: "no_active_entitlements",
          message: "RC has no active entitlements. User downgraded.",
        }),
        { status: 200, headers: { "Content-Type": "application/json" } },
      );
    }

    // Update is_premium + tier only (NO credit grant — webhook owns credits)
    const { error: statusErr } = await supabase.rpc(
      "update_subscription_status",
      {
        p_user_id: userId,
        p_is_premium: true,
        p_tier: resolvedTier,
        p_expires_at: resolvedExpiresAt,
      },
    );

    if (statusErr) {
      console.error(
        "[sync-subscription] update_subscription_status error:",
        statusErr,
      );
      return new Response(
        JSON.stringify({ error: "Failed to update subscription status" }),
        { status: 500, headers: { "Content-Type": "application/json" } },
      );
    }

    console.log(
      `[sync-subscription] Synced ${userId}: tier=${resolvedTier}, expires=${resolvedExpiresAt ?? "unlimited"}`,
    );

    return new Response(
      JSON.stringify({
        synced: true,
        tier: resolvedTier,
        is_premium: true,
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
