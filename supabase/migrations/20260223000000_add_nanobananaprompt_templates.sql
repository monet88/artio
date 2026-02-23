-- Add 13 new templates from nanobananaprompt.org (cross-model: Nano Banana, Seedream, Flux-2)
-- Date: 2026-02-23
-- Note: All templates use {variable} interpolation mapped to input_fields
-- Note: is_active = false → set to true after manual QA test on device

-- ============================================================
-- PORTRAIT & FACE EFFECTS
-- ============================================================

INSERT INTO templates (id, name, description, thumbnail_url, category, prompt_template, input_fields, default_aspect_ratio, is_premium, is_active, "order")
VALUES (
  gen_random_uuid(),
  'Professional Headshot',
  'Transform your casual photo into a polished professional headshot for LinkedIn, CV, or work profile.',
  'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=512&h=512&fit=crop',
  'Portrait & Face Effects',
  'Professional corporate headshot of the person in the photo, clean {background_color} background, sharp focus on face, professional studio lighting with soft shadows, polished and confident look, photorealistic, 8K ultra-detailed',
  '[
    {"name": "image", "type": "image", "label": "Upload your photo", "required": true},
    {"name": "background_color", "type": "select", "label": "Background Color", "options": ["white", "light gray", "navy blue", "dark charcoal", "soft beige"], "required": true}
  ]'::jsonb,
  '3:4',
  false,
  true,
  30
);

INSERT INTO templates (id, name, description, thumbnail_url, category, prompt_template, input_fields, default_aspect_ratio, is_premium, is_active, "order")
VALUES (
  gen_random_uuid(),
  'Age Transformation',
  'See yourself at a different age — younger or older with realistic results.',
  'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=512&h=512&fit=crop',
  'Portrait & Face Effects',
  'Realistically transform the person in the photo to appear {age_target}, maintain same identity and facial structure, natural aging or de-aging effects, preserve bone structure and hair style adapted to age, photorealistic portrait, cinematic soft lighting, high quality',
  '[
    {"name": "image", "type": "image", "label": "Upload your photo", "required": true},
    {"name": "age_target", "type": "select", "label": "Transform to Age", "options": ["20 years old", "30 years old", "50 years old", "65 years old", "80 years old"], "required": true}
  ]'::jsonb,
  '3:4',
  false,
  true,
  31
);

INSERT INTO templates (id, name, description, thumbnail_url, category, prompt_template, input_fields, default_aspect_ratio, is_premium, is_active, "order")
VALUES (
  gen_random_uuid(),
  'Outfit Changer',
  'Dress yourself in any style — business, traditional, fantasy, or streetwear.',
  'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=512&h=512&fit=crop',
  'Portrait & Face Effects',
  'Keep the face and identity of the person exactly the same, change their outfit to {outfit_style} clothing, {outfit_color} color palette, realistic fabric textures with natural folds, matching lighting, photorealistic full portrait, high quality, ultra-detailed',
  '[
    {"name": "image", "type": "image", "label": "Upload your photo", "required": true},
    {"name": "outfit_style", "type": "select", "label": "Outfit Style", "options": ["formal business suit", "casual streetwear", "traditional Vietnamese ao dai", "Korean hanbok", "fantasy warrior armor", "cyberpunk jacket", "elegant evening gown", "school uniform"], "required": true},
    {"name": "outfit_color", "type": "select", "label": "Primary Color", "options": ["black", "white", "red", "navy blue", "gold", "emerald green", "burgundy"], "required": false}
  ]'::jsonb,
  '3:4',
  false,
  true,
  32
);

-- ============================================================
-- ART STYLE TRANSFER
-- ============================================================

INSERT INTO templates (id, name, description, thumbnail_url, category, prompt_template, input_fields, default_aspect_ratio, is_premium, is_active, "order")
VALUES (
  gen_random_uuid(),
  'Ghibli Anime Style',
  'Transform your photo into magical Studio Ghibli anime art with soft watercolors and hand-drawn aesthetic.',
  'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=512&h=512&fit=crop',
  'Art Style Transfer',
  'Studio Ghibli anime art style illustration, transform the person in the photo into a Ghibli character, soft watercolor tones, hand-drawn aesthetic with clean lines, expressive large eyes, warm nostalgic color palette, {background} detailed background with magical Ghibli elements, high quality animation art, cinematic composition',
  '[
    {"name": "image", "type": "image", "label": "Upload your photo", "required": true},
    {"name": "background", "type": "select", "label": "Background Setting", "options": ["enchanted forest with glowing fireflies", "countryside meadow at golden hour", "floating castle in clouds", "peaceful seaside village", "magical library with floating books", "rainy urban street with paper umbrellas"], "required": false}
  ]'::jsonb,
  '3:4',
  false,
  true,
  40
);

INSERT INTO templates (id, name, description, thumbnail_url, category, prompt_template, input_fields, default_aspect_ratio, is_premium, is_active, "order")
VALUES (
  gen_random_uuid(),
  'Oil Painting Portrait',
  'Turn your photo into a museum-quality oil painting masterpiece.',
  'https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?w=512&h=512&fit=crop',
  'Art Style Transfer',
  'Transform into a museum-quality oil painting portrait in the style of {painting_style}, rich deep colors with visible thick impasto brushstrokes, dramatic chiaroscuro lighting with deep shadows, classical fine art masterpiece composition, textured canvas background, fine art gallery quality',
  '[
    {"name": "image", "type": "image", "label": "Upload your photo", "required": true},
    {"name": "painting_style", "type": "select", "label": "Painting Style", "options": ["Rembrandt Dutch Golden Age", "Van Gogh Post-Impressionist", "Vermeer subtle lighting", "Monet Impressionist soft", "Da Vinci Renaissance realism", "Caravaggio dramatic baroque"], "required": true}
  ]'::jsonb,
  '3:4',
  false,
  true,
  41
);

INSERT INTO templates (id, name, description, thumbnail_url, category, prompt_template, input_fields, default_aspect_ratio, is_premium, is_active, "order")
VALUES (
  gen_random_uuid(),
  'Pencil Sketch',
  'Convert your photo into a realistic hand-drawn pencil sketch with fine detail.',
  'https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=512&h=512&fit=crop',
  'Art Style Transfer',
  'Convert the photo into a detailed {sketch_style} pencil sketch drawing, realistic graphite shading with crosshatching technique, white paper background with subtle texture, fine hand-drawn line work, clean artistic aesthetic, fine art quality pencil work, ultra-detailed',
  '[
    {"name": "image", "type": "image", "label": "Upload your photo", "required": true},
    {"name": "sketch_style", "type": "select", "label": "Sketch Style", "options": ["detailed realistic graphite", "loose gestural charcoal", "technical architectural", "soft smudged charcoal", "comic book ink style"], "required": true}
  ]'::jsonb,
  '3:4',
  false,
  true,
  42
);

-- ============================================================
-- CREATIVE & FUN
-- ============================================================

INSERT INTO templates (id, name, description, thumbnail_url, category, prompt_template, input_fields, default_aspect_ratio, is_premium, is_active, "order")
VALUES (
  gen_random_uuid(),
  'Vintage Polaroid',
  'Transform your photo into an authentic vintage Polaroid instant photo with nostalgic film aesthetics.',
  'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=512&h=512&fit=crop',
  'Creative & Fun',
  'Transform into an authentic vintage Polaroid instant photo from the {era}, classic thick white Polaroid border frame, aged film grain texture with light leaks, faded warm color tones, slight overexposure and soft vignette edges, nostalgic instant photography look, analog film aesthetic, photorealistic',
  '[
    {"name": "image", "type": "image", "label": "Upload your photo", "required": true},
    {"name": "era", "type": "select", "label": "Film Era", "options": ["1970s warm golden", "1980s faded colors", "1990s slightly desaturated"], "required": false}
  ]'::jsonb,
  '1:1',
  false,
  true,
  50
);

INSERT INTO templates (id, name, description, thumbnail_url, category, prompt_template, input_fields, default_aspect_ratio, is_premium, is_active, "order")
VALUES (
  gen_random_uuid(),
  '3D Chibi Figurine',
  'Turn yourself into an adorable 3D chibi collectible toy figurine.',
  'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=512&h=512&fit=crop',
  'Creative & Fun',
  'Transform the person into a high-quality 3D chibi collectible figurine, oversized round head with big expressive eyes, small cute compact body, {material} material finish, vibrant accurate colors matching original outfit, displayed on clean product base, studio product photography with soft even lighting, white background, collector grade quality, ultra-detailed 3D render',
  '[
    {"name": "image", "type": "image", "label": "Upload your photo", "required": true},
    {"name": "material", "type": "select", "label": "Figurine Material", "options": ["shiny PVC vinyl toy", "matte resin collectible", "soft plush fabric toy", "glossy ceramic figure", "metallic painted figure"], "required": true}
  ]'::jsonb,
  '3:4',
  false,
  true,
  51
);

INSERT INTO templates (id, name, description, thumbnail_url, category, prompt_template, input_fields, default_aspect_ratio, is_premium, is_active, "order")
VALUES (
  gen_random_uuid(),
  'Superhero Action Figure',
  'Become a superhero in an epic collectible action figure package.',
  'https://images.unsplash.com/photo-1601645191163-3fc0d5d64e35?w=512&h=512&fit=crop',
  'Creative & Fun',
  'Turn this person into a superhero action figure with {hero_power} themed costume and powers, dynamic heroic pose with dramatic energy effects, detailed muscular proportions with metallic and fabric texture, displayed in a collector box with dramatic comic book art graphics and bold typography, product photography on white background, ultra-detailed, high quality',
  '[
    {"name": "image", "type": "image", "label": "Upload your photo", "required": true},
    {"name": "hero_power", "type": "select", "label": "Superpower Theme", "options": ["fire and flames", "ice and frost crystal", "electric lightning", "shadow dark ninja", "cosmic space", "nature earth green", "water ocean", "wind storm"], "required": true}
  ]'::jsonb,
  '3:4',
  false,
  true,
  52
);

INSERT INTO templates (id, name, description, thumbnail_url, category, prompt_template, input_fields, default_aspect_ratio, is_premium, is_active, "order")
VALUES (
  gen_random_uuid(),
  'Fantasy RPG Character',
  'Transform yourself into an epic fantasy RPG game character with magical gear.',
  'https://images.unsplash.com/photo-1594736797933-d0501ba2fe65?w=512&h=512&fit=crop',
  'Creative & Fun',
  'Transform the person into a detailed fantasy RPG {character_class} character, elaborate {armor_style} armor and magical accessories, heroic pose with magical energy effects, placed on a mystical base with glowing runes and fantasy landscape elements, cinematic game art style, ultra-detailed, dramatic lighting, high quality',
  '[
    {"name": "image", "type": "image", "label": "Upload your photo", "required": true},
    {"name": "character_class", "type": "select", "label": "Character Class", "options": ["Warrior", "Mage", "Archer", "Paladin", "Rogue Shadow", "Druid Nature"], "required": true},
    {"name": "armor_style", "type": "select", "label": "Armor Style", "options": ["dark gothic plate", "golden royal plate", "mystical ancient robe", "leather ranger", "crystal enchanted", "dragon scale"], "required": false}
  ]'::jsonb,
  '3:4',
  false,
  true,
  53
);

-- ============================================================
-- PHOTO ENHANCEMENT
-- ============================================================

INSERT INTO templates (id, name, description, thumbnail_url, category, prompt_template, input_fields, default_aspect_ratio, is_premium, is_active, "order")
VALUES (
  gen_random_uuid(),
  'Photo Colorizer',
  'Bring black & white or faded photos back to life with natural, realistic colors.',
  'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=512&h=512&fit=crop',
  'Photo Enhancement',
  'Colorize this black and white photo with natural realistic colors, accurate skin tones for the historical period, period-appropriate clothing and environment colors, photorealistic color restoration preserving all original textures and details, high quality result, cinematic color grading',
  '[
    {"name": "image", "type": "image", "label": "Upload black & white photo", "required": true}
  ]'::jsonb,
  '1:1',
  false,
  true,
  60
);

INSERT INTO templates (id, name, description, thumbnail_url, category, prompt_template, input_fields, default_aspect_ratio, is_premium, is_active, "order")
VALUES (
  gen_random_uuid(),
  'Product Studio Shot',
  'Turn casual product photos into professional e-commerce studio quality shots.',
  'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=512&h=512&fit=crop',
  'Photo Enhancement',
  'Professional {shot_style} product photography of the item in the photo, clean {background_type} background, dramatic studio lighting with soft product shadows, sharp focus on all product details, commercial advertising quality, high resolution photorealistic e-commerce product shot',
  '[
    {"name": "image", "type": "image", "label": "Upload your product photo", "required": true},
    {"name": "shot_style", "type": "select", "label": "Shot Style", "options": ["minimalist white studio", "luxury dark dramatic", "lifestyle natural context", "colorful gradient", "wooden surface lifestyle"], "required": true},
    {"name": "background_type", "type": "select", "label": "Background", "options": ["pure white seamless", "soft gradient pastel", "dark dramatic black", "marble luxury texture", "natural wood surface"], "required": false}
  ]'::jsonb,
  '1:1',
  false,
  true,
  61
);

-- ============================================================
-- REMOVAL & EDITING
-- ============================================================

INSERT INTO templates (id, name, description, thumbnail_url, category, prompt_template, input_fields, default_aspect_ratio, is_premium, is_active, "order")
VALUES (
  gen_random_uuid(),
  'Background Changer',
  'Replace your photo background with any scene while keeping you perfectly separated.',
  'https://images.unsplash.com/photo-1480714378408-67cf0d13bc1b?w=512&h=512&fit=crop',
  'Removal & Editing',
  'Keep the person in the photo exactly as they are with perfect edge separation, replace only the background with {new_background} scene, realistic lighting match between person and new background, photorealistic seamless composite, natural shadows and ambient light integration, high quality',
  '[
    {"name": "image", "type": "image", "label": "Upload your photo", "required": true},
    {"name": "new_background", "type": "select", "label": "New Background", "options": ["Tokyo city skyline at night with neon lights", "Paris Eiffel Tower at sunset golden hour", "tropical white sand beach paradise", "modern minimal white office interior", "cherry blossom park in spring", "New York Times Square busy streets", "snowy Alpine mountain peak", "cozy cafe interior with warm lighting", "luxury hotel rooftop pool"], "required": true}
  ]'::jsonb,
  '3:4',
  false,
  true,
  70
);
