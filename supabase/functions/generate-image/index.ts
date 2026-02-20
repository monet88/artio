import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import { corsHeaders, handleCorsIfPreflight } from "../_shared/cors.ts";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const KIE_API_KEY = Deno.env.get("KIE_API_KEY")!;
const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY")!;

const KIE_API_BASE = "https://api.kie.ai";
const GEMINI_API_BASE = "https://generativelanguage.googleapis.com/v1beta";

// Main provider — all models routed through KIE API
const KIE_MODELS = [
  // Google / Imagen
  "google/imagen4",
  "google/imagen4-fast",
  "google/imagen4-ultra",
  "nano-banana-pro", // NOTE: no google/ prefix per KIE API spec
  "google/nano-banana-edit",
  "google/pro-image-to-image",
  // Flux-2
  "flux-2/flex-text-to-image",
  "flux-2/flex-image-to-image",
  "flux-2/pro-text-to-image",
  "flux-2/pro-image-to-image",
  // GPT Image
  "gpt-image/1.5-text-to-image",
  "gpt-image/1.5-image-to-image",
  // Seedream
  "seedream/4.5-text-to-image",
  "seedream/4.5-edit",
] as const;

// Fallback provider — Google native Gemini models
const GEMINI_MODELS = [
  "gemini-3-pro-image-preview",
  "gemini-2.5-flash-image",
] as const;

// Server-side authoritative model costs (matches ai_models.dart)
const MODEL_CREDIT_COSTS: Record<string, number> = {
  "google/imagen4": 6,
  "google/imagen4-fast": 4,
  "google/imagen4-ultra": 12,
  "google/nano-banana-edit": 10,
  "nano-banana-pro": 10,
  "google/pro-image-to-image": 15,
  "flux-2/flex-text-to-image": 8,
  "flux-2/flex-image-to-image": 10,
  "flux-2/pro-text-to-image": 16,
  "flux-2/pro-image-to-image": 20,
  "gpt-image/1.5-text-to-image": 15,
  "gpt-image/1.5-image-to-image": 18,
  "seedream/4.5-text-to-image": 8,
  "seedream/4.5-edit": 10,
  "gemini-3-pro-image-preview": 15,
  "gemini-2.5-flash-image": 8,
};

interface GenerationRequest {
  jobId: string;
  prompt: string;
  model?: string;
  aspectRatio?: string;
  imageCount?: number;
  outputFormat?: string; // 'jpg' or 'png'
  imageInputs?: string[];
}

interface KieCreateTaskResponse {
  code: number;
  msg: string;
  data?: { taskId: string };
}

interface KieTaskDetailResponse {
  code: number;
  msg: string;
  data?: {
    taskId: string;
    status: "pending" | "processing" | "completed" | "failed";
    output?: { images?: string[]; image_url?: string };
    error?: string;
  };
}

function getSupabaseClient() {
  return createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
    auth: { persistSession: false },
  });
}

function getProvider(model: string): "kie" | "gemini" {
  if (KIE_MODELS.includes(model as typeof KIE_MODELS[number])) return "kie";
  if (GEMINI_MODELS.includes(model as typeof GEMINI_MODELS[number])) return "gemini";
  return "kie";
}

async function checkAndDeductCredits(
  supabase: ReturnType<typeof getSupabaseClient>,
  userId: string,
  amount: number,
  jobId: string
): Promise<{ success: boolean; error?: string }> {
  const { data, error } = await supabase.rpc("deduct_credits", {
    p_user_id: userId,
    p_amount: amount,
    p_description: "Image generation",
    p_reference_id: jobId,
  });

  if (error) {
    console.error(`[${jobId}] Credit deduction RPC error:`, error);
    return { success: false, error: "Credit check failed" };
  }

  // deduct_credits returns boolean: true = success, false = insufficient
  if (data === false) {
    return { success: false, error: "Insufficient credits" };
  }

  return { success: true };
}

async function refundCreditsOnFailure(
  supabase: ReturnType<typeof getSupabaseClient>,
  userId: string,
  amount: number,
  jobId: string,
  maxRetries: number = 3
): Promise<{ success: boolean; attempts: number }> {
  let lastError: unknown = null;

  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      const { error } = await supabase.rpc("refund_credits", {
        p_user_id: userId,
        p_amount: amount,
        p_description: "Generation failed — refund",
        p_reference_id: jobId,
      });

      if (error) {
        lastError = error;
        console.error(`[${jobId}] Credit refund RPC error (attempt ${attempt}/${maxRetries}):`, error);
      } else {
        console.log(`[${jobId}] Refunded ${amount} credits (attempt ${attempt})`);
        return { success: true, attempts: attempt };
      }
    } catch (err) {
      lastError = err;
      console.error(`[${jobId}] Credit refund exception (attempt ${attempt}/${maxRetries}):`, err);
    }

    // Exponential backoff before next retry
    if (attempt < maxRetries) {
      const delayMs = Math.pow(2, attempt) * 1000;
      await new Promise((resolve) => setTimeout(resolve, delayMs));
    }
  }

  // All retries exhausted — CRITICAL: requires manual intervention
  console.error(
    `[CRITICAL] Credit refund failed after ${maxRetries} attempts. ` +
    `userId=${userId}, amount=${amount}, jobId=${jobId}, lastError=`,
    lastError
  );
  return { success: false, attempts: maxRetries };
}

async function createKieTask(
  prompt: string,
  model: string,
  aspectRatio: string,
  imageCount: number,
  imageInputs?: string[]
): Promise<{ taskId: string } | { error: string }> {
  const input: Record<string, unknown> = {
    prompt,
    aspect_ratio: aspectRatio || "1:1",
    num_images: imageCount || 1,
  };

  if (imageInputs?.length) {
    input.image_input = imageInputs;
  }

  const response = await fetch(`${KIE_API_BASE}/api/v1/jobs/createTask`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${KIE_API_KEY}`,
    },
    body: JSON.stringify({ model, input }),
  });

  const result: KieCreateTaskResponse = await response.json();

  if (result.code !== 200 || !result.data?.taskId) {
    return { error: result.msg || "Failed to create Kie task" };
  }

  return { taskId: result.data.taskId };
}

async function pollKieTask(
  taskId: string,
  maxAttempts = 60,
  intervalMs = 2000
): Promise<{ images: string[] } | { error: string }> {
  for (let attempt = 0; attempt < maxAttempts; attempt++) {
    const response = await fetch(
      `${KIE_API_BASE}/api/v1/jobs/getTaskDetail?taskId=${taskId}`,
      {
        method: "GET",
        headers: { Authorization: `Bearer ${KIE_API_KEY}` },
      }
    );

    const result: KieTaskDetailResponse = await response.json();

    if (result.code !== 200) {
      return { error: result.msg || "Failed to get task status" };
    }

    const status = result.data?.status;

    if (status === "completed") {
      const images: string[] = [];
      if (result.data?.output?.images) {
        images.push(...result.data.output.images);
      } else if (result.data?.output?.image_url) {
        images.push(result.data.output.image_url);
      }
      return { images };
    }

    if (status === "failed") {
      return { error: result.data?.error || "Generation failed" };
    }

    await new Promise((resolve) => setTimeout(resolve, intervalMs));
  }

  return { error: "Task timed out" };
}

async function generateViaGemini(
  prompt: string,
  model: string,
  aspectRatio: string
): Promise<{ base64Images: string[] } | { error: string }> {
  const response = await fetch(
    `${GEMINI_API_BASE}/models/${model}:generateContent`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-goog-api-key": GEMINI_API_KEY,
      },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: {
          imageConfig: { aspectRatio: aspectRatio || "1:1" },
        },
      }),
    }
  );

  if (!response.ok) {
    const errorText = await response.text();
    return { error: `Gemini API error: ${response.status} - ${errorText}` };
  }

  const result = await response.json();
  const base64Images: string[] = [];

  for (const candidate of result.candidates || []) {
    for (const part of candidate.content?.parts || []) {
      if (part.inlineData?.data) {
        base64Images.push(part.inlineData.data);
      }
    }
  }

  if (base64Images.length === 0) {
    return { error: "No images generated" };
  }

  return { base64Images };
}

async function downloadImage(url: string): Promise<Uint8Array> {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`Failed to download image: ${response.status}`);
  }
  return new Uint8Array(await response.arrayBuffer());
}

async function uploadToStorage(
  supabase: ReturnType<typeof getSupabaseClient>,
  userId: string,
  jobId: string,
  imageData: Uint8Array,
  index: number,
  outputFormat: string = "jpg"
): Promise<string> {
  const ext = outputFormat === "png" ? "png" : "jpg";
  const contentType = outputFormat === "png" ? "image/png" : "image/jpeg";
  const fileName = index === 0 ? `${jobId}.${ext}` : `${jobId}_${index}.${ext}`;
  const storagePath = `${userId}/${fileName}`;

  const { error } = await supabase.storage
    .from("generated-images")
    .upload(storagePath, imageData, {
      contentType,
      upsert: true,
    });

  if (error) {
    throw new Error(`Storage upload failed: ${error.message}`);
  }

  return storagePath;
}

async function mirrorUrlsToStorage(
  supabase: ReturnType<typeof getSupabaseClient>,
  userId: string,
  jobId: string,
  imageUrls: string[],
  outputFormat: string = "jpg"
): Promise<string[]> {
  const storagePaths: string[] = [];

  for (let i = 0; i < imageUrls.length; i++) {
    const imageData = await downloadImage(imageUrls[i]);
    const storagePath = await uploadToStorage(supabase, userId, jobId, imageData, i, outputFormat);
    storagePaths.push(storagePath);
  }

  return storagePaths;
}

async function mirrorBase64ToStorage(
  supabase: ReturnType<typeof getSupabaseClient>,
  userId: string,
  jobId: string,
  base64Images: string[],
  outputFormat: string = "jpg"
): Promise<string[]> {
  const storagePaths: string[] = [];

  for (let i = 0; i < base64Images.length; i++) {
    const binaryString = atob(base64Images[i]);
    const bytes = new Uint8Array(binaryString.length);
    for (let j = 0; j < binaryString.length; j++) {
      bytes[j] = binaryString.charCodeAt(j);
    }

    const storagePath = await uploadToStorage(supabase, userId, jobId, bytes, i, outputFormat);
    storagePaths.push(storagePath);
  }

  return storagePaths;
}

async function updateJobStatus(
  supabase: ReturnType<typeof getSupabaseClient>,
  jobId: string,
  updates: {
    status?: string;
    provider_task_id?: string | null;
    result_urls?: string[];
    error_message?: string;
    completed_at?: string;
  }
) {
  const { error } = await supabase
    .from("generation_jobs")
    .update(updates)
    .eq("id", jobId);

  if (error) {
    console.error("Failed to update job:", error);
  }
}

Deno.serve(async (req) => {
  const preflight = handleCorsIfPreflight(req);
  if (preflight) return preflight;

  const headers = corsHeaders();

  try {
    // Extract userId from JWT token (not from request body)
    const authHeader = req.headers.get("Authorization");
    if (!authHeader?.startsWith("Bearer ")) {
      return new Response(
        JSON.stringify({ error: "Missing authorization header" }),
        { status: 401, headers: { ...headers, "Content-Type": "application/json" } }
      );
    }

    const token = authHeader.replace("Bearer ", "");
    const supabase = getSupabaseClient();

    const { data: { user }, error: authError } = await supabase.auth.getUser(token);
    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: "Invalid or expired token" }),
        { status: 401, headers: { ...headers, "Content-Type": "application/json" } }
      );
    }

    const userId = user.id; // Trusted source from JWT

    const body: GenerationRequest = await req.json();
    const {
      jobId,
      prompt,
      model = "google/imagen4",
      aspectRatio = "1:1",
      imageCount = 1,
      outputFormat = "jpg",
      imageInputs,
    } = body;

    if (!jobId || !prompt) {
      return new Response(
        JSON.stringify({ error: "Missing required fields: jobId, prompt" }),
        { status: 400, headers: { ...headers, "Content-Type": "application/json" } }
      );
    }

    // Verify job ownership
    const { data: job, error: jobError } = await supabase
      .from("generation_jobs")
      .select("user_id")
      .eq("id", jobId)
      .single();

    if (jobError || !job) {
      return new Response(
        JSON.stringify({ error: "Job not found" }),
        { status: 404, headers: { ...headers, "Content-Type": "application/json" } }
      );
    }

    if (job.user_id !== userId) {
      return new Response(
        JSON.stringify({ error: "Unauthorized: job belongs to another user" }),
        { status: 403, headers: { ...headers, "Content-Type": "application/json" } }
      );
    }
    // Resolve credit cost from server-side map
    const creditCost = MODEL_CREDIT_COSTS[model];
    if (creditCost === undefined) {
      return new Response(
        JSON.stringify({ error: `Unknown model: ${model}` }),
        { status: 400, headers: { ...headers, "Content-Type": "application/json" } }
      );
    }

    // Deduct credits before generation
    const creditResult = await checkAndDeductCredits(supabase, userId, creditCost, jobId);
    if (!creditResult.success) {
      console.log(`[${jobId}] Insufficient credits: need ${creditCost}`);
      return new Response(
        JSON.stringify({ error: creditResult.error, required: creditCost, model }),
        { status: 402, headers: { ...headers, "Content-Type": "application/json" } }
      );
    }

    console.log(`[${jobId}] Deducted ${creditCost} credits`);

    // Inner try ensures credits are refunded if any post-deduction step throws
    try {
      const provider = getProvider(model);

      await updateJobStatus(supabase, jobId, { status: "processing", provider_task_id: null });

      let storagePaths: string[] = [];

      if (provider === "kie") {
        console.log(`[${jobId}] Kie.ai generation: ${model}, count: ${imageCount}, format: ${outputFormat}`);

        const createResult = await createKieTask(prompt, model, aspectRatio, imageCount, imageInputs);

        if ("error" in createResult) {
          await refundCreditsOnFailure(supabase, userId, creditCost, jobId);
          await updateJobStatus(supabase, jobId, { status: "failed", error_message: createResult.error });
          return new Response(JSON.stringify({ error: createResult.error }), {
            status: 500,
            headers: { ...headers, "Content-Type": "application/json" },
          });
        }

        await updateJobStatus(supabase, jobId, { provider_task_id: createResult.taskId });
        console.log(`[${jobId}] Kie task: ${createResult.taskId}`);

        const pollResult = await pollKieTask(createResult.taskId);

        if ("error" in pollResult) {
          await refundCreditsOnFailure(supabase, userId, creditCost, jobId);
          await updateJobStatus(supabase, jobId, { status: "failed", error_message: pollResult.error });
          return new Response(JSON.stringify({ error: pollResult.error }), {
            status: 500,
            headers: { ...headers, "Content-Type": "application/json" },
          });
        }

        console.log(`[${jobId}] Mirroring ${pollResult.images.length} images`);
        storagePaths = await mirrorUrlsToStorage(supabase, userId, jobId, pollResult.images, outputFormat);

      } else {
        console.log(`[${jobId}] Gemini generation: ${model}, format: ${outputFormat}`);

        const geminiResult = await generateViaGemini(prompt, model, aspectRatio);

        if ("error" in geminiResult) {
          await refundCreditsOnFailure(supabase, userId, creditCost, jobId);
          await updateJobStatus(supabase, jobId, { status: "failed", error_message: geminiResult.error });
          return new Response(JSON.stringify({ error: geminiResult.error }), {
            status: 500,
            headers: { ...headers, "Content-Type": "application/json" },
          });
        }

        console.log(`[${jobId}] Mirroring ${geminiResult.base64Images.length} images`);
        storagePaths = await mirrorBase64ToStorage(supabase, userId, jobId, geminiResult.base64Images, outputFormat);
      }

      await updateJobStatus(supabase, jobId, {
        status: "completed",
        result_urls: storagePaths,
        completed_at: new Date().toISOString(),
      });

      console.log(`[${jobId}] Completed: ${storagePaths.length} images`);

      return new Response(
        JSON.stringify({ success: true, jobId, storagePaths }),
        { status: 200, headers: { ...headers, "Content-Type": "application/json" } }
      );
    } catch (postDeductionError) {
      // Refund credits if any step after deduction fails (e.g. mirroring)
      await refundCreditsOnFailure(supabase, userId, creditCost, jobId);
      const errorMsg = postDeductionError instanceof Error ? postDeductionError.message : "Unknown error";
      await updateJobStatus(supabase, jobId, { status: "failed", error_message: errorMsg });
      return new Response(
        JSON.stringify({ error: errorMsg }),
        { status: 500, headers: { ...headers, "Content-Type": "application/json" } }
      );
    }
  } catch (error) {
    console.error("Edge function error:", error);
    return new Response(
      JSON.stringify({ error: error instanceof Error ? error.message : "Unknown error" }),
      { status: 500, headers: { ...headers, "Content-Type": "application/json" } }
    );
  }
});
