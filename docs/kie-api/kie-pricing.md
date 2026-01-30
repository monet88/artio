# KIE API Pricing

## Credit System

- **1 credit = $0.005** (200 credits = $1.00)
- Billing: Per image/task, not per request
- Storage: Generated images stored 14 days

---

## Image Generation Models

### Google / Imagen

| Model | Credits | USD | Resolution | Notes |
|-------|---------|-----|------------|-------|
| `google/imagen4-fast` | 4 | ~$0.020 | Standard | Fastest, good quality |
| `google/imagen4` | 6 | ~$0.030 | Standard | Balanced speed/quality |
| `google/imagen4-ultra` | 12 | ~$0.060 | High | Premium quality |
| `google/nano-banana-edit` | 8 | ~$0.040 | Standard | Image editing |
| `google/pro-image-to-image` | 15 | ~$0.075 | High | Premium img2img |

### Flux-2

| Model | Credits | USD | Resolution | Notes |
|-------|---------|-----|------------|-------|
| `flux-2/flex-text-to-image` (1K) | 14 | ~$0.070 | 1K | Standard |
| `flux-2/flex-text-to-image` (2K) | 24 | ~$0.120 | 2K | High res |
| `flux-2/flex-image-to-image` (1K) | 14 | ~$0.070 | 1K | Standard |
| `flux-2/flex-image-to-image` (2K) | 24 | ~$0.120 | 2K | High res |
| `flux-2/pro-text-to-image` (1K) | 5 | ~$0.025 | 1K | Premium |
| `flux-2/pro-text-to-image` (2K) | 7 | ~$0.035 | 2K | Premium high res |
| `flux-2/pro-image-to-image` (1K) | 5 | ~$0.025 | 1K | Premium |
| `flux-2/pro-image-to-image` (2K) | 7 | ~$0.035 | 2K | Premium high res |

### GPT Image 1.5

| Model | Credits | USD | Quality | Notes |
|-------|---------|-----|---------|-------|
| `gpt-image/1.5-text-to-image` | 6 | ~$0.030 | Medium/High | Flat pricing |
| `gpt-image/1.5-image-to-image` | 6 | ~$0.030 | Medium/High | Flat pricing |

### Seedream

| Model | Credits | USD | Resolution | Notes |
|-------|---------|-----|------------|-------|
| `seedream/4.5-text-to-image` (basic) | 5 | ~$0.025 | 2K | Standard |
| `seedream/4.5-text-to-image` (high) | 8 | ~$0.040 | 4K | High quality |
| `seedream/4.5-edit` (basic) | 5 | ~$0.025 | 2K | Standard |
| `seedream/4.5-edit` (high) | 8 | ~$0.040 | 4K | High quality |

### Other Image Models

| Model | Credits | USD | Notes |
|-------|---------|-----|-------|
| `qwen/text-to-image` | 5 | ~$0.025 | Alibaba model |
| `qwen/image-to-image` | 5 | ~$0.025 | Alibaba model |
| `grok-imagine/text-to-image` | 8 | ~$0.040 | xAI model |
| `ideogram/character` | 10 | ~$0.050 | Character generation |
| `recraft/crisp-upscale` | 3 | ~$0.015 | Image upscaling |
| `recraft/remove-background` | 2 | ~$0.010 | BG removal |

---

## Pricing Tiers for Artio App

### Recommended Model Selection

| Tier | Model | Credits | Use Case |
|------|-------|---------|----------|
| **Free** | `google/imagen4-fast` | 4 | Default for free users |
| **Standard** | `google/imagen4` | 6 | Balanced option |
| **Premium** | `google/imagen4-ultra` | 12 | Subscription users |
| **Premium** | `flux-2/pro-text-to-image` | 5-7 | Alternative premium |

### Cost Analysis (per 1000 images)

| Model | Credits | Cost |
|-------|---------|------|
| Imagen 4 Fast | 4,000 | $20 |
| Imagen 4 | 6,000 | $30 |
| Imagen 4 Ultra | 12,000 | $60 |
| GPT Image 1.5 | 6,000 | $30 |
| Seedream 4.5 | 5,000 | $25 |
| Flux-2 Pro 1K | 5,000 | $25 |

---

## Notes

- Prices subject to change; verify at https://kie.ai/pricing
- Some models have resolution-based pricing (1K vs 2K vs 4K)
- Premium models may have queue priority
- Batch discounts available for enterprise

---

*Last Updated: 2026-01-30*
*Source: https://kie.ai/pricing, web search results*
