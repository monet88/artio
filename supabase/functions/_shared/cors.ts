/**
 * Shared CORS helpers for Supabase Edge Functions.
 *
 * Usage:
 *   import { corsHeaders, handleCorsIfPreflight } from "../_shared/cors.ts";
 */

/** Returns standard CORS headers using CORS_ALLOWED_ORIGIN env var. */
export function corsHeaders(): Record<string, string> {
    const allowedOrigin =
        Deno.env.get("CORS_ALLOWED_ORIGIN") ?? "https://artio.app";
    return {
        "Access-Control-Allow-Origin": allowedOrigin,
        "Access-Control-Allow-Headers":
            "authorization, x-client-info, apikey, content-type",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
    };
}

/**
 * Returns an OPTIONS preflight response if the request is a CORS preflight,
 * otherwise returns null so the caller can continue handling the request.
 */
export function handleCorsIfPreflight(req: Request): Response | null {
    if (req.method === "OPTIONS") {
        return new Response("ok", { headers: corsHeaders() });
    }
    return null;
}
