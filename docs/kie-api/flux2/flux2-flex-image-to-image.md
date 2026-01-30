# Flux-2 Flex - Image to Image

> Image generation by Flux-2 Flex

## Model ID
`flux-2/flex-image-to-image`

## Endpoint
`POST /api/v1/jobs/createTask`

## Input Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `input_urls` | array | Yes | - | Input images (1-8 images, JPEG/PNG/WebP, 10MB each) |
| `prompt` | string | Yes | - | Edit instruction (3-5000 chars) |
| `aspect_ratio` | string | Yes | `1:1` | `1:1`, `4:3`, `3:4`, `16:9`, `9:16`, `3:2`, `2:3`, `auto` |
| `resolution` | string | Yes | `1K` | `1K` or `2K` |

## Request Example

```json
{
  "model": "flux-2/flex-image-to-image",
  "callBackUrl": "https://your-domain.com/api/callback",
  "input": {
    "input_urls": ["https://example.com/image1.png", "https://example.com/image2.png"],
    "prompt": "Replace the can in image 2 with the can from image 1",
    "aspect_ratio": "1:1",
    "resolution": "1K"
  }
}
```

## Notes
- Supports 1-8 input reference images
- Can reference multiple images in prompt (image 1, image 2, etc.)
