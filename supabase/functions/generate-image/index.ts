import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const KIE_API_KEY = Deno.env.get("KIE_API_KEY")!;
const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY")!;

const KIE_API_BASE = "https://api.kie.ai";
const GEMINI_API_BASE = "https://generativelanguage.googleapis.com/v1beta";

const KIE_MODELS = [
  "google/imagen4",
  "google/imagen4-fast",
  "google/imagen4-ultra",
  "nano-banana-pro",
  "google/nano-banana-edit",
] as const;

const GEMINI_MODELS = [
  "gemini-3-pro-image-preview",
  "gemini-2.5-flash-image",
] as const;

interface GenerationRequest {
  jobId: string;
  userId: string;
  prompt: string;
  model?: string;
  aspectRatio?: string;
  imageCount?: number;
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

async function createKieTask(
  prompt: string,
  model: string,
  aspectRatio: string,
  imageInputs?: string[]
): Promise<{ taskId: string } | { error: string }> {
  const input: Record<string, unknown> = {
    prompt,
    aspect_ratio: aspectRatio || "1:1",
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
  index: number
): Promise<string> {
  const fileName = index === 0 ? `${jobId}.png` : `${jobId}_${index}.png`;
  const storagePath = `${userId}/${fileName}`;

  const { error } = await supabase.storage
    .from("generated-images")
    .upload(storagePath, imageData, {
      contentType: "image/png",
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
  imageUrls: string[]
): Promise<string[]> {
  const storagePaths: string[] = [];

  for (let i = 0; i < imageUrls.length; i++) {
    const imageData = await downloadImage(imageUrls[i]);
    const storagePath = await uploadToStorage(supabase, userId, jobId, imageData, i);
    storagePaths.push(storagePath);
  }

  return storagePaths;
}

async function mirrorBase64ToStorage(
  supabase: ReturnType<typeof getSupabaseClient>,
  userId: string,
  jobId: string,
  base64Images: string[]
): Promise<string[]> {
  const storagePaths: string[] = [];

  for (let i = 0; i < base64Images.length; i++) {
    const binaryString = atob(base64Images[i]);
    const bytes = new Uint8Array(binaryString.length);
    for (let j = 0; j < binaryString.length; j++) {
      bytes[j] = binaryString.charCodeAt(j);
    }

    const storagePath = await uploadToStorage(supabase, userId, jobId, bytes, i);
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
  const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  };

  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const body: GenerationRequest = await req.json();
    const {
      jobId,
      userId,
      prompt,
      model = "nano-banana-pro",
      aspectRatio = "1:1",
      imageInputs,
    } = body;

    if (!jobId || !userId || !prompt) {
      return new Response(
        JSON.stringify({ error: "Missing required fields: jobId, userId, prompt" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabase = getSupabaseClient();
    const provider = getProvider(model);

    await updateJobStatus(supabase, jobId, { status: "processing", provider_task_id: null });

    let storagePaths: string[] = [];

    if (provider === "kie") {
      console.log(`[${jobId}] Kie.ai generation: ${model}`);

      const createResult = await createKieTask(prompt, model, aspectRatio, imageInputs);

      if ("error" in createResult) {
        await updateJobStatus(supabase, jobId, { status: "failed", error_message: createResult.error });
        return new Response(JSON.stringify({ error: createResult.error }), {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      await updateJobStatus(supabase, jobId, { provider_task_id: createResult.taskId });
      console.log(`[${jobId}] Kie task: ${createResult.taskId}`);

      const pollResult = await pollKieTask(createResult.taskId);

      if ("error" in pollResult) {
        await updateJobStatus(supabase, jobId, { status: "failed", error_message: pollResult.error });
        return new Response(JSON.stringify({ error: pollResult.error }), {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      console.log(`[${jobId}] Mirroring ${pollResult.images.length} images`);
      storagePaths = await mirrorUrlsToStorage(supabase, userId, jobId, pollResult.images);

    } else {
      console.log(`[${jobId}] Gemini generation: ${model}`);

      const geminiResult = await generateViaGemini(prompt, model, aspectRatio);

      if ("error" in geminiResult) {
        await updateJobStatus(supabase, jobId, { status: "failed", error_message: geminiResult.error });
        return new Response(JSON.stringify({ error: geminiResult.error }), {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        });
      }

      console.log(`[${jobId}] Mirroring ${geminiResult.base64Images.length} images`);
      storagePaths = await mirrorBase64ToStorage(supabase, userId, jobId, geminiResult.base64Images);
    }

    await updateJobStatus(supabase, jobId, {
      status: "completed",
      result_urls: storagePaths,
      completed_at: new Date().toISOString(),
    });

    console.log(`[${jobId}] Completed: ${storagePaths.length} images`);

    return new Response(
      JSON.stringify({ success: true, jobId, storagePaths }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("Edge function error:", error);
    return new Response(
      JSON.stringify({ error: error instanceof Error ? error.message : "Unknown error" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
