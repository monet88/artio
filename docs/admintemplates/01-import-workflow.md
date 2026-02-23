# Template Import Workflow — nanobananaprompt.org → Artio Admin

**Ngày tạo:** 2026-02-23  
**Mục tiêu:** Hướng dẫn quy trình import template từ nanobananaprompt.org vào Artio Admin chuẩn cross-model  
**Scope:** All KIE models (Nano Banana, Seedream, Flux-2) — bỏ qua Gemini

---

## Tổng quan luồng

```
nanobananaprompt.org          Admin UI              Supabase DB
      │                          │                      │
      │  1. copy prompt text     │                      │
      ├─────────────────────────►│                      │
      │                          │  2. add {variables}  │
      │                          │─────────────────────►│
      │                          │  3. set input_fields │
      │                          │─────────────────────►│
      │                          │  4. assign model     │
      │                          │─────────────────────►│
      │                          │  5. add thumbnail URL│
      │                          │─────────────────────►│
                                 │  6. test generate    │
```

---

## Bước 1 — Tìm prompt phù hợp trên nanobananaprompt.org

### URL categories:
| Category | URL | Artio Category |
|----------|-----|---------------|
| Portrait | https://nanobananaprompt.org/prompts/portrait | Portrait & Face Effects |
| Polaroid | https://nanobananaprompt.org/prompts/polaroid | Creative & Fun |
| Product | https://nanobananaprompt.org/prompts/product | Photo Enhancement |
| Figurine | https://nanobananaprompt.org/prompts/figurine | Creative & Fun |
| Sketch to Photo | từ homepage | Art Style Transfer |
| AI Halloween | từ homepage | Creative & Fun |
| AI Photo Colorizer | từ homepage | Photo Enhancement |

### Tiêu chí chọn prompt tốt:
- ✅ Text thuần (không phải JSON)
- ✅ Có mô tả style rõ ràng (anime, polaroid, 3D figure...)
- ✅ Có quality keywords (hyper-realistic, 8K, cinematic lighting...)
- ✅ Có thể thêm variable (chỉnh costume, style, background...)
- ❌ Bỏ qua JSON prompt phức tạp (tối ưu cho Google AI Studio, không phải KIE)

---

## Bước 2 — Convert prompt thành template chuẩn

### Rules chuyển đổi:

| Vấn đề | Cách xử lý |
|--------|-----------|
| Prompt dài, không có variable | Giữ nguyên + thêm `{custom_style}` cuối |
| Prompt có mô tả người cụ thể | Replace bằng "the person in the uploaded photo" |
| Prompt có JSON format | Flatten thành text, giữ ý chính |
| Prompt quá ngắn (<50 chars) | Thêm quality suffix: `, photorealistic, 8K, ultra-detailed` |

### Template cho chỉnh sửa ảnh (img2img):
```
{original_prompt}, transform the person in the uploaded photo,
preserve facial features and identity, {extra_detail}
```

### Template cho text-to-image:
```
{original_prompt}, {subject_description}, {quality_suffix}
```

---

## Bước 3 — Thiết kế input_fields

### Nguyên tắc:
- Luôn có `image` field nếu template cần ảnh user (img2img)
- Tối đa **3-4 fields** (UX tốt nhất)
- Sử dụng `select` cho các option có giới hạn
- Sử dụng `text` cho custom input ngắn (<100 chars)

### Field types được hỗ trợ:
```json
{ "name": "image", "type": "image", "label": "...", "required": true }
{ "name": "style", "type": "select", "label": "...", "options": ["A","B","C"] }
{ "name": "description", "type": "text", "label": "...", "required": false, "placeholder": "..." }
{ "name": "intensity", "type": "slider", "label": "...", "min": 0.3, "max": 0.9, "default_value": "0.7" }
```

### Template trong prompt_template dùng `{field_name}`:
```
"Transform into {style} style, {description}"
→ {style} được replace bởi giá trị user chọn
```

---

## Bước 4 — Chọn model phù hợp

### Quick rule:
```
Template CÓ image input field  → dùng img2img model
Template KHÔNG có image input  → dùng text-to-image model
```

### Recommended model theo use case:

| Use case | Model (default) | Lý do |
|----------|----------------|-------|
| Portrait/face edit | `google/nano-banana-edit` | Tốt nhất cho face editing, free |
| Style transfer nhẹ | `seedream/4.5-edit` | Balanced quality/cost |
| Artistic style mạnh | `flux-2/flex-image-to-image` | FLUX chạy style chính xác |
| Text-to-image đơn | `seedream/4.5-text-to-image` | Rẻ, fast |
| Creative/product | `flux-2/flex-text-to-image` | Quality tốt |

> **Lưu ý:** Model `default` trong DB chỉ là gợi ý. User vẫn có thể chọn model khác trong app.

---

## Bước 5 — Negative prompt (nên thêm)

Thêm `negative_prompt` field vào DB (hiện admin chưa có — cần thêm sau):

| Template type | Negative prompt đề xuất |
|--------------|------------------------|
| Portrait | `blurry, distorted face, ugly, extra limbs, bad anatomy, watermark` |
| Style transfer | `realistic, photo, blurry, low quality, jpeg artifacts` |
| 3D Figurine | `2D, flat, blurry, poorly detailed, bad proportions` |
| Polaroid | `digital, sharp clean photo, modern camera, blurry` |

---

## Bước 6 — Thumbnail URL

Dùng **Unsplash** cho thumbnail demo:
```
https://images.unsplash.com/photo-{ID}?w=512&h=512&fit=crop
```

Tìm ảnh phù hợp tại https://unsplash.com, lấy photo ID từ URL.

Hoặc dùng Supabase Storage nếu có ảnh output mẫu thực tế (tốt nhất).

---

## Checklist trước khi Save template

```
[ ] name: ngắn gọn, dễ hiểu (< 30 chars)
[ ] description: mô tả rõ ràng cho user biết template làm gì
[ ] category: đúng 1 trong 5 category của Artio
[ ] prompt_template: có {variable} nếu có field tương ứng
[ ] prompt_template: không còn placeholder chưa được map
[ ] input_fields: valid JSON, đã test validate
[ ] thumbnail_url: ảnh load được, đúng aspect ratio
[ ] is_active: true
[ ] is_premium: false (free first, upgrade later)
[ ] order: số thứ tự trong category
```

---

## Ví dụ hoàn chỉnh — Template "AI Polaroid"

```json
{
  "name": "Vintage Polaroid",
  "description": "Transform your photo into a vintage Polaroid instant photo with nostalgic film aesthetics",
  "category": "Creative & Fun",
  "prompt_template": "Transform into a vintage Polaroid instant photo with classic white border, aged film grain texture, soft faded colors with warm tones, slight vignette effect, nostalgic 1970s aesthetic, authentic instant photography look, photorealistic",
  "input_fields": [
    {"name": "image", "type": "image", "label": "Upload your photo", "required": true},
    {"name": "era", "type": "select", "label": "Film Era", "options": ["1970s", "1980s", "1990s"], "required": false}
  ],
  "default_aspect_ratio": "1:1",
  "is_premium": false,
  "is_active": true
}
```

**Prompt khi user chọn "1980s":**
> *"Transform into a vintage Polaroid instant photo... nostalgic 1970s aesthetic"* + Additional details: era=1980s
