# Cross-Model Compatibility Guide — Artio Templates

**Cập nhật:** 2026-02-23  
**Scope:** KIE API models chỉ — Gemini excluded

---

## Model Quick Reference

| Model ID | Display Name | Type | Free? | Credits | Best for |
|----------|-------------|------|-------|---------|---------|
| `google/nano-banana-edit` | Nano Banana Edit | img2img | ✅ | 8 | Face edit, portrait, style |
| `nano-banana-pro` | Nano Banana Pro | text+img | ✅ | 36 | Complex compositions |
| `seedream/4.5-text-to-image` | Seedream 4.5 | text-only | ✅ | 8 | Text-to-image fast |
| `seedream/4.5-edit` | Seedream 4.5 Edit | img2img | ✅ | 10 | Art style, sketch |
| `flux-2/flex-text-to-image` | Flux-2 Flex | text-only | ✅ | 28 | Creative text-to-image |
| `flux-2/flex-image-to-image` | Flux-2 Flex Edit | img2img | ✅ | 28 | Artistic style transfer |
| `flux-2/pro-image-to-image` | Flux-2 Pro Edit | img2img | 👑 | 10 | Premium quality |
| `gpt-image-1` | GPT Image 1.5 Edit | img2img | 👑 | 8 | Precise instruction following |

---

## Prompt Compatibility Matrix

| Prompt Style | Nano Banana | Seedream | Flux-2 | Ghi chú |
|-------------|-------------|----------|--------|---------|
| Natural language text | ✅ Best | ✅ Good | ✅ Good | Tất cả model đều nhận |
| Comma-separated keywords | ✅ Good | ✅ Best | ✅ Good | Flux thích style này |
| JSON format | ❌ | ❌ | ❌ | Chỉ Gemini, không dùng |
| Long descriptive (>300 chars) | ✅ OK | ⚠️ Trim | ✅ Good | Seedream crop dài |
| `{variable}` interpolation | ✅ | ✅ | ✅ | App tự replace trước khi gửi |

---

## Prompt Writing Rules — Cross-Model Safe

### ✅ DOs:
```
✅ "Transform the person in the photo into..."
✅ "Professional portrait of the person, [style], photorealistic, 8K"
✅ "Convert this image to [style], [quality modifiers]"
✅ Dùng quality suffix: "photorealistic, high quality, 8K, ultra-detailed"
✅ Mention lighting: "soft studio lighting", "cinematic lighting", "golden hour"
```

### ❌ DON'Ts:
```
❌ JSON object format { "prompt": {...} }
❌ Quá ngắn < 30 chars (AI không có đủ context)
❌ Dùng tên model cụ thể trong prompt ("Nano Banana style...")
❌ Lệnh tiêu cực trong positive prompt ("don't add...", "avoid...")
   → để riêng vào negative_prompt field (khi có)
```

---

## Template → Model Mapping Rules

```
IF template.inputFields.any(type == 'image')
  → Chỉ show img2img models
  → Default: google/nano-banana-edit
  
IF template.inputFields.none(type == 'image')
  → Chỉ show text-to-image models
  → Default: seedream/4.5-text-to-image
```

**Hiện tại:** App đã có `_hasImageInput()` check — logic đúng  
**Còn thiếu:** Template DB chưa có `default_model_id` field

---

## Prompt Adaptation theo từng model

### Nano Banana Edit — thêm image reference hint:
```
Original: "Transform into anime style"
Nano Banana: "Transform the person in the uploaded reference photo into anime style, 
               maintain face identity, [details...]"
```

### Seedream — ngắn gọn, focus vào style:
```
Original: "Professional headshot with studio lighting and clean background"
Seedream: "Professional headshot, studio lighting, clean white background, 
           photorealistic, sharp focus, high quality"
```

### Flux-2 — mô tả chi tiết, composition rõ:
```
Original: "Oil painting style portrait"  
Flux-2: "Oil painting portrait, Rembrandt style, rich dark colors, 
         dramatic chiaroscuro lighting, thick brushstrokes, museum quality,
         classical composition, 16th century European art style"
```

---

## Testing Checklist khi import template mới

```
[ ] Test với Nano Banana Edit (model free, most used)
[ ] Test với Seedream 4.5 Edit (second most used)
[ ] Verify output giữ được identity nếu là portrait template
[ ] Verify {variable} replace đúng trong prompt
[ ] Verify image upload flow hoạt động
[ ] Compare output chất lượng với ảnh demo trên nanobananaprompt.org
[ ] Nếu kết quả sai < 30% cases → OK, ship
[ ] Nếu kết quả sai > 30% → điều chỉnh prompt, re-test
```

---

## Bảng Quality Modifiers (sử dụng cuối prompt)

Thêm vào cuối mỗi prompt để tăng quality:

| Modifier | Hiệu quả |
|---------|---------|
| `photorealistic` | Realistic photo look |
| `8K resolution` | High detail |
| `ultra-detailed` | Fine detail everywhere |
| `cinematic lighting` | Movie-quality lighting |
| `sharp focus` | Clear, not blurry |
| `professional photography` | Commercial quality |
| `high quality` | General boost |
| `award-winning photography` | Best quality push |
