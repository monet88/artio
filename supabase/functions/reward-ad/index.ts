import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import { corsHeaders, handleCorsIfPreflight } from "../_shared/cors.ts";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

function getSupabaseClient() {
    return createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
        auth: { persistSession: false },
    });
}

// ---------------------------------------------------------------------------
// Auth helper — shared between both actions
// ---------------------------------------------------------------------------
async function authenticateUser(
    req: Request,
    supabase: ReturnType<typeof getSupabaseClient>
): Promise<{ user: { id: string } } | { error: Response }> {
    const headers = corsHeaders();
    const authHeader = req.headers.get("Authorization");
    if (!authHeader?.startsWith("Bearer ")) {
        return {
            error: new Response(
                JSON.stringify({ error: "Missing authorization header" }),
                { status: 401, headers: { ...headers, "Content-Type": "application/json" } }
            ),
        };
    }

    const token = authHeader.replace("Bearer ", "");
    const { data: { user }, error: authError } = await supabase.auth.getUser(token);

    if (authError || !user) {
        return {
            error: new Response(
                JSON.stringify({ error: "Invalid or expired token" }),
                { status: 401, headers: { ...headers, "Content-Type": "application/json" } }
            ),
        };
    }

    return { user };
}

// ---------------------------------------------------------------------------
// Action: request-nonce
// ---------------------------------------------------------------------------
async function handleRequestNonce(
    userId: string,
    supabase: ReturnType<typeof getSupabaseClient>,
    headers: Record<string, string>
): Promise<Response> {
    const { data, error } = await supabase.rpc("request_ad_nonce", {
        p_user_id: userId,
    });

    if (error) {
        console.error(`[reward-ad] request-nonce RPC error for ${userId}:`, error);
        return new Response(
            JSON.stringify({ error: "Failed to generate nonce" }),
            { status: 500, headers: { ...headers, "Content-Type": "application/json" } }
        );
    }

    if (data.success === false) {
        const statusCode = data.error === "daily_limit_reached" ? 429 : 400;
        return new Response(JSON.stringify(data), {
            status: statusCode,
            headers: { ...headers, "Content-Type": "application/json" },
        });
    }

    console.log(`[reward-ad] request-nonce for ${userId}: nonce=${data.nonce}`);

    return new Response(JSON.stringify(data), {
        status: 200,
        headers: { ...headers, "Content-Type": "application/json" },
    });
}

// ---------------------------------------------------------------------------
// Action: claim
// ---------------------------------------------------------------------------
async function handleClaim(
    userId: string,
    nonce: string,
    supabase: ReturnType<typeof getSupabaseClient>,
    headers: Record<string, string>
): Promise<Response> {
    const { data, error } = await supabase.rpc("claim_ad_reward", {
        p_user_id: userId,
        p_nonce: nonce,
    });

    if (error) {
        console.error(`[reward-ad] claim RPC error for ${userId}:`, error);
        return new Response(
            JSON.stringify({ error: "Failed to process ad reward" }),
            { status: 500, headers: { ...headers, "Content-Type": "application/json" } }
        );
    }

    if (data.success === false) {
        const statusCode = data.error === "daily_limit_reached"
            ? 429
            : data.error === "invalid_or_expired_nonce"
                ? 400
                : 400;
        return new Response(JSON.stringify(data), {
            status: statusCode,
            headers: { ...headers, "Content-Type": "application/json" },
        });
    }

    console.log(
        `[reward-ad] claim for ${userId}: awarded ${data.credits_awarded} credits. ` +
        `Balance: ${data.new_balance}, Ads today: ${data.ads_today}`
    );

    return new Response(JSON.stringify(data), {
        status: 200,
        headers: { ...headers, "Content-Type": "application/json" },
    });
}

// ---------------------------------------------------------------------------
// Main handler
// ---------------------------------------------------------------------------
Deno.serve(async (req) => {
    const preflight = handleCorsIfPreflight(req);
    if (preflight) return preflight;

    const headers = corsHeaders();

    try {
        const url = new URL(req.url);
        const action = url.searchParams.get("action");

        if (!action || !["request-nonce", "claim"].includes(action)) {
            return new Response(
                JSON.stringify({
                    error: 'Invalid action. Use ?action=request-nonce or ?action=claim',
                }),
                { status: 400, headers: { ...headers, "Content-Type": "application/json" } }
            );
        }

        const supabase = getSupabaseClient();
        const authResult = await authenticateUser(req, supabase);

        if ("error" in authResult) return authResult.error;

        const userId = authResult.user.id;

        if (action === "request-nonce") {
            return await handleRequestNonce(userId, supabase, headers);
        }

        // action === "claim"
        const body = await req.json().catch(() => ({}));
        const nonce = (body as Record<string, unknown>)?.nonce;

        if (!nonce || typeof nonce !== "string") {
            return new Response(
                JSON.stringify({ error: "Missing required field: nonce" }),
                { status: 400, headers: { ...headers, "Content-Type": "application/json" } }
            );
        }

        return await handleClaim(userId, nonce, supabase, headers);
    } catch (error) {
        console.error("[reward-ad] Unexpected error:", error);
        return new Response(
            JSON.stringify({
                error: error instanceof Error ? error.message : "Unknown error",
            }),
            { status: 500, headers: { ...headers, "Content-Type": "application/json" } }
        );
    }
});
