# Flux-2 Pro - Image to Image

> Image generation by Flux-2 Pro

## Model ID
`flux-2/pro-image-to-image`

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
  "model": "flux-2/pro-image-to-image",
  "callBackUrl": "https://your-domain.com/api/callback",
  "input": {
    "input_urls": ["https://example.com/jar.png", "https://example.com/capsules.png"],
    "prompt": "The jar in image 1 is filled with capsules exactly same as image 2 with the exact logo",
    "aspect_ratio": "1:1",
    "resolution": "1K"
  }
}
```

## Notes
- Pro version - higher quality than Flex
- Supports 1-8 input reference images
