import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const STORAGE_BUCKET = "generated-images";

function getSupabaseClient() {
  return createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
    auth: { persistSession: false },
  });
}

// Inlined from _shared/cors.ts (MCP deploy does not resolve cross-directory imports)
function corsHeaders(): Record<string, string> {
  const allowedOrigin =
    Deno.env.get("CORS_ALLOWED_ORIGIN") ?? "https://artio.app";
  return {
    "Access-Control-Allow-Origin": allowedOrigin,
    "Access-Control-Allow-Headers":
      "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
  };
}

function handleCorsIfPreflight(req: Request): Response | null {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders() });
  }
  return null;
}

Deno.serve(async (req) => {
  const preflight = handleCorsIfPreflight(req);
  if (preflight) return preflight;

  const headers = corsHeaders();

  try {
    // Validate JWT using service role client
    const authHeader = req.headers.get("Authorization");
    if (!authHeader?.startsWith("Bearer ")) {
      return new Response(
        JSON.stringify({ error: "Missing authorization header" }),
        { status: 401, headers: { ...headers, "Content-Type": "application/json" } },
      );
    }

    const token = authHeader.replace("Bearer ", "");
    const supabase = getSupabaseClient();

    const { data: { user }, error: authError } = await supabase.auth.getUser(token);
    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: "Invalid or expired token" }),
        { status: 401, headers: { ...headers, "Content-Type": "application/json" } },
      );
    }

    const userId = user.id;
    console.log(`[delete-account] Starting deletion for user=${userId}`);

    // Step 1: Delete all Storage objects for this user (paginated — handles >1000 files).
    // Always list at offset 0: after each successful removal the remaining files shift
    // down, so incrementing offset would skip files that moved into already-seen slots.
    const PAGE_SIZE = 1000;
    let totalRemoved = 0;
    while (true) {
      const { data: storageFiles, error: listError } = await supabase.storage
        .from(STORAGE_BUCKET)
        .list(userId, { limit: PAGE_SIZE, offset: 0 });

      if (listError) {
        console.error(`[delete-account] Storage list error for user=${userId}:`, listError.message);
        break; // Non-fatal: proceed with account deletion even if storage cleanup fails
      }
      if (!storageFiles || storageFiles.length === 0) break;

      const paths = storageFiles.map((f) => `${userId}/${f.name}`);
      const { error: removeError } = await supabase.storage
        .from(STORAGE_BUCKET)
        .remove(paths);
      if (removeError) {
        console.error(`[delete-account] Storage remove error for user=${userId}:`, removeError.message);
        break; // Cannot make progress — avoid infinite loop; proceed with account deletion
      }
      totalRemoved += paths.length;
      if (storageFiles.length < PAGE_SIZE) break; // last page
    }
    if (totalRemoved > 0) {
      console.log(`[delete-account] Removed ${totalRemoved} storage files for user=${userId}`);
    }

    // Step 2: Delete the auth user — cascades all DB tables
    const { error: deleteError } = await supabase.auth.admin.deleteUser(userId);
    if (deleteError) {
      console.error(`[delete-account] Auth delete error for user=${userId}:`, deleteError.message);
      return new Response(
        JSON.stringify({ error: "Failed to delete account" }),
        { status: 500, headers: { ...headers, "Content-Type": "application/json" } },
      );
    }

    console.log(`[delete-account] Successfully deleted user=${userId}`);
    return new Response(
      JSON.stringify({ ok: true }),
      { status: 200, headers: { ...headers, "Content-Type": "application/json" } },
    );
  } catch (error) {
    console.error("[delete-account] Unexpected error:", error);
    return new Response(
      JSON.stringify({ error: error instanceof Error ? error.message : "Unknown error" }),
      { status: 500, headers: { ...headers, "Content-Type": "application/json" } },
    );
  }
});
