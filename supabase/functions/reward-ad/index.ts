import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

// Google AdMob SSV verifier keys URL — keys rotate occasionally; fetched per-request.
const ADMOB_VERIFIER_KEYS_URL =
  "https://www.gstatic.com/admob/reward/verifier-keys.json";

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

// ---------------------------------------------------------------------------
// Auth helper — shared between request-nonce and claim actions
// ---------------------------------------------------------------------------
async function authenticateUser(
  req: Request,
  supabase: ReturnType<typeof getSupabaseClient>,
): Promise<{ user: { id: string } } | { error: Response }> {
  const headers = corsHeaders();
  const authHeader = req.headers.get("Authorization");
  if (!authHeader?.startsWith("Bearer ")) {
    return {
      error: new Response(
        JSON.stringify({ error: "Missing authorization header" }),
        {
          status: 401,
          headers: { ...headers, "Content-Type": "application/json" },
        },
      ),
    };
  }

  const token = authHeader.replace("Bearer ", "");
  const {
    data: { user },
    error: authError,
  } = await supabase.auth.getUser(token);

  if (authError || !user) {
    return {
      error: new Response(
        JSON.stringify({ error: "Invalid or expired token" }),
        {
          status: 401,
          headers: { ...headers, "Content-Type": "application/json" },
        },
      ),
    };
  }

  return { user };
}

// ---------------------------------------------------------------------------
// AdMob SSV helpers
// ---------------------------------------------------------------------------

/** Thrown when the keyId from Google's SSV callback is not in the verifier keys list.
 * This is a permanent error (not transient) — Google should not retry. */
class KeyNotFoundError extends Error {
  constructor(keyId: string) {
    super(`AdMob verifier key not found for keyId=${keyId}`);
    this.name = "KeyNotFoundError";
  }
}

/**
 * Convert a DER-encoded ECDSA signature to IEEE P1363 format (r || s, 64 bytes).
 * Web Crypto API requires P1363; Google AdMob sends DER.
 *
 * DER structure (short-form lengths only, sufficient for P-256):
 *   0x30 <total-len-1-byte> 0x02 <r-len> <r-bytes> 0x02 <s-len> <s-bytes>
 * Note: multi-byte DER lengths (≥128 bytes) are not supported and not needed
 * for P-256 ECDSA signatures which are always ≤72 bytes of DER.
 */
function derToP1363(der: Uint8Array): Uint8Array {
  if (der.length < 8) throw new Error("DER too short");
  if (der[0] !== 0x30) {
    throw new Error("Invalid DER signature: missing SEQUENCE tag");
  }
  let offset = 2; // skip 0x30 and total length byte (short-form, 1 byte)

  // Parse r
  if (offset >= der.length || der[offset] !== 0x02) {
    throw new Error("Invalid DER signature: missing INTEGER tag for r");
  }
  offset++;
  const rLen = der[offset++];
  if (offset + rLen > der.length) throw new Error("DER r value out of bounds");
  // DER integers may have a leading 0x00 padding byte to indicate positive
  let rStart = offset;
  let rBytes = rLen;
  if (der[rStart] === 0x00) {
    rStart++;
    rBytes--;
  }
  if (rBytes > 32) throw new Error("DER r value too large for P-256");
  offset += rLen;

  // Parse s
  if (offset >= der.length || der[offset] !== 0x02) {
    throw new Error("Invalid DER signature: missing INTEGER tag for s");
  }
  offset++;
  const sLen = der[offset++];
  if (offset + sLen > der.length) throw new Error("DER s value out of bounds");
  let sStart = offset;
  let sBytes = sLen;
  if (der[sStart] === 0x00) {
    sStart++;
    sBytes--;
  }
  if (sBytes > 32) throw new Error("DER s value too large for P-256");

  // Build 64-byte P1363: r (32 bytes, zero-padded left) || s (32 bytes, zero-padded left)
  const p1363 = new Uint8Array(64);
  p1363.set(der.slice(rStart, rStart + rBytes), 32 - rBytes);
  p1363.set(der.slice(sStart, sStart + sBytes), 64 - sBytes);
  return p1363;
}

/** Parse a PEM public key block → raw bytes (strips header/footer and base64-decodes). */
function pemToBytes(pem: string): Uint8Array {
  const b64 = pem
    .replace(/-----BEGIN PUBLIC KEY-----/, "")
    .replace(/-----END PUBLIC KEY-----/, "")
    .replace(/\s+/g, "");
  const binary = atob(b64);
  return Uint8Array.from(binary, (c) => c.charCodeAt(0));
}

/** base64url-decode a string to Uint8Array. */
function base64UrlDecode(b64url: string): Uint8Array {
  const b64 = b64url.replace(/-/g, "+").replace(/_/g, "/");
  const padded = b64 + "==".slice(0, (4 - (b64.length % 4)) % 4);
  const binary = atob(padded);
  return Uint8Array.from(binary, (c) => c.charCodeAt(0));
}

/**
 * Verify Google AdMob SSV ECDSA P-256/SHA-256 signature.
 *
 * @param message     - The raw query string bytes to verify (all params except `signature`)
 * @param signatureB64url - base64url-encoded DER signature from Google
 * @param keyId       - numeric key ID to look up in Google's verifier keys
 * @returns true if signature is valid
 */
async function verifyGoogleSsvSignature(
  message: Uint8Array,
  signatureB64url: string,
  keyId: string,
): Promise<boolean> {
  // Fetch Google's public verifier keys with a 5-second timeout.
  // Keys rotate infrequently; no caching needed in a stateless edge function.
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), 5000);
  let keysResp: Response;
  try {
    keysResp = await fetch(ADMOB_VERIFIER_KEYS_URL, {
      signal: controller.signal,
    });
  } finally {
    clearTimeout(timer);
  }
  if (!keysResp.ok) {
    throw new Error(`Failed to fetch AdMob verifier keys: ${keysResp.status}`);
  }
  const keysJson = (await keysResp.json()) as {
    keys: Array<{ keyId: number; pem: string }>;
  };

  const keyEntry = keysJson.keys.find((k) => String(k.keyId) === keyId);
  if (!keyEntry) {
    // Permanent error — key rotation means this keyId is no longer valid.
    // Caller should return 403, not 500, so Google doesn't retry indefinitely.
    throw new KeyNotFoundError(keyId);
  }

  // Import the SPKI key from PEM
  const spkiBytes = pemToBytes(keyEntry.pem);
  const cryptoKey = await crypto.subtle.importKey(
    "spki",
    spkiBytes,
    { name: "ECDSA", namedCurve: "P-256" },
    false,
    ["verify"],
  );

  // Convert DER signature → P1363 (required by Web Crypto)
  const derBytes = base64UrlDecode(signatureB64url);
  const p1363 = derToP1363(derBytes);

  return await crypto.subtle.verify(
    { name: "ECDSA", hash: "SHA-256" },
    cryptoKey,
    p1363,
    message,
  );
}

// ---------------------------------------------------------------------------
// Action: ssv-callback (Google server-to-server GET, no JWT auth)
// ---------------------------------------------------------------------------
async function handleSsvCallback(
  req: Request,
  supabase: ReturnType<typeof getSupabaseClient>,
): Promise<Response> {
  const url = new URL(req.url);
  const params = url.searchParams;

  const signature = params.get("signature");
  const keyId = params.get("key_id");
  const customData = params.get("custom_data"); // our nonce
  const userId = params.get("user_id"); // Supabase UUID passed via AdMob SDK

  // Validate UUID format before any logging to prevent log injection from
  // attacker-controlled query params.
  const UUID_RE =
    /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

  if (!signature || !keyId) {
    console.warn("[reward-ad] SSV callback missing signature or key_id");
    return new Response(
      JSON.stringify({ error: "Missing signature or key_id" }),
      { status: 400, headers: { "Content-Type": "application/json" } },
    );
  }
  if (!customData) {
    console.warn("[reward-ad] SSV callback missing custom_data (nonce)");
    return new Response(JSON.stringify({ error: "Missing custom_data" }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    });
  }
  if (!userId || !UUID_RE.test(userId)) {
    console.warn("[reward-ad] SSV callback missing or invalid user_id");
    return new Response(
      JSON.stringify({ error: "Missing or invalid user_id" }),
      {
        status: 400,
        headers: { "Content-Type": "application/json" },
      },
    );
  }

  // Build the message Google signed: raw query string MINUS `&signature=<value>`.
  // Google always appends `signature` last, so we split on the last occurrence.
  // Using lastIndexOf on the raw query avoids any re-encoding round-trip issues
  // (params.get() decodes, encodeURIComponent re-encodes — not always identical).
  const rawQuery = url.search.slice(1); // drop leading "?"
  const sigSepIdx = rawQuery.lastIndexOf("&signature=");
  const messageStr = sigSepIdx !== -1 ? rawQuery.slice(0, sigSepIdx) : rawQuery;
  const message = new TextEncoder().encode(messageStr);

  let valid = false;
  try {
    valid = await verifyGoogleSsvSignature(message, signature, keyId);
  } catch (err) {
    if (err instanceof KeyNotFoundError) {
      // Permanent error: keyId is unknown (rotated key or forged request).
      // Return 403 so Google does NOT retry — retrying won't help.
      console.error(`[reward-ad] SSV unknown keyId=${keyId}`);
      return new Response(JSON.stringify({ error: "Unknown key" }), {
        status: 403,
        headers: { "Content-Type": "application/json" },
      });
    }
    // Transient error (key fetch timeout, DER parse failure, etc.) — 500 triggers retry.
    console.error("[reward-ad] SSV signature verification error:", err);
    return new Response(
      JSON.stringify({ error: "Signature verification failed" }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    );
  }

  if (!valid) {
    console.warn(
      `[reward-ad] SSV invalid signature for user=${userId} nonce=${customData}`,
    );
    return new Response(JSON.stringify({ error: "Invalid signature" }), {
      status: 403,
      headers: { "Content-Type": "application/json" },
    });
  }

  // Signature verified — grant the reward
  const { data, error } = await supabase.rpc("claim_ad_reward", {
    p_user_id: userId,
    p_nonce: customData,
  });

  if (error) {
    console.error(
      `[reward-ad] SSV claim_ad_reward RPC error for user=${userId}:`,
      error,
    );
    return new Response(
      JSON.stringify({ error: "Failed to process ad reward" }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    );
  }

  if (data.success === false) {
    // Non-fatal failures (already claimed, daily limit). Return 200 so Google
    // doesn't retry — the reward was intentionally withheld, not a server error.
    console.log(
      `[reward-ad] SSV claim skipped for user=${userId}: ${data.error}`,
    );
    return new Response(
      JSON.stringify({ ok: true, skipped: true, reason: data.error }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" },
      },
    );
  }

  console.log(
    `[reward-ad] SSV claimed for user=${userId}: +${data.credits_awarded} credits`,
  );
  return new Response(JSON.stringify({ ok: true }), {
    status: 200,
    headers: { "Content-Type": "application/json" },
  });
}

// ---------------------------------------------------------------------------
// Action: request-nonce
// ---------------------------------------------------------------------------
async function handleRequestNonce(
  userId: string,
  supabase: ReturnType<typeof getSupabaseClient>,
  headers: Record<string, string>,
): Promise<Response> {
  const { data, error } = await supabase.rpc("request_ad_nonce", {
    p_user_id: userId,
  });

  if (error) {
    console.error(`[reward-ad] request-nonce RPC error for ${userId}:`, error);
    return new Response(JSON.stringify({ error: "Failed to generate nonce" }), {
      status: 500,
      headers: { ...headers, "Content-Type": "application/json" },
    });
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
// Action: claim (client-side fallback — idempotent via nonce)
// ---------------------------------------------------------------------------
async function handleClaim(
  userId: string,
  nonce: string,
  supabase: ReturnType<typeof getSupabaseClient>,
  headers: Record<string, string>,
): Promise<Response> {
  const { data, error } = await supabase.rpc("claim_ad_reward", {
    p_user_id: userId,
    p_nonce: nonce,
  });

  if (error) {
    console.error(`[reward-ad] claim RPC error for ${userId}:`, error);
    return new Response(
      JSON.stringify({ error: "Failed to process ad reward" }),
      {
        status: 500,
        headers: { ...headers, "Content-Type": "application/json" },
      },
    );
  }

  if (data.success === false) {
    const statusCode =
      data.error === "daily_limit_reached"
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
      `Balance: ${data.new_balance}, Ads today: ${data.ads_today}`,
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

    // SSV callback is a server-to-server GET from Google — no JWT, separate routing.
    if (action === "ssv-callback") {
      if (req.method !== "GET") {
        return new Response(JSON.stringify({ error: "Method not allowed" }), {
          status: 405,
          headers: { ...headers, "Content-Type": "application/json" },
        });
      }
      const supabase = getSupabaseClient();
      return await handleSsvCallback(req, supabase);
    }

    if (!action || !["request-nonce", "claim"].includes(action)) {
      return new Response(
        JSON.stringify({
          error:
            "Invalid action. Use ?action=request-nonce, ?action=claim, or ?action=ssv-callback",
        }),
        {
          status: 400,
          headers: { ...headers, "Content-Type": "application/json" },
        },
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
        {
          status: 400,
          headers: { ...headers, "Content-Type": "application/json" },
        },
      );
    }

    return await handleClaim(userId, nonce, supabase, headers);
  } catch (error) {
    console.error("[reward-ad] Unexpected error:", error);
    return new Response(
      JSON.stringify({
        error: error instanceof Error ? error.message : "Unknown error",
      }),
      {
        status: 500,
        headers: { ...headers, "Content-Type": "application/json" },
      },
    );
  }
});
