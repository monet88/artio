// supabase/functions/verify-google-purchase/index.ts
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const GOOGLE_PLAY_SERVICE_ACCOUNT_JSON = Deno.env.get("GOOGLE_PLAY_SERVICE_ACCOUNT_JSON")!;

const PACKAGE_NAME = "com.artio.artio";

/** Map product ID prefix → tier name + credits */
function getTierInfo(productId: string): { tier: string; credits: number } | null {
  if (productId.startsWith("artio_ultra_")) return { tier: "ultra", credits: 500 };
  if (productId.startsWith("artio_pro_")) return { tier: "pro", credits: 200 };
  return null;
}

/** Generate a Google OAuth2 access token using service account JWT (RS256). */
async function getGoogleAccessToken(): Promise<string> {
  const sa = JSON.parse(GOOGLE_PLAY_SERVICE_ACCOUNT_JSON);
  const now = Math.floor(Date.now() / 1000);
  const header = { alg: "RS256", typ: "JWT" };
  const payload = {
    iss: sa.client_email,
    scope: "https://www.googleapis.com/auth/androidpublisher",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  };

  const encode = (obj: unknown) =>
    btoa(JSON.stringify(obj)).replace(/=/g, "").replace(/\+/g, "-").replace(/\//g, "_");

  const signingInput = `${encode(header)}.${encode(payload)}`;

  // Import RSA private key
  const pemBody = sa.private_key
    .replace("-----BEGIN RSA PRIVATE KEY-----", "")
    .replace("-----END RSA PRIVATE KEY-----", "")
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replace(/\s/g, "");
  const keyBytes = Uint8Array.from(atob(pemBody), (c) => c.charCodeAt(0));
  const cryptoKey = await crypto.subtle.importKey(
    "pkcs8",
    keyBytes,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );

  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    cryptoKey,
    new TextEncoder().encode(signingInput),
  );
  const sigB64 = btoa(String.fromCharCode(...new Uint8Array(signature)))
    .replace(/=/g, "").replace(/\+/g, "-").replace(/\//g, "_");

  const jwt = `${signingInput}.${sigB64}`;

  // Exchange JWT for access token
  const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: `grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=${jwt}`,
  });
  if (!tokenRes.ok) {
    const err = await tokenRes.text();
    throw new Error(`Google OAuth2 token error: ${err}`);
  }
  const { access_token } = await tokenRes.json() as { access_token: string };
  return access_token;
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

  const userClient = createClient(SUPABASE_URL, Deno.env.get("SUPABASE_ANON_KEY")!, {
    auth: { persistSession: false },
    global: { headers: { Authorization: authHeader } },
  });
  const { data: { user }, error: authError } = await userClient.auth.getUser();
  if (authError || !user) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), {
      status: 401,
      headers: { "Content-Type": "application/json" },
    });
  }

  // Parse request body
  let purchaseToken: string;
  let productId: string;
  try {
    const body = await req.json() as { purchaseToken?: string; productId?: string };
    purchaseToken = body.purchaseToken ?? "";
    productId = body.productId ?? "";
    if (!purchaseToken || !productId) throw new Error("missing fields");
  } catch {
    return new Response(JSON.stringify({ error: "Body must include purchaseToken and productId" }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    });
  }

  const tierInfo = getTierInfo(productId);
  if (!tierInfo) {
    return new Response(JSON.stringify({ error: `Unknown productId: ${productId}` }), {
      status: 400,
      headers: { "Content-Type": "application/json" },
    });
  }

  try {
    // Call Google Play Publisher API
    const accessToken = await getGoogleAccessToken();
    const gpUrl = `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${PACKAGE_NAME}/purchases/subscriptions/${productId}/tokens/${purchaseToken}`;
    const gpRes = await fetch(gpUrl, {
      headers: { Authorization: `Bearer ${accessToken}` },
    });

    if (!gpRes.ok) {
      const errBody = await gpRes.text();
      console.error("[verify-google-purchase] Google Play API error:", gpRes.status, errBody);
      return new Response(JSON.stringify({ error: "Google Play validation failed", detail: errBody }), {
        status: 502,
        headers: { "Content-Type": "application/json" },
      });
    }

    const gpData = await gpRes.json() as {
      purchaseState?: number; // 0=purchased, 1=cancelled, 2=pending
      orderId?: string;
      expiryTimeMillis?: string;
      startTimeMillis?: string;
    };

    console.log(`[verify-google-purchase] GP response for ${user.id}: state=${gpData.purchaseState} orderId=${gpData.orderId}`);

    // purchaseState: 0 = active purchase
    if (gpData.purchaseState !== 0 && gpData.purchaseState !== undefined) {
      return new Response(JSON.stringify({
        verified: false,
        reason: `purchaseState=${gpData.purchaseState}`,
      }), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    }

    const orderId = gpData.orderId ?? purchaseToken; // fallback to token if no orderId
    const expiresAt = gpData.expiryTimeMillis
      ? new Date(Number(gpData.expiryTimeMillis)).toISOString()
      : null;

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
      auth: { persistSession: false },
    });

    // Update subscription status
    const { error: statusErr } = await supabase.rpc("update_subscription_status", {
      p_user_id: user.id,
      p_is_premium: true,
      p_tier: tierInfo.tier,
      p_expires_at: expiresAt,
    });
    if (statusErr) {
      console.error("[verify-google-purchase] update_subscription_status error:", statusErr);
      return new Response(JSON.stringify({ error: "Failed to update subscription status" }), {
        status: 500,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Grant credits (idempotent via orderId — same orderId RC webhook uses as transaction_id)
    const { error: creditErr } = await supabase.rpc("grant_subscription_credits", {
      p_user_id: user.id,
      p_amount: tierInfo.credits,
      p_description: `${tierInfo.tier} subscription — verified via Google Play API`,
      p_reference_id: `gp-${orderId}`,
    });
    if (creditErr) {
      console.error("[verify-google-purchase] grant_subscription_credits error:", creditErr);
      // Don't fail — subscription status already updated
    }

    console.log(`[verify-google-purchase] Verified ${user.id}: tier=${tierInfo.tier}, ${tierInfo.credits} credits, orderId=${orderId}`);

    return new Response(JSON.stringify({
      verified: true,
      tier: tierInfo.tier,
      credits: tierInfo.credits,
      orderId,
    }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error("[verify-google-purchase] Unexpected error:", err);
    return new Response(JSON.stringify({ error: "Internal server error" }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
