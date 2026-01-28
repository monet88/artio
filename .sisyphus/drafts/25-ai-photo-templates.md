# Draft: Adding 25 AI Photo Templates

**Date**: 2026-01-28
**Status**: Brainstorming Phase

## User Request
Add 25 new AI photo templates to Artio app:

1. Remove Filter from Photo
2. AI Mockup Generator
3. AI Object Remover
4. Sketch to Photo
5. Remove Text from Image
6. Hug My Younger Self
7. AI Snow Filter
8. Face Cutout
9. AI Costume Generator
10. AI Pet Portrait
11. AI Emoji Maker
12. Passport Photo Maker
13. Chibi Art Generator
14. Pixel Art Generator
15. Lego Filter
16. Ghibli AI Generator
17. AI Graffiti Generator
18. AI Polaroid Maker
19. AI Bangs Filter
20. AI Beard Filter
21. AI Beard Remover
22. Skin Color Changer
23. Black & White Filter
24. Fisheye Filter
25. AI Color Correction

## Current System Analysis

### TemplateModel Structure
```dart
@freezed
class TemplateModel with _$TemplateModel {
  const factory TemplateModel({
    required String id,
    required String name,
    required String description,
    required String thumbnailUrl,
    required String category,
    required String promptTemplate,
    required List<InputFieldModel> inputFields,
    @Default('1:1') String defaultAspectRatio,
    @Default(false) bool isPremium,
    @Default(0) int order,
  }) = _TemplateModel;
}
```

### Edge Function Capabilities
- Supports KIE API models: `nano-banana-pro`, `google/nano-banana-edit`, `google/imagen4`
- Accepts: `prompt`, `aspect_ratio`, `image_input[]`
- Returns generated images from KIE API

### Key Findings
1. Templates stored in Supabase `templates` table
2. Dynamic input fields allow flexible forms per template
3. Current system uses prompt templates + user inputs
4. No admin UI yet - templates must be added via SQL/seed data

## Open Questions (To Be Answered)

### Technical Feasibility
- [ ] Does Nano Banana API support all 25 transformations?
- [ ] Which templates require image input vs text-only?
- [ ] Are there API limitations for specific effects (e.g., object removal)?

### Content Requirements
- [ ] Thumbnail images for each template?
- [ ] Exact prompt templates for each effect?
- [ ] Category organization strategy?

### Business Logic
- [ ] Should any be premium-only?
- [ ] Order/priority in template list?
- [ ] Are all 25 needed for MVP or can we phase?

## Confirmed Decisions

### API & Delivery
- **API Support**: Nano Banana supports all 25 effects ✓
- **Delivery**: All 25 templates at once (single migration)
- **Premium**: All FREE for MVP (monetize later)
- **Thumbnails**: Generate with AI (using Nano Banana to create samples)

### Input Pattern (Standardized)
- All templates: **1 image upload + auto-generated prompt**
- Type: Image-to-image / Edit mode
- User provides image → system applies effect with predefined prompt

### Categories (5 total)
1. **Portrait & Face Effects** (7 templates)
   - Hug My Younger Self
   - AI Bangs Filter
   - AI Beard Filter
   - AI Beard Remover
   - Skin Color Changer
   - Face Cutout
   - Passport Photo Maker

2. **Removal & Editing** (4 templates)
   - Remove Filter from Photo
   - AI Object Remover
   - Remove Text from Image
   - AI Color Correction

3. **Art Style Transfer** (6 templates)
   - Sketch to Photo
   - Chibi Art Generator
   - Pixel Art Generator
   - Lego Filter
   - Ghibli AI Generator
   - AI Graffiti Generator

4. **Photo Enhancement** (4 templates)
   - AI Snow Filter
   - Black & White Filter
   - Fisheye Filter
   - AI Polaroid Maker

5. **Creative & Fun** (4 templates)
   - AI Mockup Generator
   - AI Costume Generator
   - AI Pet Portrait
   - AI Emoji Maker

## Implementation Approach

### Option A: SQL Migration (Recommended)
**Pros:**
- Version controlled
- Reproducible across environments
- Standard Supabase workflow

**Cons:**
- Requires writing SQL INSERT statements

### Option B: Seed Data Script
**Pros:**
- Easier to maintain JSON structure
- Can validate before inserting

**Cons:**
- Extra tooling needed

### Option C: Direct Supabase Dashboard
**Pros:**
- Fastest for one-time insert

**Cons:**
- Not version controlled
- Error-prone for 25 entries

## Template Structure (per template)

```sql
INSERT INTO templates (name, description, thumbnail_url, category, prompt_template, input_fields, default_aspect_ratio, is_premium, "order")
VALUES (
  'Ghibli AI Generator',
  'Transform your photo into Studio Ghibli anime style',
  'https://storage.supabase.co/.../ghibli-thumb.jpg',
  'Art Style Transfer',
  'Transform this image into Studio Ghibli anime art style, soft colors, hand-drawn aesthetic, magical atmosphere',
  '[{"name": "image", "type": "image", "label": "Upload your photo", "required": true}]'::jsonb,
  '1:1',
  false,
  1
);
```

## Prompt Templates (Draft)

| Template | Prompt Template |
|----------|-----------------|
| Remove Filter from Photo | Remove all filters and restore natural colors |
| AI Mockup Generator | Place this image onto a professional product mockup |
| AI Object Remover | Remove the selected object seamlessly |
| Sketch to Photo | Convert this sketch to realistic photo |
| Remove Text from Image | Remove all text and watermarks from image |
| Hug My Younger Self | Create heartwarming photo of person hugging younger version |
| AI Snow Filter | Add realistic falling snow effect |
| Face Cutout | Extract face/person from background |
| AI Costume Generator | Dress person in {costume_type} costume |
| AI Pet Portrait | Transform pet photo into artistic portrait |
| AI Emoji Maker | Create emoji/sticker from face |
| Passport Photo Maker | Create standard passport photo with white background |
| Chibi Art Generator | Transform into cute chibi anime character |
| Pixel Art Generator | Convert to retro pixel art style |
| Lego Filter | Transform into Lego brick mosaic style |
| Ghibli AI Generator | Transform into Studio Ghibli anime style |
| AI Graffiti Generator | Transform into street graffiti art style |
| AI Polaroid Maker | Create vintage polaroid photo with frame |
| AI Bangs Filter | Add realistic bangs/fringe hairstyle |
| AI Beard Filter | Add realistic beard to face |
| AI Beard Remover | Remove beard while keeping natural face |
| Skin Color Changer | Adjust skin tone to {skin_tone} |
| Black & White Filter | Convert to classic black and white |
| Fisheye Filter | Apply fisheye lens distortion effect |
| AI Color Correction | Auto-correct colors and enhance photo |

## Work Estimate

| Task | Effort |
|------|--------|
| Write SQL migration with 25 templates | 2h |
| Generate 25 thumbnail images | 2h |
| Upload thumbnails to Supabase Storage | 0.5h |
| Test all templates E2E | 2h |
| **Total** | **6.5h** |

## Risks

| Risk | Mitigation |
|------|------------|
| Some prompts may not produce good results | Test each prompt, iterate |
| Thumbnail generation quality | Use best sample, regenerate if needed |
| Template ordering conflicts | Use explicit order field |

## Next Steps

1. ✅ Confirm template list and categories
2. ⏳ Generate thumbnail images for all 25
3. ⏳ Create Supabase migration file
4. ⏳ Test each template with Nano Banana
5. ⏳ Deploy migration to production
