import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import { encodeBase64 } from "https://deno.land/std/encoding/base64.ts";
import { corsHeaders, handleCorsIfPreflight } from "../_shared/cors.ts";
import { isPremiumModel, getModelCreditCost } from "../_shared/model_config.ts";
import { checkAndDeductCredits, refundCreditsOnFailure } from "../_shared/credit_logic.ts";

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

// Fallback provider — Google native Gemini models (use :generateContent)
const GEMINI_MODELS = [
  "gemini-3-pro-image-preview",
  "gemini-2.5-flash-image",
] as const;

// Google Imagen 4.0 native models (use :predict endpoint)
const IMAGEN_MODELS = [
  "imagen-4.0-generate-001",
  "imagen-4.0-ultra-generate-001",
  "imagen-4.0-fast-generate-001",
] as const;

// MODEL_CREDIT_COSTS, PREMIUM_MODELS, isPremiumModel, getModelCreditCost
// imported from ../_shared/model_config.ts

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

interface KieRecordInfoResponse {
  code: number;
  message: string;
  data?: {
    taskId: string;
    model: string;
    state: "pending" | "processing" | "success" | "failed";
    resultJson?: string; // JSON string like {"resultUrls":["..."]}
    failCode?: string;
    failMsg?: string;
    completeTime?: number;
    createTime?: number;
  };
}

function getSupabaseClient() {
  return createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
    auth: { persistSession: false },
  });
}

function getProvider(model: string): "kie" | "gemini" | "imagen" {
  if (KIE_MODELS.includes(model as typeof KIE_MODELS[number])) return "kie";
  if (GEMINI_MODELS.includes(model as typeof GEMINI_MODELS[number])) return "gemini";
  if (IMAGEN_MODELS.includes(model as typeof IMAGEN_MODELS[number])) return "imagen";
  return "kie";
}


const STORAGE_BUCKET = "generated-images";
const SIGNED_URL_EXPIRY_SECONDS = 3600; // 1 hour

/**
 * Resolve image inputs to publicly accessible URLs.
 * - Supabase storage paths (no protocol) → signed URLs
 * - Already full URLs (http/https) → passed through unchanged
 */
async function resolveImageUrls(
  supabase: ReturnType<typeof createClient>,
  imageInputs: string[]
): Promise<string[]> {
  const resolved: string[] = [];
  for (const input of imageInputs) {
    if (input.startsWith("http://") || input.startsWith("https://")) {
      resolved.push(input);
    } else {
      // Treat as Supabase storage path — generate signed URL
      const { data, error } = await supabase.storage
        .from(STORAGE_BUCKET)
        .createSignedUrl(input, SIGNED_URL_EXPIRY_SECONDS);
      if (error || !data?.signedUrl) {
        console.error(`[storage] Failed to sign URL for "${input}":`, error?.message);
        // Fallback: construct public URL (may fail if bucket is private)
        resolved.push(`${SUPABASE_URL}/storage/v1/object/public/${STORAGE_BUCKET}/${input}`);
      } else {
        resolved.push(data.signedUrl);
      }
    }
  }
  return resolved;
}

/**
 * Build model-specific input payload per KIE API OpenAPI specs.
 * Each model family has different field names and supported parameters.
 */
function buildKieInput(
  prompt: string,
  model: string,
  aspectRatio: string,
  imageInputs?: string[]
): Record<string, unknown> {
  const ratio = aspectRatio || "1:1";

  // Google Imagen models: aspect_ratio, negative_prompt, seed
  if (model.startsWith("google/imagen4")) {
    return { prompt, aspect_ratio: ratio };
  }

  // Nano Banana Edit (image-editing): image_size, image_urls (required), output_format
  if (model === "google/nano-banana-edit") {
    return {
      prompt,
      image_urls: imageInputs || [],
      image_size: ratio,
      output_format: "png",
    };
  }

  // Nano Banana Pro (text-to-image + optional image_input): aspect_ratio, resolution, output_format
  if (model === "nano-banana-pro") {
    const input: Record<string, unknown> = {
      prompt,
      aspect_ratio: ratio,
      resolution: "1K",
      output_format: "png",
    };
    if (imageInputs?.length) input.image_input = imageInputs;
    return input;
  }

  // Flux-2 models: aspect_ratio, resolution, input_urls (image-to-image)
  if (model.startsWith("flux-2/")) {
    const input: Record<string, unknown> = {
      prompt,
      aspect_ratio: ratio,
      resolution: "1K",
    };
    if (imageInputs?.length && model.includes("image-to-image")) {
      input.input_urls = imageInputs;
    }
    return input;
  }

  // GPT Image models: aspect_ratio, quality, input_urls (image-to-image)
  // GPT Image only supports 1:1, 2:3, 3:2 — auto-map universal ratios
  if (model.startsWith("gpt-image/")) {
    const gptRatioMap: Record<string, string> = {
      "3:4": "2:3",
      "9:16": "2:3",
      "4:3": "3:2",
      "16:9": "3:2",
    };
    const mappedRatio = gptRatioMap[ratio] || ratio;
    const input: Record<string, unknown> = {
      prompt,
      aspect_ratio: mappedRatio,
      quality: "medium",
    };
    if (imageInputs?.length && model.includes("image-to-image")) {
      input.input_urls = imageInputs;
    }
    return input;
  }

  // Seedream models: aspect_ratio, quality, image_urls (edit)
  if (model.startsWith("seedream/")) {
    const input: Record<string, unknown> = {
      prompt,
      aspect_ratio: ratio,
      quality: "basic",
    };
    if (imageInputs?.length && model.includes("edit")) {
      input.image_urls = imageInputs;
    }
    return input;
  }

  // Fallback: generic payload
  return { prompt, aspect_ratio: ratio };
}

async function createKieTask(
  prompt: string,
  model: string,
  aspectRatio: string,
  _imageCount: number,
  imageInputs?: string[]
): Promise<{ taskId: string } | { error: string }> {
  const input = buildKieInput(prompt, model, aspectRatio, imageInputs);

  console.log(`[KIE] Creating task: model=${model}, input keys=${Object.keys(input).join(",")}`);

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
    console.error(`[KIE] Create task failed:`, JSON.stringify(result));
    return { error: result.msg || "Failed to create Kie task" };
  }

  return { taskId: result.data.taskId };
}

async function pollKieTask(
  taskId: string,
  maxAttempts = 60,
  intervalMs = 2000
): Promise<{ images: string[] } | { error: string }> {
  const startTime = Date.now();
  const timeoutMs = 120 * 1000; // 120 seconds max

  for (let attempt = 0; attempt < maxAttempts; attempt++) {
    if (Date.now() - startTime >= timeoutMs) {
      console.warn(`[${taskId}] Polling timed out after 120s`);
      return { error: "Generation timed out after 120 seconds" };
    }

    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 10000); // 10s timeout per req

      const response = await fetch(
        `${KIE_API_BASE}/api/v1/jobs/recordInfo?taskId=${taskId}`,
        {
          method: "GET",
          headers: { Authorization: `Bearer ${KIE_API_KEY}` },
          signal: controller.signal,
        }
      );

      clearTimeout(timeoutId);

      const result: KieRecordInfoResponse = await response.json();

      if (result.code !== 200) {
        console.warn(`[${taskId}] KIE poll non-200 (attempt ${attempt}):`, JSON.stringify(result));
      } else {
        const state = result.data?.state;

        if (state === "success") {
          const images: string[] = [];
          if (result.data?.resultJson) {
            try {
              const parsed = JSON.parse(result.data.resultJson);
              if (parsed.resultUrls?.length) {
                images.push(...parsed.resultUrls);
              }
            } catch (e) {
              console.error(`[${taskId}] Failed to parse resultJson:`, e);
            }
          }
          if (images.length === 0) {
            return { error: "Generation completed but no images returned" };
          }
          return { images };
        }

        if (state === "failed") {
          return { error: result.data?.failMsg || "Generation failed" };
        }
      }
    } catch (err) {
      console.error(`[${taskId}] Poll loop error:`, err);
      // Fall through to exponential backoff or next attempt
    }

    await new Promise((resolve) => setTimeout(resolve, intervalMs));
  }

  return { error: "Generation timed out after 120 seconds" };
}

async function downloadImageAsBase64(
  url: string
): Promise<{ mimeType: string; data: string }> {
  const response = await fetch(url);
  if (!response.ok) throw new Error(`Failed to download image: ${response.status}`);
  const contentType = response.headers.get("content-type") || "image/jpeg";
  const buffer = new Uint8Array(await response.arrayBuffer());
  const base64 = encodeBase64(buffer);
  return { mimeType: contentType, data: base64 };
}

async function generateViaGemini(
  prompt: string,
  model: string,
  aspectRatio: string,
  imageUrls?: string[]
): Promise<{ base64Images: string[] } | { error: string }> {
  // Build parts: images first (if any), then text prompt
  const parts: Array<Record<string, unknown>> = [];

  if (imageUrls?.length) {
    const imageParts = await Promise.all(
      imageUrls.map(async (url) => {
        const { mimeType, data } = await downloadImageAsBase64(url);
        return { inlineData: { mimeType, data } };
      })
    );
    parts.push(...imageParts);
  }

  parts.push({ text: prompt });

  const response = await fetch(
    `${GEMINI_API_BASE}/models/${model}:generateContent`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-goog-api-key": GEMINI_API_KEY,
      },
      body: JSON.stringify({
        contents: [{ parts }],
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

async function generateViaImagen(
  prompt: string,
  model: string,
  aspectRatio: string,
  imageCount: number
): Promise<{ base64Images: string[] } | { error: string }> {
  const response = await fetch(
    `${GEMINI_API_BASE}/models/${model}:predict`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-goog-api-key": GEMINI_API_KEY,
      },
      body: JSON.stringify({
        instances: [{ prompt }],
        parameters: {
          sampleCount: imageCount,
          aspectRatio: aspectRatio || "1:1",
        },
      }),
    }
  );

  if (!response.ok) {
    const errorText = await response.text();
    return { error: `Imagen API error: ${response.status} - ${errorText}` };
  }

  const result = await response.json();
  const base64Images: string[] = [];

  for (const prediction of result.predictions || []) {
    if (prediction.bytesBase64Encoded) {
      base64Images.push(prediction.bytesBase64Encoded);
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

async function cleanupStorageFiles(
  supabase: ReturnType<typeof getSupabaseClient>,
  paths: string[]
): Promise<void> {
  const { error } = await supabase.storage
    .from("generated-images")
    .remove(paths);

  if (error) {
    console.error(`Failed to cleanup orphaned files: ${error.message}`, paths);
    // Non-fatal: log but don't throw — the original error is more important
  }
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
    try {
      const imageData = await downloadImage(imageUrls[i]);
      const storagePath = await uploadToStorage(supabase, userId, jobId, imageData, i, outputFormat);
      storagePaths.push(storagePath);
    } catch (error) {
      if (storagePaths.length > 0) {
        console.warn(`[${jobId}] Upload failed at index ${i}, cleaning up ${storagePaths.length} orphaned files`);
        await cleanupStorageFiles(supabase, storagePaths);
      }
      throw error;
    }
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
    try {
      const binaryString = atob(base64Images[i]);
      const bytes = new Uint8Array(binaryString.length);
      for (let j = 0; j < binaryString.length; j++) {
        bytes[j] = binaryString.charCodeAt(j);
      }

      const storagePath = await uploadToStorage(supabase, userId, jobId, bytes, i, outputFormat);
      storagePaths.push(storagePath);
    } catch (error) {
      if (storagePaths.length > 0) {
        console.warn(`[${jobId}] Base64 upload failed at index ${i}, cleaning up ${storagePaths.length} orphaned files`);
        await cleanupStorageFiles(supabase, storagePaths);
      }
      throw error;
    }
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

/**
 * Refunds credits and builds an error message that includes a manual
 * intervention marker when the refund itself fails.
 */
async function refundAndBuildErrorMsg(
  supabase: ReturnType<typeof getSupabaseClient>,
  userId: string,
  creditCost: number,
  jobId: string,
  originalError: string
): Promise<string> {
  const refund = await refundCreditsOnFailure(supabase, userId, creditCost, jobId);
  return refund.success
    ? originalError
    : `${originalError} [refund_pending_manual attempts=${refund.attempts}]`;
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

    // Rate limiting: 5 requests per 60 seconds per user
    const { data: rateLimit, error: rateLimitError } = await supabase.rpc("check_rate_limit", {
      p_user_id: userId,
      p_max_requests: 5,
      p_window_seconds: 60,
    });

    if (rateLimitError) {
      console.error(`Rate limit check failed for ${userId}:`, rateLimitError);
      return new Response(
        JSON.stringify({ error: "Rate limit service unavailable. Please try again." }),
        { status: 503, headers: { ...headers, "Content-Type": "application/json" } }
      );
    } else if (rateLimit?.allowed === false) {
      console.warn(`[rate-limit] User ${userId} exceeded limit. Retry after ${rateLimit.retry_after}s`);
      return new Response(
        JSON.stringify({ error: "Rate limit exceeded", retry_after: rateLimit.retry_after }),
        { status: 429, headers: { ...headers, "Content-Type": "application/json" } }
      );
    }

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

    // Validate imageCount bounds (1-4)
    if (!Number.isInteger(imageCount) || imageCount < 1 || imageCount > 4) {
      return new Response(
        JSON.stringify({ error: "imageCount must be an integer between 1 and 4" }),
        { status: 400, headers: { ...headers, "Content-Type": "application/json" } }
      );
    }

    // Verify job ownership and deduplication
    const { data: job, error: jobError } = await supabase
      .from("generation_jobs")
      .select("user_id, status")
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

    if (job.status !== "pending") {
      console.warn(`[${jobId}] Duplicate generation request ignored (status: ${job.status})`);
      return new Response(
        JSON.stringify({ error: `Job has already been processed or is currently running (status: ${job.status})` }),
        { status: 409, headers: { ...headers, "Content-Type": "application/json" } }
      );
    }
    // Resolve credit cost from server-side map
    const creditCost = getModelCreditCost(model);
    if (creditCost === undefined) {
      return new Response(
        JSON.stringify({ error: `Unknown model: ${model}` }),
        { status: 400, headers: { ...headers, "Content-Type": "application/json" } }
      );
    }

    // Premium model enforcement — check BEFORE credit deduction
    if (isPremiumModel(model)) {
      const { data: profile, error: profileError } = await supabase
        .from('profiles')
        .select('is_premium')
        .eq('id', userId)
        .single();

      if (profileError || !profile?.is_premium) {
        return new Response(
          JSON.stringify({ error: 'Premium subscription required for this model', model, premiumRequired: true }),
          { status: 403, headers: { ...headers, 'Content-Type': 'application/json' } }
        );
      }
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

        // Resolve Supabase storage paths to signed URLs for KIE access
        const resolvedImages = imageInputs?.length
          ? await resolveImageUrls(supabase, imageInputs)
          : undefined;

        const createResult = await createKieTask(prompt, model, aspectRatio, imageCount, resolvedImages);

        if ("error" in createResult) {
          const errorMsg = await refundAndBuildErrorMsg(supabase, userId, creditCost, jobId, createResult.error);
          await updateJobStatus(supabase, jobId, { status: "failed", error_message: errorMsg });
          return new Response(JSON.stringify({ error: createResult.error }), {
            status: 500,
            headers: { ...headers, "Content-Type": "application/json" },
          });
        }

        await updateJobStatus(supabase, jobId, { provider_task_id: createResult.taskId });
        console.log(`[${jobId}] Kie task: ${createResult.taskId}`);

        const pollResult = await pollKieTask(createResult.taskId);

        if ("error" in pollResult) {
          const errorMsg = await refundAndBuildErrorMsg(supabase, userId, creditCost, jobId, pollResult.error);
          await updateJobStatus(supabase, jobId, { status: "failed", error_message: errorMsg });
          return new Response(JSON.stringify({ error: pollResult.error }), {
            status: 500,
            headers: { ...headers, "Content-Type": "application/json" },
          });
        }

        console.log(`[${jobId}] Mirroring ${pollResult.images.length} images`);
        storagePaths = await mirrorUrlsToStorage(supabase, userId, jobId, pollResult.images, outputFormat);

      } else if (provider === "imagen") {
        console.log(`[${jobId}] Imagen generation: ${model}, count: ${imageCount}, format: ${outputFormat}`);

        const imagenResult = await generateViaImagen(prompt, model, aspectRatio, imageCount);

        if ("error" in imagenResult) {
          const errorMsg = await refundAndBuildErrorMsg(supabase, userId, creditCost, jobId, imagenResult.error);
          await updateJobStatus(supabase, jobId, { status: "failed", error_message: errorMsg });
          return new Response(JSON.stringify({ error: imagenResult.error }), {
            status: 500,
            headers: { ...headers, "Content-Type": "application/json" },
          });
        }

        console.log(`[${jobId}] Mirroring ${imagenResult.base64Images.length} images`);
        storagePaths = await mirrorBase64ToStorage(supabase, userId, jobId, imagenResult.base64Images, outputFormat);

      } else {
        console.log(`[${jobId}] Gemini generation: ${model}, format: ${outputFormat}`);

        // Resolve Supabase storage paths to signed URLs for Gemini access
        const resolvedGeminiImages = imageInputs?.length
          ? await resolveImageUrls(supabase, imageInputs)
          : undefined;

        const geminiResult = await generateViaGemini(prompt, model, aspectRatio, resolvedGeminiImages);

        if ("error" in geminiResult) {
          const errorMsg = await refundAndBuildErrorMsg(supabase, userId, creditCost, jobId, geminiResult.error);
          await updateJobStatus(supabase, jobId, { status: "failed", error_message: errorMsg });
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
      const rawMsg = postDeductionError instanceof Error ? postDeductionError.message : "Unknown error";
      const errorMsg = await refundAndBuildErrorMsg(supabase, userId, creditCost, jobId, rawMsg);
      await updateJobStatus(supabase, jobId, { status: "failed", error_message: errorMsg });
      return new Response(
        JSON.stringify({ error: rawMsg }),
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
