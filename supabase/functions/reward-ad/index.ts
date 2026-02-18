import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

function getSupabaseClient() {
    return createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
        auth: { persistSession: false },
    });
}

Deno.serve(async (req) => {
    const allowedOrigin =
        Deno.env.get("CORS_ALLOWED_ORIGIN") ?? "https://artio.app";
    const corsHeaders = {
        "Access-Control-Allow-Origin": allowedOrigin,
        "Access-Control-Allow-Headers":
            "authorization, x-client-info, apikey, content-type",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
    };

    if (req.method === "OPTIONS") {
        return new Response("ok", { headers: corsHeaders });
    }

    try {
        // Authenticate user via JWT
        const authHeader = req.headers.get("Authorization");
        if (!authHeader?.startsWith("Bearer ")) {
            return new Response(
                JSON.stringify({ error: "Missing authorization header" }),
                {
                    status: 401,
                    headers: { ...corsHeaders, "Content-Type": "application/json" },
                }
            );
        }

        const token = authHeader.replace("Bearer ", "");
        const supabase = getSupabaseClient();

        const {
            data: { user },
            error: authError,
        } = await supabase.auth.getUser(token);
        if (authError || !user) {
            return new Response(
                JSON.stringify({ error: "Invalid or expired token" }),
                {
                    status: 401,
                    headers: { ...corsHeaders, "Content-Type": "application/json" },
                }
            );
        }

        // Call the atomic reward function
        const { data, error } = await supabase.rpc("reward_ad_credits", {
            p_user_id: user.id,
        });

        if (error) {
            console.error(`[reward-ad] RPC error for ${user.id}:`, error);
            return new Response(
                JSON.stringify({ error: "Failed to process ad reward" }),
                {
                    status: 500,
                    headers: { ...corsHeaders, "Content-Type": "application/json" },
                }
            );
        }

        // The RPC returns a JSON object with success/error fields
        if (data.success === false) {
            const statusCode = data.error === "daily_limit_reached" ? 429 : 400;
            return new Response(JSON.stringify(data), {
                status: statusCode,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        console.log(
            `[reward-ad] Awarded ${data.credits_awarded} credits to ${user.id}. ` +
            `Balance: ${data.new_balance}, Ads today: ${data.ads_today}`
        );

        return new Response(JSON.stringify(data), {
            status: 200,
            headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
    } catch (error) {
        console.error("[reward-ad] Unexpected error:", error);
        return new Response(
            JSON.stringify({
                error: error instanceof Error ? error.message : "Unknown error",
            }),
            {
                status: 500,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            }
        );
    }
});
