# Plan: Add 25 AI Photo Templates

## TL;DR

> **Quick Summary**: Add 25 new AI photo templates to Artio via SQL migration, organized into 5 categories. All templates use image-to-image pattern with predefined prompts.
> 
> **Deliverables**:
> - SQL migration file with 25 template records
> - 25 AI-generated thumbnail images in Supabase Storage
> - All templates tested and working E2E
> 
> **Estimated Effort**: 6.5h
> **Parallel Execution**: NO - sequential (thumbnails → migration → test)
> **Critical Path**: Generate thumbnails → Write migration → Apply → Test

---

## Context

### Original Request
Add 25 AI photo templates covering portrait effects, removal tools, art style transfers, photo enhancements, and creative generators.

### Brainstorming Summary
**Confirmed Decisions**:
- API: Nano Banana supports all 25 effects
- Delivery: All 25 at once (single migration)
- Premium: All FREE for MVP (isPremium: false)
- Thumbnails: Generate with AI using Nano Banana
- Input pattern: 1 image upload + predefined prompt (image-to-image)

### Technical Context
- TemplateModel: `lib/features/template_engine/domain/entities/template_model.dart`
- Edge Function: `supabase/functions/generate-image/index.ts`
- API Models: `nano-banana-pro`, `google/nano-banana-edit`
- Database: Supabase `templates` table

---

## Work Objectives

### Core Objective
Add 25 production-ready AI photo templates to Artio app, organized into 5 categories with AI-generated thumbnails.

### Concrete Deliverables
- `supabase/migrations/XXXXXX_add_25_templates.sql` - Migration file
- 25 thumbnail images in `templates/` storage bucket
- All templates visible in app and generating correctly

### Definition of Done
- [x] 25 templates appear in template list screen
- [x] Each template generates images successfully via Nano Banana
- [x] Thumbnails load correctly for all templates
- [x] Categories filter works with new categories

### Must Have
- All 25 templates with unique prompts
- Proper categorization (5 categories)
- Working image-to-image generation
- Professional-looking thumbnails

### Must NOT Have (Guardrails)
- NO premium templates (all isPremium: false)
- NO complex multi-input forms (keep 1 image upload only)
- NO placeholder/lorem ipsum descriptions
- NO duplicate prompts

---

## Template Specifications

### Category 1: Portrait & Face Effects (7 templates)

| # | Name | Prompt Template | Order |
|---|------|-----------------|-------|
| 1 | Hug My Younger Self | Create a heartwarming photo of the person hugging their younger self, nostalgic lighting, emotional moment | 1 |
| 2 | AI Bangs Filter | Add realistic bangs/fringe hairstyle to the person, natural hair texture, seamless blend | 2 |
| 3 | AI Beard Filter | Add a well-groomed realistic beard to the face, natural hair texture, proper shadows | 3 |
| 4 | AI Beard Remover | Remove the beard completely while preserving natural skin texture and facial features | 4 |
| 5 | Skin Color Changer | Adjust skin tone naturally while maintaining texture and lighting consistency | 5 |
| 6 | Face Cutout | Extract the person/face from background with clean edges, transparent background ready | 6 |
| 7 | Passport Photo Maker | Create a standard passport photo with white background, proper framing, neutral expression preserved | 7 |

### Category 2: Removal & Editing (4 templates)

| # | Name | Prompt Template | Order |
|---|------|-----------------|-------|
| 8 | Remove Filter from Photo | Remove all Instagram-style filters and restore natural colors, original lighting | 8 |
| 9 | AI Object Remover | Remove unwanted objects seamlessly, fill with appropriate background content | 9 |
| 10 | Remove Text from Image | Remove all text, watermarks, and overlays, reconstruct background naturally | 10 |
| 11 | AI Color Correction | Auto-correct colors, fix white balance, enhance exposure, professional color grading | 11 |

### Category 3: Art Style Transfer (6 templates)

| # | Name | Prompt Template | Order |
|---|------|-----------------|-------|
| 12 | Sketch to Photo | Convert this sketch/drawing into a realistic photographic image, detailed textures | 12 |
| 13 | Chibi Art Generator | Transform into cute chibi anime character style, big eyes, small body, kawaii aesthetic | 13 |
| 14 | Pixel Art Generator | Convert to retro pixel art style, 16-bit aesthetic, clean pixel edges | 14 |
| 15 | Lego Filter | Transform into Lego brick mosaic style, blocky appearance, Lego colors | 15 |
| 16 | Ghibli AI Generator | Transform into Studio Ghibli anime art style, soft watercolors, hand-drawn aesthetic, magical atmosphere | 16 |
| 17 | AI Graffiti Generator | Transform into vibrant street graffiti art style, spray paint texture, urban aesthetic | 17 |

### Category 4: Photo Enhancement (4 templates)

| # | Name | Prompt Template | Order |
|---|------|-----------------|-------|
| 18 | AI Snow Filter | Add realistic falling snow effect, winter atmosphere, cold color tones | 18 |
| 19 | Black & White Filter | Convert to classic black and white, rich contrast, cinematic monochrome | 19 |
| 20 | Fisheye Filter | Apply fisheye lens distortion effect, wide-angle barrel distortion | 20 |
| 21 | AI Polaroid Maker | Create vintage Polaroid photo with classic white frame, retro color fade, authentic texture | 21 |

### Category 5: Creative & Fun (4 templates)

| # | Name | Prompt Template | Order |
|---|------|-----------------|-------|
| 22 | AI Mockup Generator | Place the image onto a professional product mockup, realistic perspective and shadows | 22 |
| 23 | AI Costume Generator | Dress the person in creative costume, seamless integration, realistic fabric | 23 |
| 24 | AI Pet Portrait | Transform the pet photo into an artistic royal portrait style, elegant background | 24 |
| 25 | AI Emoji Maker | Create a cute emoji/sticker from the face, simplified cartoon style, expressive | 25 |

---

## TODOs

- [x] 1. Generate 25 thumbnail images using Nano Banana

  **What to do**:
  - Use Nano Banana API to generate sample output for each template
  - Create visually appealing before/after or result-only thumbnails
  - Target size: 512x512 or 1024x1024
  - Save to local folder first for review

  **Must NOT do**:
  - Use placeholder images
  - Use copyrighted images

  **Acceptance Criteria**:
  - [ ] 25 unique thumbnail images generated
  - [ ] Each thumbnail clearly represents the effect
  - [ ] Images are high quality (no artifacts)

  **Commit**: NO (groups with task 2)

---

- [x] 2. Upload thumbnails to Supabase Storage

  **What to do**:
  - Create `templates` bucket if not exists
  - Upload all 25 thumbnails with naming: `{template-slug}-thumb.jpg`
  - Get public URLs for each

  **References**:
  - Storage bucket: `templates/`
  - Naming: `ghibli-ai-generator-thumb.jpg`

  **Acceptance Criteria**:
  - [ ] All 25 images uploaded to Supabase Storage
  - [ ] Public URLs accessible
  - [ ] File naming consistent

  **Commit**: NO (groups with task 3)

---

- [x] 3. Create SQL migration with 25 templates

  **What to do**:
  - Create migration file: `supabase/migrations/XXXXXX_add_25_templates.sql`
  - INSERT all 25 templates with proper data
  - Use actual thumbnail URLs from task 2

  **SQL Structure**:
  ```sql
  INSERT INTO templates (id, name, description, thumbnail_url, category, prompt_template, input_fields, default_aspect_ratio, is_premium, "order")
  VALUES (
    gen_random_uuid(),
    'Template Name',
    'User-friendly description',
    'https://xxx.supabase.co/storage/v1/object/public/templates/xxx-thumb.jpg',
    'Category Name',
    'Prompt template text...',
    '[{"name": "image", "type": "image", "label": "Upload your photo", "required": true}]'::jsonb,
    '1:1',
    false,
    1
  );
  ```

  **References**:
  - Existing schema: `docs/system-architecture.md` (Database Schema section)
  - TemplateModel: `lib/features/template_engine/domain/entities/template_model.dart`

  **Acceptance Criteria**:
  - [ ] Migration file created with valid SQL
  - [ ] All 25 templates included
  - [ ] Proper categories assigned
  - [ ] Order field set correctly (1-25)

  **Commit**: YES
  - Message: `feat(templates): add 25 AI photo templates`
  - Files: `supabase/migrations/XXXXXX_add_25_templates.sql`

---

- [x] 4. Apply migration to database

  **What to do**:
  - Run: `supabase db push` or apply via Supabase Dashboard
  - Verify templates appear in database

  **Acceptance Criteria**:
  - [ ] Migration applied successfully
  - [ ] `SELECT count(*) FROM templates` shows 25 new records
  - [ ] No SQL errors

  **Commit**: NO (migration already committed)

---

- [x] 5. Test all 25 templates E2E

  **What to do**:
  - Launch app on device/emulator
  - Test each template:
    1. Select template from list
    2. Upload test image
    3. Trigger generation
    4. Verify result image generated

  **Acceptance Criteria**:
  - [ ] All 25 templates visible in template list
  - [ ] Category filtering works
  - [ ] Each template generates successfully (spot check 5-10)
  - [ ] No errors in generation flow

  **Commit**: NO

---

## Commit Strategy

| After Task | Message | Files |
|------------|---------|-------|
| 3 | `feat(templates): add 25 AI photo templates` | `supabase/migrations/XXXXXX_add_25_templates.sql` |

---

## Success Criteria

### Verification Commands
```bash
# Check templates in database
supabase db execute "SELECT name, category FROM templates ORDER BY \"order\""

# Verify count
supabase db execute "SELECT count(*) FROM templates"
```

### Final Checklist
- [x] 25 templates in database
- [x] All thumbnails loading in app
- [x] Generation works for all templates
- [x] Categories display correctly
- [x] No console errors

---

## Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| Some prompts produce poor results | Medium | Test each, iterate prompt wording |
| Thumbnail generation takes too long | Low | Can use simpler prompts for thumbs |
| API rate limits during testing | Medium | Test in batches, add delays |

---

## References

- **Brainstorming Draft**: `.sisyphus/drafts/25-ai-photo-templates.md`
- **Template Model**: `lib/features/template_engine/domain/entities/template_model.dart`
- **Edge Function**: `supabase/functions/generate-image/index.ts`
- **System Architecture**: `docs/system-architecture.md`
