# Research: Supabase Edge Functions & Background Tasks

## Summary

Using Supabase Edge Functions for AI image generation with background processing.

## Edge Functions Overview

- Deno-based serverless functions
- Deploy with `supabase functions deploy`
- Auto-scale, cold starts ~100ms
- Access Supabase client with service role

## Background Tasks

### Purpose
- Respond immediately to user while processing continues
- Long-running operations without blocking response
- AI image generation takes 5-30 seconds

### API

```typescript
// Mark task to continue after response
EdgeRuntime.waitUntil(asyncLongRunningTask());

// Inside request handler - won't block
Deno.serve(async (req) => {
  EdgeRuntime.waitUntil(generateImages(jobId));
  return new Response(JSON.stringify({ job_id: jobId }));
});
```

### Lifecycle Hooks

```typescript
// Notified before shutdown
addEventListener('beforeunload', (ev) => {
  console.log('Shutdown reason:', ev.detail?.reason);
  // Save state or log progress
});
```

### Local Testing

```toml
# supabase/config.toml
[edge_runtime]
policy = "per_worker"  # Prevents auto-termination
```

## Image Generation Flow

```
1. Client → POST /generate-image
2. Edge Function:
   a. Validate auth & credits
   b. Create job record (status: pending)
   c. Return job_id (< 1 second)
   d. EdgeRuntime.waitUntil(processJob())
3. Background:
   a. Update job status: generating
   b. Call Gemini Imagen 4 API
   c. Upload images to Storage
   d. Deduct credits (if not premium)
   e. Update job status: completed
4. Client subscribes to Realtime on job ID
5. Receives status updates automatically
```

## Gemini Imagen 4 API

### Endpoint
```
POST https://generativelanguage.googleapis.com/v1beta/models/imagen-4.0-generate-001:predict
```

### Request
```json
{
  "instances": [{ "prompt": "Robot holding skateboard" }],
  "parameters": {
    "sampleCount": 4,
    "aspectRatio": "16:9"
  }
}
```

### Response
```json
{
  "predictions": [
    { "bytesBase64Encoded": "..." },
    { "bytesBase64Encoded": "..." }
  ]
}
```

### Parameters
| Param | Values | Default |
|-------|--------|---------|
| sampleCount | 1-4 | 4 |
| aspectRatio | 1:1, 3:4, 4:3, 9:16, 16:9 | 1:1 |
| imageSize | 1K, 2K (Ultra only) | 1K |
| personGeneration | dont_allow, allow_adult, allow_all | allow_adult |

## Job Status Table

```sql
CREATE TABLE generation_jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  template_id UUID REFERENCES templates(id),
  prompt TEXT NOT NULL,
  status TEXT DEFAULT 'pending', -- pending, generating, completed, failed
  result_urls TEXT[],
  error_message TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  completed_at TIMESTAMPTZ
);

-- Enable Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE generation_jobs;
```

## Realtime Subscription

```dart
final stream = supabase
    .from('generation_jobs')
    .stream(primaryKey: ['id'])
    .eq('id', jobId);

stream.listen((data) {
  final job = GenerationJobModel.fromJson(data.first);
  // Update UI
});
```

## Error Handling

```typescript
async function processJob(jobId: string) {
  try {
    // ... generation logic
  } catch (error) {
    await supabase
      .from('generation_jobs')
      .update({
        status: 'failed',
        error_message: error.message,
      })
      .eq('id', jobId);
  }
}
```

## References

- https://supabase.com/docs/guides/functions/background-tasks
- https://ai.google.dev/gemini-api/docs/imagen
- https://supabase.com/docs/guides/realtime
