# Seedream4.5 - Edit

> Image editing by Seedream4.5

## Model ID
`seedream/4.5-edit`

## Endpoint
`POST /api/v1/jobs/createTask`

## Input Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `prompt` | string | Yes | - | Edit instruction (Max: 3000 chars) |
| `image_urls` | array | Yes | - | Input images (Max: 14 images, JPEG/PNG/WebP, 10MB each) |
| `aspect_ratio` | string | Yes | `1:1` | `1:1`, `4:3`, `3:4`, `16:9`, `9:16`, `2:3`, `3:2`, `21:9` |
| `quality` | string | Yes | `basic` | `basic` (2K) or `high` (4K) |

## Request Example

```json
{
  "model": "seedream/4.5-edit",
  "callBackUrl": "https://your-domain.com/api/callback",
  "input": {
    "prompt": "Keep the model's pose unchanged. Change the clothing...",
    "image_urls": ["https://example.com/input.webp"],
    "aspect_ratio": "1:1",
    "quality": "basic"
  }
}
```

## Notes
- Supports up to 14 input images for multi-reference editing
- Basic = 2K, High = 4K
