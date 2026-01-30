# Flux-2 Flex - Text to Image

> High-quality photorealistic image generation powered by Flux-2

## Model ID
`flux-2/flex-text-to-image`

## Endpoint
`POST /api/v1/jobs/createTask`

## Input Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `prompt` | string | Yes | - | Text description (3-5000 chars) |
| `aspect_ratio` | string | Yes | `1:1` | `1:1`, `4:3`, `3:4`, `16:9`, `9:16`, `3:2`, `2:3`, `auto` |
| `resolution` | string | Yes | `1K` | `1K` or `2K` |

## Request Example

```json
{
  "model": "flux-2/flex-text-to-image",
  "callBackUrl": "https://your-domain.com/api/callback",
  "input": {
    "prompt": "A humanoid figure with a vintage television set for a head...",
    "aspect_ratio": "1:1",
    "resolution": "1K"
  }
}
```

## Notes
- `auto` aspect ratio defaults to `1:1` for text-to-image (no input image reference)
- Resolution: 1K or 2K output
