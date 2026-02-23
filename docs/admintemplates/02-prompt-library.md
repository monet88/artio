# Artio Template Prompt Library — Ready to Import

**Nguồn:** nanobananaprompt.org + custom adaptation  
**Cập nhật:** 2026-02-23  
**Cross-model:** ✅ Nano Banana · Seedream · Flux-2 (Gemini excluded)

> **Cách dùng:** Copy từng block JSON vào Admin → Templates → New Template

---

## 📸 Category: Portrait & Face Effects

### T01 — AI Portrait Headshot
**Model:** `google/nano-banana-edit` (img2img)  
**Use case:** Biến ảnh thường thành professional headshot

```json
{
  "name": "Professional Headshot",
  "description": "Transform your casual photo into a polished professional headshot",
  "category": "Portrait & Face Effects",
  "prompt_template": "Professional corporate headshot of the person in the photo, clean background in {background_color}, sharp focus on face, professional studio lighting with soft shadows, polished and confident look, photorealistic, 8K",
  "input_fields": [
    {"name": "image", "type": "image", "label": "Upload your photo", "required": true},
    {"name": "background_color", "type": "select", "label": "Background Color", "options": ["white", "light gray", "navy blue", "dark charcoal"], "required": true}
  ],
  "default_aspect_ratio": "3:4",
  "is_premium": false
}
```

---

### T02 — Age Transformation
**Model:** `google/nano-banana-edit` (img2img)

```json
{
  "name": "Age Transformation",
  "description": "See yourself at a different age — younger or older",
  "category": "Portrait & Face Effects",
  "prompt_template": "Realistically transform the person in the photo to appear {age_target}, maintain same identity and facial structure, natural aging or de-aging effects, preserve skin texture and hair style adapted to age, photorealistic portrait, cinematic lighting",
  "input_fields": [
    {"name": "image", "type": "image", "label": "Upload your photo", "required": true},
    {"name": "age_target", "type": "select", "label": "Transform to Age", "options": ["20 years old", "30 years old", "50 years old", "70 years old", "80 years old"], "required": true}
  ],
  "default_aspect_ratio": "3:4",
  "is_premium": false
}
```

---

### T03 — Skin Tone Changer *(fix của template hiện có)*
**Model:** `google/nano-banana-edit` (img2img)

```json
{
  "name": "Skin Tone Changer",
  "description": "Naturally adjust skin tone while preserving facial texture and lighting",
  "category": "Portrait & Face Effects",
  "prompt_template": "Adjust the skin tone of the person in this photo to {skin_tone} complexion, natural and realistic result, preserve original facial features and texture, maintain consistent lighting, photorealistic, high quality portrait",
  "input_fields": [
    {"name": "image", "type": "image", "label": "Upload your photo", "required": true},
    {"name": "skin_tone", "type": "select", "label": "Target Skin Tone", "options": ["fair porcelain", "light ivory", "medium beige", "olive tan", "warm brown", "deep dark brown"], "required": true}
  ],
  "default_aspect_ratio": "3:4",
  "is_premium": false
}
```

---

### T04 — Costume & Outfit Change
**Model:** `google/nano-banana-edit` (img2img)

```json
{
  "name": "Outfit Change",
  "description": "Dress yourself in different styles and outfits",
  "category": "Portrait & Face Effects",
  "prompt_template": "Keep the face of the person identical, change their outfit to {outfit_style} clothing style, {outfit_color} color palette, realistic fabric textures, natural lighting, photorealistic full body or half-body portrait, high quality",
  "input_fields": [
    {"name": "image", "type": "image", "label": "Upload your photo", "required": true},
    {"name": "outfit_style", "type": "select", "label": "Style", "options": ["formal business suit", "casual streetwear", "traditional Vietnamese ao dai", "Korean hanbok", "fantasy warrior armor", "cyberpunk jacket", "elegant evening gown"], "required": true},
    {"name": "outfit_color", "type": "select", "label": "Color", "options": ["black", "white", "red", "navy blue", "gold", "emerald green"], "required": false}
  ],
  "default_aspect_ratio": "3:4",
  "is_premium": false
}
```

---

## 🎨 Category: Art Style Transfer

### T05 — Studio Ghibli Anime
**Model:** `seedream/4.5-edit` hoặc `flux-2/flex-image-to-image`

```json
{
  "name": "Ghibli Anime Style",
  "description": "Transform your photo into Studio Ghibli anime art style",
  "category": "Art Style Transfer",
  "prompt_template": "Studio Ghibli anime art style illustration of the person in the photo, soft watercolor tones, hand-drawn aesthetic with clean lines, expressive big eyes, warm and nostalgic color palette, detailed natural background with Ghibli magic elements, high quality animation art",
  "input_fields": [
    {"name": "image", "type": "image", "label": "Upload your photo", "required": true},
    {"name": "background", "type": "select", "label": "Background Setting", "options": ["enchanted forest", "countryside meadow", "floating castle", "seaside village", "magical library"], "required": false}
  ],
  "default_aspect_ratio": "3:4",
  "is_premium": false
}
```

---

### T06 — Oil Painting Master
**Model:** `flux-2/flex-image-to-image`

```json
{
  "name": "Oil Painting Portrait",
  "description": "Turn your photo into a classic oil painting masterpiece",
  "category": "Art Style Transfer",
  "prompt_template": "Transform into a museum-quality oil painting portrait in the style of {painting_style}, rich deep colors, visible brushstrokes with thick impasto texture, dramatic chiaroscuro lighting, classical composition, Renaissance or Baroque aesthetic, fine art masterpiece quality",
  "input_fields": [
    {"name": "image", "type": "image", "label": "Upload your photo", "required": true},
    {"name": "painting_style", "type": "select", "label": "Painting Style", "options": ["Rembrandt", "Van Gogh", "Vermeer", "Monet Impressionist", "Da Vinci Renaissance"], "required": true}
  ],
  "default_aspect_ratio": "3:4",
  "is_premium": false
}
```

---

### T07 — Pencil Sketch
**Model:** `seedream/4.5-edit` (img2img)

```json
{
  "name": "Pencil Sketch",
  "description": "Convert your photo into a realistic hand-drawn pencil sketch",
  "category": "Art Style Transfer",
  "prompt_template": "Convert the photo into a detailed pencil sketch drawing, {sketch_style} style, realistic shading with crosshatching technique, white paper background, clean hand-drawn aesthetic, fine art quality pencil work",
  "input_fields": [
    {"name": "image", "type": "image", "label": "Upload your photo", "required": true},
    {"name": "sketch_style", "type": "select", "label": "Sketch Style", "options": ["detailed realistic", "loose gestural", "architectural technical", "charcoal smudged"], "required": true}
  ],
  "default_aspect_ratio": "3:4",
  "is_premium": false
}
```

---

## 📷 Category: Creative & Fun

### T08 — Vintage Polaroid
**Model:** `google/nano-banana-edit` (img2img)  
**Nguồn:** nanobananaprompt.org/prompts/polaroid

```json
{
  "name": "Vintage Polaroid",
  "description": "Transform your photo into an authentic vintage Polaroid instant photo",
  "category": "Creative & Fun",
  "prompt_template": "Transform into an authentic vintage Polaroid instant photo from the {era}, classic thick white border with iconic Polaroid frame, aged film grain and light leaks, faded warm color tones with slight overexposure, soft vignette edges, nostalgic instant photography look, analog film aesthetic, photorealistic",
  "input_fields": [
    {"name": "image", "type": "image", "label": "Upload your photo", "required": true},
    {"name": "era", "type": "select", "label": "Film Era", "options": ["1970s", "1980s", "1990s"], "required": false}
  ],
  "default_aspect_ratio": "1:1",
  "is_premium": false
}
```

---

### T09 — 3D Chibi Figurine
**Model:** `google/nano-banana-edit` (img2img)  
**Nguồn:** nanobananaprompt.org/prompts/figurine

```json
{
  "name": "3D Chibi Figurine",
  "description": "Turn yourself into an adorable 3D chibi collectible figurine",
  "category": "Creative & Fun",
  "prompt_template": "Transform the person into a high-quality 3D chibi collectible figurine, oversized head with big expressive eyes small cute body, {material} material finish, vibrant colors, displayed on a clean product display base, studio product photography lighting, white background, collector grade quality, ultra-detailed 3D render",
  "input_fields": [
    {"name": "image", "type": "image", "label": "Upload your photo", "required": true},
    {"name": "material", "type": "select", "label": "Figurine Material", "options": ["shiny PVC vinyl", "matte resin", "plush soft toy", "glossy ceramic"], "required": true}
  ],
  "default_aspect_ratio": "3:4",
  "is_premium": false
}
```

---

### T10 — Superhero Action Figure
**Model:** `google/nano-banana-edit` hoặc `flux-2/flex-image-to-image`  
**Nguồn:** nanobananaprompt.org/prompts/figurine

```json
{
  "name": "Superhero Action Figure",
  "description": "Become a superhero in an epic collectible action figure",
  "category": "Creative & Fun",
  "prompt_template": "Turn this person into a superhero action figure with {hero_power} themed costume, dynamic heroic pose, detailed muscular proportions, metallic and fabric texture detail, displayed in a collector box with dramatic comic book art graphics, product photography on white background, ultra-detailed",
  "input_fields": [
    {"name": "image", "type": "image", "label": "Upload your photo", "required": true},
    {"name": "hero_power", "type": "select", "label": "Superpower Theme", "options": ["fire elemental", "ice and frost", "electric lightning", "shadow ninja", "space cosmic", "nature earth"], "required": true}
  ],
  "default_aspect_ratio": "3:4",
  "is_premium": false
}
```

---

## 🖼 Category: Photo Enhancement

### T11 — AI Photo Colorizer
**Model:** `google/nano-banana-edit` (img2img)

```json
{
  "name": "Photo Colorizer",
  "description": "Bring black & white or faded photos back to life with vibrant colors",
  "category": "Photo Enhancement",
  "prompt_template": "Colorize this black and white photo with natural, realistic colors, accurate skin tones for the era, period-appropriate clothing colors, realistic environmental colors, photorealistic result preserving all original details and textures, high quality color restoration",
  "input_fields": [
    {"name": "image", "type": "image", "label": "Upload black & white photo", "required": true}
  ],
  "default_aspect_ratio": "1:1",
  "is_premium": false
}
```

---

### T12 — Product Photography
**Model:** `flux-2/flex-image-to-image` hoặc `seedream/4.5-edit`  
**Nguồn:** nanobananaprompt.org/prompts/product

```json
{
  "name": "Product Studio Shot",
  "description": "Turn casual product photos into professional e-commerce studio shots",
  "category": "Photo Enhancement",
  "prompt_template": "Professional {shot_style} product photography of the item, clean {background_type} background, dramatic studio lighting with soft shadows, sharp product details, commercial advertising quality, high resolution, photorealistic e-commerce shot",
  "input_fields": [
    {"name": "image", "type": "image", "label": "Upload your product photo", "required": true},
    {"name": "shot_style", "type": "select", "label": "Shot Style", "options": ["minimalist white studio", "lifestyle contextual", "luxury dark dramatic", "natural wooden surface", "gradient colorful"], "required": true},
    {"name": "background_type", "type": "select", "label": "Background", "options": ["pure white", "soft gradient", "dark black", "marble texture", "wood surface"], "required": false}
  ],
  "default_aspect_ratio": "1:1",
  "is_premium": false
}
```

---

## 🏗 Category: Removal & Editing

### T13 — Background Remover & Replacer
**Model:** `google/nano-banana-edit` (img2img)

```json
{
  "name": "Background Changer",
  "description": "Replace your photo background with any scene or setting",
  "category": "Removal & Editing",
  "prompt_template": "Keep the person in the photo exactly as they are, replace only the background with {new_background} scene, professional edge separation between subject and background, realistic lighting match, photorealistic composite, high quality",
  "input_fields": [
    {"name": "image", "type": "image", "label": "Upload your photo", "required": true},
    {"name": "new_background", "type": "select", "label": "New Background", "options": ["Tokyo city skyline at night", "Paris Eiffel Tower at sunset", "tropical beach paradise", "modern office interior", "cherry blossom park in spring", "New York Times Square", "snowy mountain peak"], "required": true}
  ],
  "default_aspect_ratio": "3:4",
  "is_premium": false
}
```

---

## Thứ tự import đề xuất (priority)

| Priority | Template | Lý do |
|----------|----------|-------|
| 1 | Skin Tone Changer (T03) | Fix template hiện có sai prompt |
| 2 | Vintage Polaroid (T08) | Viral, dễ test |
| 3 | 3D Chibi Figurine (T09) | Trending, high engagement |
| 4 | Professional Headshot (T01) | High utility for users |
| 5 | Ghibli Anime (T05) | Art style transfer flagship |
| 6 | Background Changer (T13) | Most requested feature |
| 7+ | Còn lại | Theo nhu cầu |
