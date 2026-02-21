# Feature: Image Input Flow

> **Status:** NOT STARTED
> **Priority:** P0 — All 25 templates require image input but app has no image upload capability
> **Created:** 2026-02-21
> **Related:** `ai-models-reference.md`, Edge Function `generate-image/index.ts`

---

## Problem

All 25 templates in Artio require user-uploaded images (defined via `input_fields` in DB), but the Flutter app currently:

1. **Has no image picker** — no `image_picker` or equivalent dependency
2. **Has no upload logic** — `generation_repository.dart` doesn't upload images to Storage
3. **Doesn't send `imageInputs`** — Edge Function call body is missing `imageInputs` array
4. **Renders image fields as text** — `template_detail_screen.dart` only handles text `inputFields`

The Edge Function already fully supports this flow (tested 2026-02-21):
- Resolves Supabase Storage paths → signed URLs
- Sends correct field names to KIE API per model (`input_urls`, `image_urls`, `image_input`)

---

## Current Architecture

### What EXISTS (✅)

```
Template DB Schema:
  input_fields: jsonb = [
    { "name": "image", "type": "image", "label": "Upload your photo", "required": true }
  ]

Edge Function (index.ts):
  - Accepts `imageInputs: string[]` in request body
  - resolveImageUrls() converts Storage paths → signed URLs (60min expiry)
  - buildKieInput() maps to correct API field per model family

Supabase Storage:
  - Bucket: `generated-images`
  - RLS: authenticated users can upload to `{userId}/` prefix
  - Output stored at: `{userId}/{jobId}.jpg`
```

### What's MISSING (❌)

```
Flutter App:
  ❌ image_picker package dependency
  ❌ Image selection widget (supports 1-3 images per template)
  ❌ Image upload service (local file → Storage)
  ❌ imageInputs parameter in generation_repository.dart
  ❌ Image state management in generation_view_model.dart
  ❌ Upload progress indicator
  ❌ Image preview/remove UI
```

---

## Template Image Requirements

All 25 templates require at least 1 image. Current DB schema:

```json
// Example: Sketch to Photo (1 image)
{
  "input_fields": [
    { "name": "image", "type": "image", "label": "Upload your photo", "required": true }
  ]
}
```

Templates may need 1-3 images. The `input_fields` array defines how many.

### Categories & Image Needs

| Category | Templates | Typical Image Count |
|----------|-----------|:---:|
| Portrait & Face Effects | 7 (Bangs, Beard, Skin Color...) | 1 |
| Removal & Editing | 4 (Object Remover, Text Remover...) | 1 |
| Art Style Transfer | 6 (Sketch to Photo, Ghibli, Pixel...) | 1 |
| Photo Enhancement | 4 (Snow Filter, B&W, Fisheye...) | 1 |
| Creative & Fun | 4 (Mockup, Costume, Pet Portrait...) | 1 |

> **Note:** Some future templates (e.g. "Hug My Younger Self") may need 2 images.
> Design the system to support N images from the start.

---

## Proposed Architecture

### Storage Path Convention

```
generated-images/
  {userId}/
    inputs/           ← user-uploaded source images
      {uuid}.jpg
      {uuid}.jpg
    {jobId}.jpg       ← generated output (already exists)
```

### Data Flow

```
1. User opens template → sees image slots based on input_fields
2. User taps slot → image_picker opens (camera/gallery)
3. User selects image → preview shown, compress if needed
4. User taps "Generate" →
   a. Upload images to Storage: {userId}/inputs/{uuid}.jpg
   b. Create job row in generation_jobs
   c. Call Edge Function with:
      {
        "jobId": "...",
        "prompt": "...",
        "model": "...",
        "aspectRatio": "1:1",
        "imageInputs": ["{userId}/inputs/{uuid1}.jpg", "{userId}/inputs/{uuid2}.jpg"]
      }
   d. Edge Function resolves paths → signed URLs → KIE API
5. Poll/watch job status → show result
```

### Files to Create/Modify

| File | Action | Description |
|------|--------|-------------|
| `pubspec.yaml` | MODIFY | Add `image_picker` dependency |
| `lib/core/services/image_upload_service.dart` | CREATE | Upload local files to Storage, return paths |
| `lib/shared/widgets/image_input_widget.dart` | CREATE | Reusable widget: pick, preview, remove images |
| `lib/features/template_engine/presentation/screens/template_detail_screen.dart` | MODIFY | Add image input slots based on `inputFields` |
| `lib/features/template_engine/presentation/view_models/generation_view_model.dart` | MODIFY | Add `imageFiles` state, handle upload before generate |
| `lib/features/template_engine/data/repositories/generation_repository.dart` | MODIFY | Add `imageInputs` param, upload before Edge Function call |

### Key Decisions

1. **Compress before upload?** — Yes, max 2MB per image to reduce storage costs and upload time
2. **Image format** — JPEG (lossy OK for AI input), quality 85%
3. **Max images per template** — Read from `input_fields.length` where `type == "image"`
4. **Upload timing** — Upload at generation time (not on pick), to avoid orphan uploads
5. **Cleanup** — Input images can be auto-deleted after 24h (KIE only needs signed URL temporarily)

---

## Edge Function — Already Working ✅

Tested flow (2026-02-21):

```bash
# 1. Login
POST /auth/v1/token?grant_type=password → access_token

# 2. Upload image to Storage
POST /storage/v1/object/generated-images/{userId}/inputs/photo.jpg

# 3. Create job in DB
INSERT INTO generation_jobs (id, user_id, template_id, prompt, status, ...)

# 4. Call Edge Function
POST /functions/v1/generate-image
{
  "jobId": "<uuid>",
  "prompt": "Convert this sketch/drawing into a realistic photographic image",
  "model": "gpt-image/1.5-image-to-image",
  "aspectRatio": "1:1",
  "imageInputs": ["{userId}/inputs/photo.jpg"]
}

# Result: {"success": true, "storagePaths": ["{userId}/{jobId}.jpg"]}
```

### Image Input Field Names by Model

| Model Family | Field Name | Used When |
|-------------|------------|-----------|
| `flux-2/*-image-to-image` | `input_urls` | model includes "image-to-image" |
| `gpt-image/*-image-to-image` | `input_urls` | model includes "image-to-image" |
| `seedream/*-edit` | `image_urls` | model includes "edit" |
| `google/nano-banana-edit` | `image_urls` | always (image-editing model) |
| `nano-banana-pro` | `image_input` | when imageInputs provided |
| `gemini-*` | `image_input` | when imageInputs provided |

---

## JWT Note

Edge Function deployed with `verify_jwt = false` in `config.toml`.
Gateway-level HS256 verification rejects GoTrue v2 ES256 tokens.
Auth handled internally by function via `supabase.auth.getUser(token)`.

---

## Model Selection for Image Templates

Not all models support image input. Template UI should filter models:

### Image-to-Image Models (supports `imageInputs`)

| Model ID | Display Name | Premium | Credits |
|----------|-------------|:---:|:---:|
| `google/nano-banana-edit` | Nano Banana Edit | ❌ | 8 |
| `nano-banana-pro` | Nano Banana Pro | ❌ | 36 |
| `flux-2/flex-image-to-image` | Flux-2 Flex Edit | ❌ | 28 |
| `flux-2/pro-image-to-image` | Flux-2 Pro Edit | ✅ | 10 |
| `gpt-image/1.5-image-to-image` | GPT Image 1.5 Edit | ✅ | 8 |
| `seedream/4.5-edit` | Seedream 4.5 Edit | ❌ | 10 |

### Text-to-Image Models (NO `imageInputs`)

These should NOT be available for templates requiring images:
`google/imagen4`, `google/imagen4-fast`, `google/imagen4-ultra`,
`flux-2/flex-text-to-image`, `flux-2/pro-text-to-image`,
`gpt-image/1.5-text-to-image`, `seedream/4.5-text-to-image`,
`gemini-3-pro-image-preview`, `gemini-2.5-flash-image`

> **Exception:** `nano-banana-pro` is text-to-image but optionally accepts `image_input`.
> `gemini-*` models also accept optional `image_input`.

---

## Acceptance Criteria

- [ ] User can select 1-3 images from device gallery/camera
- [ ] Image preview shown with remove button
- [ ] Images compressed to max 2MB before upload
- [ ] Upload progress indicator shown during generation
- [ ] `imageInputs` correctly sent to Edge Function
- [ ] Model selector filtered to image-compatible models only
- [ ] Works on both iOS and Android
- [ ] Error handling: file too large, unsupported format, upload failure
- [ ] Generated image displayed in result screen
- [ ] Job saved with correct status in `generation_jobs` table
