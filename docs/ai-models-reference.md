# AI Models Reference

> Last updated: 2026-02-21
>
> ⚠️ **SYNC**: Model IDs, credit costs, and premium flags must match across:
> - `lib/core/constants/ai_models.dart` (Flutter client)
> - `supabase/functions/_shared/model_config.ts` (Edge Function server)
> - `supabase/functions/generate-image/index.ts` (KIE_MODELS list + buildKieInput)

---

## Providers

| Provider | Endpoint | Polling |
|----------|----------|---------|
| **KIE** (Market API) | `POST https://api.kie.ai/api/v1/jobs/createTask` | `GET https://api.kie.ai/api/v1/jobs/recordInfo?taskId=...` |
| **Gemini** (Google native) | Direct via `@google/generative-ai` SDK | Synchronous (no polling) |

---

## Text-to-Image Models (Tạo ảnh từ prompt)

| Model ID | Display Name | Provider | Premium | Credits | Aspect Ratios | Local Docs | Online Docs |
|----------|-------------|----------|---------|---------|---------------|------------|-------------|
| `google/imagen4` | Imagen 4 | KIE | ❌ | 16 | 1:1, 16:9, 9:16, 3:4, 4:3 | [Local](kie-api/google/imagen4.md) | [KIE](https://docs.kie.ai/market/google/imagen4.md) |
| `google/imagen4-fast` | Imagen 4 Fast | KIE | ❌ | 8 | 1:1, 16:9, 9:16, 3:4, 4:3 | [Local](kie-api/google/imagen4-fast.md) | [KIE](https://docs.kie.ai/market/google/imagen4-fast.md) |
| `google/imagen4-ultra` | Imagen 4 Ultra | KIE | ✅ | 24 | 1:1, 16:9, 9:16, 3:4, 4:3 | [Local](kie-api/google/imagen4-ultra.md) | [KIE](https://docs.kie.ai/market/google/imagen4-ultra.md) |
| `nano-banana-pro` | Nano Banana Pro | KIE | ❌ | 36 | 1:1, 2:3, 3:2, 3:4, 4:3, 4:5, 5:4, 9:16, 16:9, 21:9 | [Local](kie-api/google/nano-banana-pro.md) | [KIE](https://docs.kie.ai/market/google/pro-image-to-image.md) |
| `flux-2/flex-text-to-image` | Flux-2 Flex | KIE | ❌ | 28 | 1:1, 2:3, 3:2, 9:16, 16:9, 3:4, 4:3 | [Local](kie-api/flux2/flux2-flex-text-to-image.md) | [KIE](https://docs.kie.ai/market/flux2/flex-text-to-image.md) |
| `flux-2/pro-text-to-image` | Flux-2 Pro | KIE | ✅ | 10 | 1:1, 2:3, 3:2, 9:16, 16:9, 3:4, 4:3 | [Local](kie-api/flux2/flux2-pro-text-to-image.md) | [KIE](https://docs.kie.ai/market/flux2/pro-text-to-image.md) |
| `gpt-image/1.5-text-to-image` | GPT Image 1.5 | KIE | ✅ | 8 | 1:1, 2:3, 3:2 | [Local](kie-api/gpt-image/gpt-image-1.5-text-to-image.md) | [KIE](https://docs.kie.ai/market/gpt-image/1.5-text-to-image.md) |
| `seedream/4.5-text-to-image` | Seedream 4.5 | KIE | ❌ | 8 | 1:1, 4:3, 3:4, 16:9, 9:16, 2:3, 3:2, 21:9 | [Local](kie-api/seedream/seedream-4.5-text-to-image.md) | [KIE](https://docs.kie.ai/market/seedream/4.5-text-to-image.md) |
| `gemini-3-pro-image-preview` | Gemini 3 Pro Image | Gemini | ✅ | 15 | All standard | [Local](kie-api/google/gemini-3-pro-image-preview.md) | Google native API |
| `gemini-2.5-flash-image` | Gemini 2.5 Flash Image | Gemini | ❌ | 8 | All standard | [Local](kie-api/google/gemini-2.5-flash-image.md) | Google native API |

## Image-to-Image / Editing Models (Tạo ảnh từ template + input image)

| Model ID | Display Name | Provider | Premium | Credits | Type | Image Input Field | Ratio Field | Local Docs | Online Docs |
|----------|-------------|----------|---------|---------|------|-------------------|-------------|------------|-------------|
| `google/nano-banana-edit` | Nano Banana Edit | KIE | ❌ | 8 | image-editing | `image_urls` | `image_size` | [Local](kie-api/google/nano-banana-edit.md) | [KIE](https://docs.kie.ai/market/google/nano-banana-edit.md) |
| `flux-2/flex-image-to-image` | Flux-2 Flex Edit | KIE | ❌ | 28 | image-to-image | `input_urls` | `aspect_ratio` | [Local](kie-api/flux2/flux2-flex-image-to-image.md) | [KIE](https://docs.kie.ai/market/flux2/flex-image-to-image.md) |
| `flux-2/pro-image-to-image` | Flux-2 Pro Edit | KIE | ✅ | 10 | image-to-image | `input_urls` | `aspect_ratio` | [Local](kie-api/flux2/flux2-pro-image-to-image.md) | [KIE](https://docs.kie.ai/market/flux2/pro-image-to-image.md) |
| `gpt-image/1.5-image-to-image` | GPT Image 1.5 Edit | KIE | ✅ | 8 | image-to-image | `input_urls` | `aspect_ratio` | [Local](kie-api/gpt-image/gpt-image-1.5-image-to-image.md) | [KIE](https://docs.kie.ai/market/gpt-image/1.5-image-to-image.md) |
| `seedream/4.5-edit` | Seedream 4.5 Edit | KIE | ❌ | 10 | image-editing | `image_urls` | `aspect_ratio` | [Local](kie-api/seedream/seedream-4.5-edit.md) | [KIE](https://docs.kie.ai/market/seedream/4.5-edit.md) |

> **Note**: `nano-banana-pro` cũng hỗ trợ `image_input` (optional) nên có thể dùng cho cả text-to-image lẫn image-to-image.

---

## KIE API Payload per Model

Tất cả KIE models đều dùng cùng endpoint `POST /api/v1/jobs/createTask` nhưng **payload `input` khác nhau** cho từng family:

### Google Imagen4 (imagen4 / imagen4-fast / imagen4-ultra)

```json
{
  "model": "google/imagen4",
  "input": {
    "prompt": "...",
    "aspect_ratio": "1:1",
    "negative_prompt": "",
    "seed": ""
  }
}
```

- **Aspect ratios**: Chỉ 5: `1:1`, `16:9`, `9:16`, `3:4`, `4:3`
- **Không hỗ trợ**: `num_images`, `image_input`

### Nano Banana Edit (google/nano-banana-edit)

```json
{
  "model": "google/nano-banana-edit",
  "input": {
    "prompt": "...",
    "image_urls": ["https://..."],
    "image_size": "1:1",
    "output_format": "png"
  }
}
```

- ⚠️ Dùng `image_size` (KHÔNG phải `aspect_ratio`)
- ⚠️ Dùng `image_urls` (KHÔNG phải `image_input`) — **required**
- Tương đương: `gemini-2.5-flash-image` (editing level)

### Nano Banana Pro (nano-banana-pro)

```json
{
  "model": "nano-banana-pro",
  "input": {
    "prompt": "...",
    "aspect_ratio": "1:1",
    "resolution": "1K",
    "output_format": "png",
    "image_input": []
  }
}
```

- `image_input` là optional (hỗ trợ cả text-to-image lẫn image-to-image)
- `resolution`: `1K`, `2K`, `4K`
- Tương đương: `gemini-3-pro-image-preview` (generation level)

### Flux-2 (flex-text-to-image / flex-image-to-image / pro-*)

```json
{
  "model": "flux-2/flex-text-to-image",
  "input": {
    "prompt": "...",
    "aspect_ratio": "1:1",
    "resolution": "1K"
  }
}
```

- `resolution`: `1K`, `2K`
- Image-to-image variants accept `input_urls` (1-8 images)

### GPT Image 1.5 (1.5-text-to-image / 1.5-image-to-image)

```json
{
  "model": "gpt-image/1.5-text-to-image",
  "input": {
    "prompt": "...",
    "aspect_ratio": "1:1",
    "quality": "medium"
  }
}
```

- **Aspect ratios**: Chỉ 3: `1:1`, `2:3`, `3:2`
- `quality`: `medium` (default), `high` (slower, more detailed)
- Image-to-image variant accepts `input_urls` (up to 16 images)

### Seedream 4.5 (4.5-text-to-image / 4.5-edit)

```json
{
  "model": "seedream/4.5-text-to-image",
  "input": {
    "prompt": "...",
    "aspect_ratio": "1:1",
    "quality": "basic"
  }
}
```

- `quality`: `basic` (2K), `high` (4K)
- **Aspect ratios**: `1:1`, `4:3`, `3:4`, `16:9`, `9:16`, `2:3`, `3:2`, `21:9`
- Edit variant accepts `image_urls` (up to 14 images)

---

## KIE Polling Response Format

```
GET https://api.kie.ai/api/v1/jobs/recordInfo?taskId=xxx
```

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "taskId": "xxx",
    "model": "google/imagen4-fast",
    "state": "success",
    "resultJson": "{\"resultUrls\":[\"https://...\"]}",
    "failCode": null,
    "failMsg": null,
    "completeTime": 1771683574507,
    "createTime": 1771683554507
  }
}
```

- `state`: `pending` → `processing` → `success` | `failed`
- Images in: `JSON.parse(resultJson).resultUrls`
- ⚠️ Old endpoint `/api/v1/jobs/getTaskDetail` returns **404** — deprecated

---

## 💰 Credit Cost Analysis (Artio vs KIE.ai)

> Last synced from [kie.ai/pricing](https://kie.ai/pricing): **2026-02-21**
>
> 1 KIE credit ≈ **$0.005 USD**
>
> **Pricing rule: Artio credit = KIE credit × 2** (50% margin)
>
> ⚠️ `seedream/*` không có trên trang pricing công khai — giữ nguyên, chờ confirm.
> Gemini models dùng Google API free quota → giữ nguyên.

### KIE Models — Text-to-Image

| Model ID | Display Name | Premium | Artio Credits | KIE Credits | KIE USD / gen | Margin |
|----------|-------------|---------|:---:|:---:|:---:|:---:|
| `google/imagen4` | Imagen 4 | ❌ | **16** | 8 | $0.04 | ✅ +8 |
| `google/imagen4-fast` | Imagen 4 Fast | ❌ | **8** | 4 | $0.02 | ✅ +4 |
| `google/imagen4-ultra` | Imagen 4 Ultra | ✅ | **24** | 12 | $0.06 | ✅ +12 |
| `nano-banana-pro` | Nano Banana Pro | ❌ | **36** | 18 (1K) | $0.09 | ✅ +18 |
| `flux-2/flex-text-to-image` | Flux-2 Flex | ❌ | **28** | 14 (1K) | $0.07 | ✅ +14 |
| `flux-2/pro-text-to-image` | Flux-2 Pro | ✅ | **10** | 5 (1K) | $0.025 | ✅ +5 |
| `gpt-image/1.5-text-to-image` | GPT Image 1.5 | ✅ | **8** | 4 (med) | $0.02 | ✅ +4 |
| `seedream/4.5-text-to-image` | Seedream 4.5 | ❌ | 8 | *TBD* | *TBD* | ❓ |
| `gemini-3-pro-image-preview` | Gemini 3 Pro Image | ✅ | 15 | — | *Free quota* | 🆓 |
| `gemini-2.5-flash-image` | Gemini 2.5 Flash | ❌ | 8 | — | *Free quota* | 🆓 |

### KIE Models — Image-to-Image / Editing

| Model ID | Display Name | Premium | Artio Credits | KIE Credits | KIE USD / gen | Margin |
|----------|-------------|---------|:---:|:---:|:---:|:---:|
| `google/nano-banana-edit` | Nano Banana Edit | ❌ | **8** | 4 | $0.02 | ✅ +4 |
| `flux-2/flex-image-to-image` | Flux-2 Flex Edit | ❌ | **28** | 14 (1K) | $0.07 | ✅ +14 |
| `flux-2/pro-image-to-image` | Flux-2 Pro Edit | ✅ | **10** | 5 (1K) | $0.025 | ✅ +5 |
| `gpt-image/1.5-image-to-image` | GPT Image 1.5 Edit | ✅ | **8** | 4 (med) | $0.02 | ✅ +4 |
| `seedream/4.5-edit` | Seedream 4.5 Edit | ❌ | 10 | *TBD* | *TBD* | ❓ |

### 📋 Pending Items

1. ❓ **`seedream/*`**: Cần confirm KIE credit cost → giữ nguyên cho đến khi có dữ liệu
2. 🆓 **Gemini models**: Free Google API quota → credit cost = pure revenue
3. ⚠️ **Resolution/quality hardcoded**: `nano-banana-pro` = 1K, `gpt-image` = medium, `seedream` = basic, `flux-2` = 1K — nếu thay đổi sẽ ảnh hưởng KIE cost

---

## Models NOT in Artio (Available on KIE)

| Model | Type | Docs |
|-------|------|------|
| `grok-imagine/text-to-image` | text-to-image | [Docs](https://docs.kie.ai/market/grok-imagine/text-to-image.md) |
| `grok-imagine/image-to-image` | image-to-image | [Docs](https://docs.kie.ai/market/grok-imagine/image-to-image.md) |
| `grok-imagine/upscale` | upscale | [Docs](https://docs.kie.ai/market/grok-imagine/upscale.md) |
| `qwen/text-to-image` | text-to-image | [Docs](https://docs.kie.ai/market/qwen/text-to-image.md) |
| `qwen/image-to-image` | image-to-image | [Docs](https://docs.kie.ai/market/qwen/image-to-image.md) |
| `qwen/image-edit` | editing | [Docs](https://docs.kie.ai/market/qwen/image-edit.md) |
| `ideogram/character` | text-to-image | [Docs](https://docs.kie.ai/market/ideogram/character.md) |
| `recraft/crisp-upscale` | upscale | [Docs](https://docs.kie.ai/market/recraft/crisp-upscale.md) |
| `recraft/remove-background` | utility | [Docs](https://docs.kie.ai/market/recraft/remove-background.md) |
| `z-image` | text-to-image | [Docs](https://docs.kie.ai/market/z-image/z-image.md) |

> Full model list: [https://docs.kie.ai/llms.txt](https://docs.kie.ai/llms.txt)
> Pricing: [https://kie.ai/pricing](https://kie.ai/pricing)
> API Key management: [https://kie.ai/api-key](https://kie.ai/api-key)
