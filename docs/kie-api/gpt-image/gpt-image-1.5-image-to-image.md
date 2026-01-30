# GPT Image 1.5 - Image to Image

> Generate images from input images using GPT Image 1.5 model

## Model ID
`gpt-image/1.5-image-to-image`

## Endpoint
`POST /api/v1/jobs/createTask`

## Input Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `input_urls` | array | Yes | - | Input images (Max: 16, JPEG/PNG/WebP, 10MB each) |
| `prompt` | string | Yes | - | Edit instruction |
| `aspect_ratio` | string | Yes | `3:2` | `1:1`, `2:3`, `3:2` |
| `quality` | string | Yes | `medium` | `medium` or `high` |

## Request Example

```json
{
  "model": "gpt-image/1.5-image-to-image",
  "callBackUrl": "https://your-domain.com/api/callback",
  "input": {
    "input_urls": ["https://example.com/image.webp"],
    "prompt": "Edit the image to dress the woman...",
    "aspect_ratio": "3:2",
    "quality": "medium"
  }
}
```

## Notes
- Supports up to 16 input URLs per request
- Use File Upload API first to get image URLs
