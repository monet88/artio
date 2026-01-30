# KIE Model Mapping

## Overview

Complete mapping of all AI image generation models available via KIE API.

---

## Google / Imagen Models

| Model ID | Name | Type | Quality | Documentation |
|----------|------|------|---------|---------------|
| `google/imagen4` | Imagen 4 | Text-to-Image | Standard | [Link](google/imagen4.md) |
| `google/imagen4-fast` | Imagen 4 Fast | Text-to-Image | Fast | [Link](google/imagen4-fast.md) |
| `google/imagen4-ultra` | Imagen 4 Ultra | Text-to-Image | Ultra (Premium) | [Link](google/imagen4-ultra.md) |
| `google/nano-banana-edit` | Nano Banana Edit | Image Editing | Standard | [Link](google/gemini-2.5-flash-image.md) |
| `google/pro-image-to-image` | Pro Image-to-Image | Image-to-Image | Pro (Premium) | [Link](google/gemini-3-pro-image-preview.md) |

### Model Mapping Notes
- `google/imagen4` → `imagen-4.0-generate-001`
- `google/imagen4-fast` → `imagen-4.0-fast-generate-001`
- `google/imagen4-ultra` → `imagen-4.0-ultra-generate-001`
- `google/nano-banana-edit` → `gemini-2.5-flash-image`
- `google/pro-image-to-image` → `gemini-3-pro-image-preview`

---

## Flux-2 Models

| Model ID | Name | Type | Quality | Documentation |
|----------|------|------|---------|---------------|
| `flux-2/flex-text-to-image` | Flux-2 Flex | Text-to-Image | Standard | [Link](flux2/flux2-flex-text-to-image.md) |
| `flux-2/flex-image-to-image` | Flux-2 Flex Edit | Image-to-Image | Standard | [Link](flux2/flux2-flex-image-to-image.md) |
| `flux-2/pro-text-to-image` | Flux-2 Pro | Text-to-Image | Pro (Premium) | [Link](flux2/flux2-pro-text-to-image.md) |
| `flux-2/pro-image-to-image` | Flux-2 Pro Edit | Image-to-Image | Pro (Premium) | [Link](flux2/flux2-pro-image-to-image.md) |

### Flux-2 Features
- Resolution: `1K` or `2K`
- Aspect ratio: Supports `auto` (matches input image)
- Input images: Up to 8 reference images

---

## GPT Image Models

| Model ID | Name | Type | Quality | Documentation |
|----------|------|------|---------|---------------|
| `gpt-image/1.5-text-to-image` | GPT Image 1.5 | Text-to-Image | Medium/High | [Link](gpt-image/gpt-image-1.5-text-to-image.md) |
| `gpt-image/1.5-image-to-image` | GPT Image 1.5 Edit | Image-to-Image | Medium/High | [Link](gpt-image/gpt-image-1.5-image-to-image.md) |

### GPT Image Features
- Quality: `medium` (balanced) or `high` (detailed)
- Aspect ratios: Limited to `1:1`, `2:3`, `3:2`
- Input images: Up to 16 reference images

---

## Seedream Models

| Model ID | Name | Type | Quality | Documentation |
|----------|------|------|---------|---------------|
| `seedream/4.5-text-to-image` | Seedream 4.5 | Text-to-Image | Basic (2K) / High (4K) | [Link](seedream/seedream-4.5-text-to-image.md) |
| `seedream/4.5-edit` | Seedream 4.5 Edit | Image Editing | Basic (2K) / High (4K) | [Link](seedream/seedream-4.5-edit.md) |

### Seedream Features
- Quality: `basic` (2K output) or `high` (4K output)
- Input images: Up to 14 reference images for editing
- Aspect ratios: 8 options including `21:9`

---

## Quick Reference

### By Type

| Type | Models |
|------|--------|
| **Text-to-Image** | `google/imagen4`, `google/imagen4-fast`, `google/imagen4-ultra`, `flux-2/flex-text-to-image`, `flux-2/pro-text-to-image`, `gpt-image/1.5-text-to-image`, `seedream/4.5-text-to-image` |
| **Image-to-Image** | `google/pro-image-to-image`, `flux-2/flex-image-to-image`, `flux-2/pro-image-to-image`, `gpt-image/1.5-image-to-image` |
| **Image Editing** | `google/nano-banana-edit`, `seedream/4.5-edit` |

### By Premium Status

| Status | Models |
|--------|--------|
| **Free** | `google/imagen4`, `google/imagen4-fast`, `google/nano-banana-edit`, `flux-2/flex-*`, `gpt-image/*`, `seedream/*` |
| **Premium** | `google/imagen4-ultra`, `google/pro-image-to-image`, `flux-2/pro-*` |

---

## Common API Endpoint

All models use the same endpoint:

```
POST https://api.kie.ai/api/v1/jobs/createTask
```

Query task status:
```
GET https://api.kie.ai/api/v1/jobs/getTaskDetail?taskId={taskId}
```
