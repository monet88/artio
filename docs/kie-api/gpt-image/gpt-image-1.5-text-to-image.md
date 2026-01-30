# GPT Image 1.5 - Text to Image

> Generate images using GPT Image 1.5 model

## Model ID
`gpt-image/1.5-text-to-image`

## Endpoint
`POST /api/v1/jobs/createTask`

## Input Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `prompt` | string | Yes | - | Text description |
| `aspect_ratio` | string | Yes | `1:1` | `1:1`, `2:3`, `3:2` |
| `quality` | string | Yes | `medium` | `medium` (balanced) or `high` (slow/detailed) |

## Request Example

```json
{
  "model": "gpt-image/1.5-text-to-image",
  "callBackUrl": "https://your-domain.com/api/callback",
  "input": {
    "prompt": "Create a photorealistic candid photograph...",
    "aspect_ratio": "1:1",
    "quality": "medium"
  }
}
```

## Notes
- Limited aspect ratios compared to other models
- Quality: medium = balanced, high = slower but more detailed
