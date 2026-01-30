# Seedream4.5 - Text to Image

> High-quality photorealistic image generation powered by Seedream's advanced AI model

## Model ID
`seedream/4.5-text-to-image`

## Endpoint
`POST /api/v1/jobs/createTask`

## Input Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `prompt` | string | Yes | - | Text description (Max: 3000 chars) |
| `aspect_ratio` | string | Yes | `1:1` | `1:1`, `4:3`, `3:4`, `16:9`, `9:16`, `2:3`, `3:2`, `21:9` |
| `quality` | string | Yes | `basic` | `basic` (2K) or `high` (4K) |

## Request Example

```json
{
  "model": "seedream/4.5-text-to-image",
  "callBackUrl": "https://your-domain.com/api/callback",
  "input": {
    "prompt": "A full-process cafe design tool...",
    "aspect_ratio": "1:1",
    "quality": "basic"
  }
}
```

## Response Example

```json
{
  "code": 200,
  "msg": "success",
  "data": {
    "taskId": "task_seedream_1765166238716"
  }
}
```

## Notes
- Basic quality outputs 2K images
- High quality outputs 4K images
