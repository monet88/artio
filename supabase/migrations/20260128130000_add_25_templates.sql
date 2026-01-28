-- Insert 25 AI photo templates

INSERT INTO templates (id, name, description, thumbnail_url, category, prompt_template, input_fields, default_aspect_ratio, is_premium, "order")
VALUES (
  gen_random_uuid(),
  'Hug My Younger Self',
  'Create a nostalgic portrait of you embracing your younger self with warm, emotional lighting.',
  'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=512&h=512&fit=crop',
  'Portrait & Face Effects',
  'Create a heartwarming photo of the person hugging their younger self, nostalgic lighting, emotional moment',
  '[{"name": "image", "type": "image", "label": "Upload your photo", "required": true}]'::jsonb,
  '1:1',
  false,
  1
);

INSERT INTO templates (id, name, description, thumbnail_url, category, prompt_template, input_fields, default_aspect_ratio, is_premium, "order")
VALUES (
  gen_random_uuid(),
  'AI Bangs Filter',
  'Add natural-looking bangs that blend with your hairstyle and lighting.',
  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=512&h=512&fit=crop',
  'Portrait & Face Effects',
  'Add realistic bangs/fringe hairstyle to the person, natural hair texture, seamless blend',
  '[{"name": "image", "type": "image", "label": "Upload your photo", "required": true}]'::jsonb,
  '1:1',
  false,
  2
);

INSERT INTO templates (id, name, description, thumbnail_url, category, prompt_template, input_fields, default_aspect_ratio, is_premium, "order")
VALUES (
  gen_random_uuid(),
  'AI Beard Filter',
  'Add a groomed, realistic beard with natural texture and shadows.',
  'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=512&h=512&fit=crop',
  'Portrait & Face Effects',
  'Add a well-groomed realistic beard to the face, natural hair texture, proper shadows',
  '[{"name": "image", "type": "image", "label": "Upload your photo", "required": true}]'::jsonb,
  '1:1',
  false,
  3
);

INSERT INTO templates (id, name, description, thumbnail_url, category, prompt_template, input_fields, default_aspect_ratio, is_premium, "order")
VALUES (
  gen_random_uuid(),
  'AI Beard Remover',
  'Remove facial hair while keeping skin texture and facial details intact.',
  'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=512&h=512&fit=crop',
  'Portrait & Face Effects',
  'Remove the beard completely while preserving natural skin texture and facial features',
  '[{"name": "image", "type": "image", "label": "Upload your photo", "required": true}]'::jsonb,
  '1:1',
  false,
  4
);

INSERT INTO templates (id, name, description, thumbnail_url, category, prompt_template, input_fields, default_aspect_ratio, is_premium, "order")
VALUES (
  gen_random_uuid(),
  'Skin Color Changer',
  'Adjust skin tone naturally while preserving texture and light consistency.',
  'https://images.unsplash.com/photo-1506795660198-e95c77602129?w=512&h=512&fit=crop',
  'Portrait & Face Effects',
  'Adjust skin tone naturally while maintaining texture and lighting consistency',
  '[{"name": "image", "type": "image", "label": "Upload your photo", "required": true}]'::jsonb,
  '1:1',
  false,
  5
);

INSERT INTO templates (id, name, description, thumbnail_url, category, prompt_template, input_fields, default_aspect_ratio, is_premium, "order")
VALUES (
  gen_random_uuid(),
  'Face Cutout',
  'Cut out the face or person with crisp edges and a transparent background.',
  'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?w=512&h=512&fit=crop',
  'Portrait & Face Effects',
  'Extract the person/face from background with clean edges, transparent background ready',
  '[{"name": "image", "type": "image", "label": "Upload your photo", "required": true}]'::jsonb,
  '1:1',
  false,
  6
);

INSERT INTO templates (id, name, description, thumbnail_url, category, prompt_template, input_fields, default_aspect_ratio, is_premium, "order")
VALUES (
  gen_random_uuid(),
  'Passport Photo Maker',
  'Generate a clean passport-style portrait with white background and correct framing.',
  'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=512&h=512&fit=crop',
  'Portrait & Face Effects',
  'Create a standard passport photo with white background, proper framing, neutral expression preserved',
  '[{"name": "image", "type": "image", "label": "Upload your photo", "required": true}]'::jsonb,
  '1:1',
  false,
  7
);

INSERT INTO templates (id, name, description, thumbnail_url, category, prompt_template, input_fields, default_aspect_ratio, is_premium, "order")
VALUES (
  gen_random_uuid(),
  'Remove Filter from Photo',
  'Restore natural colors and lighting by removing heavy filters.',
  'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=512&h=512&fit=crop',
  'Removal & Editing',
  'Remove all Instagram-style filters and restore natural colors, original lighting',
  '[{"name": "image", "type": "image", "label": "Upload your photo", "required": true}]'::jsonb,
  '1:1',
  false,
  8
);

INSERT INTO templates (id, name, description, thumbnail_url, category, prompt_template, input_fields, default_aspect_ratio, is_premium, "order")
VALUES (
  gen_random_uuid(),
  'AI Object Remover',
  'Erase unwanted objects and reconstruct the background seamlessly.',
  'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=512&h=512&fit=crop',
  'Removal & Editing',
  'Remove unwanted objects seamlessly, fill with appropriate background content',
  '[{"name": "image", "type": "image", "label": "Upload your photo", "required": true}]'::jsonb,
  '1:1',
  false,
  9
);

INSERT INTO templates (id, name, description, thumbnail_url, category, prompt_template, input_fields, default_aspect_ratio, is_premium, "order")
VALUES (
  gen_random_uuid(),
  'Remove Text from Image',
  'Remove text, watermarks, and overlays while rebuilding the background.',
  'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=512&h=512&fit=crop',
  'Removal & Editing',
  'Remove all text, watermarks, and overlays, reconstruct background naturally',
  '[{"name": "image", "type": "image", "label": "Upload your photo", "required": true}]'::jsonb,
  '1:1',
  false,
  10
);

INSERT INTO templates (id, name, description, thumbnail_url, category, prompt_template, input_fields, default_aspect_ratio, is_premium, "order")
VALUES (
  gen_random_uuid(),
  'AI Color Correction',
  'Auto-correct colors, balance white levels, and improve exposure.',
  'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=512&h=512&fit=crop',
  'Removal & Editing',
  'Auto-correct colors, fix white balance, enhance exposure, professional color grading',
  '[{"name": "image", "type": "image", "label": "Upload your photo", "required": true}]'::jsonb,
  '1:1',
  false,
  11
);

INSERT INTO templates (id, name, description, thumbnail_url, category, prompt_template, input_fields, default_aspect_ratio, is_premium, "order")
VALUES (
  gen_random_uuid(),
  'Sketch to Photo',
  'Turn a drawing into a realistic photo with detailed textures.',
  'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=512&h=512&fit=crop',
  'Art Style Transfer',
  'Convert this sketch/drawing into a realistic photographic image, detailed textures',
  '[{"name": "image", "type": "image", "label": "Upload your photo", "required": true}]'::jsonb,
  '1:1',
  false,
  12
);

INSERT INTO templates (id, name, description, thumbnail_url, category, prompt_template, input_fields, default_aspect_ratio, is_premium, "order")
VALUES (
  gen_random_uuid(),
  'Chibi Art Generator',
  'Transform your photo into a cute chibi character with a kawaii look.',
  'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=512&h=512&fit=crop',
  'Art Style Transfer',
  'Transform into cute chibi anime character style, big eyes, small body, kawaii aesthetic',
  '[{"name": "image", "type": "image", "label": "Upload your photo", "required": true}]'::jsonb,
  '1:1',
  false,
  13
);

INSERT INTO templates (id, name, description, thumbnail_url, category, prompt_template, input_fields, default_aspect_ratio, is_premium, "order")
VALUES (
  gen_random_uuid(),
  'Pixel Art Generator',
  'Convert your image to crisp 16-bit pixel art.',
  'https://images.unsplash.com/photo-1518770660439-4636190af475?w=512&h=512&fit=crop',
  'Art Style Transfer',
  'Convert to retro pixel art style, 16-bit aesthetic, clean pixel edges',
  '[{"name": "image", "type": "image", "label": "Upload your photo", "required": true}]'::jsonb,
  '1:1',
  false,
  14
);

INSERT INTO templates (id, name, description, thumbnail_url, category, prompt_template, input_fields, default_aspect_ratio, is_premium, "order")
VALUES (
  gen_random_uuid(),
  'Lego Filter',
  'Transform your image into a Lego-style brick mosaic.',
  'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?w=512&h=512&fit=crop',
  'Art Style Transfer',
  'Transform into Lego brick mosaic style, blocky appearance, Lego colors',
  '[{"name": "image", "type": "image", "label": "Upload your photo", "required": true}]'::jsonb,
  '1:1',
  false,
  15
);

INSERT INTO templates (id, name, description, thumbnail_url, category, prompt_template, input_fields, default_aspect_ratio, is_premium, "order")
VALUES (
  gen_random_uuid(),
  'Ghibli AI Generator',
  'Create a soft, hand-drawn anime look with a magical atmosphere.',
  'https://images.unsplash.com/photo-1471879832106-c7ab9e0cee23?w=512&h=512&fit=crop',
  'Art Style Transfer',
  'Transform into Studio Ghibli anime art style, soft watercolors, hand-drawn aesthetic, magical atmosphere',
  '[{"name": "image", "type": "image", "label": "Upload your photo", "required": true}]'::jsonb,
  '1:1',
  false,
  16
);

INSERT INTO templates (id, name, description, thumbnail_url, category, prompt_template, input_fields, default_aspect_ratio, is_premium, "order")
VALUES (
  gen_random_uuid(),
  'AI Graffiti Generator',
  'Convert your photo into vibrant street graffiti art.',
  'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?w=512&h=512&fit=crop',
  'Art Style Transfer',
  'Transform into vibrant street graffiti art style, spray paint texture, urban aesthetic',
  '[{"name": "image", "type": "image", "label": "Upload your photo", "required": true}]'::jsonb,
  '1:1',
  false,
  17
);

INSERT INTO templates (id, name, description, thumbnail_url, category, prompt_template, input_fields, default_aspect_ratio, is_premium, "order")
VALUES (
  gen_random_uuid(),
  'AI Snow Filter',
  'Add realistic falling snow for a cold, wintery mood.',
  'https://images.unsplash.com/photo-1482192596544-9eb780fc7f66?w=512&h=512&fit=crop',
  'Photo Enhancement',
  'Add realistic falling snow effect, winter atmosphere, cold color tones',
  '[{"name": "image", "type": "image", "label": "Upload your photo", "required": true}]'::jsonb,
  '1:1',
  false,
  18
);

INSERT INTO templates (id, name, description, thumbnail_url, category, prompt_template, input_fields, default_aspect_ratio, is_premium, "order")
VALUES (
  gen_random_uuid(),
  'Black & White Filter',
  'Convert to classic monochrome with rich, cinematic contrast.',
  'https://images.unsplash.com/photo-1452587925148-ce544e77e70d?w=512&h=512&fit=crop',
  'Photo Enhancement',
  'Convert to classic black and white, rich contrast, cinematic monochrome',
  '[{"name": "image", "type": "image", "label": "Upload your photo", "required": true}]'::jsonb,
  '1:1',
  false,
  19
);

INSERT INTO templates (id, name, description, thumbnail_url, category, prompt_template, input_fields, default_aspect_ratio, is_premium, "order")
VALUES (
  gen_random_uuid(),
  'Fisheye Filter',
  'Apply a wide-angle fisheye distortion for a dramatic look.',
  'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=512&h=512&fit=crop',
  'Photo Enhancement',
  'Apply fisheye lens distortion effect, wide-angle barrel distortion',
  '[{"name": "image", "type": "image", "label": "Upload your photo", "required": true}]'::jsonb,
  '1:1',
  false,
  20
);

INSERT INTO templates (id, name, description, thumbnail_url, category, prompt_template, input_fields, default_aspect_ratio, is_premium, "order")
VALUES (
  gen_random_uuid(),
  'AI Polaroid Maker',
  'Create a vintage Polaroid with a white frame and retro color fade.',
  'https://images.unsplash.com/photo-1458253329476-1ebb8593a652?w=512&h=512&fit=crop',
  'Photo Enhancement',
  'Create vintage Polaroid photo with classic white frame, retro color fade, authentic texture',
  '[{"name": "image", "type": "image", "label": "Upload your photo", "required": true}]'::jsonb,
  '1:1',
  false,
  21
);

INSERT INTO templates (id, name, description, thumbnail_url, category, prompt_template, input_fields, default_aspect_ratio, is_premium, "order")
VALUES (
  gen_random_uuid(),
  'AI Mockup Generator',
  'Place your image onto a realistic product mockup with proper lighting.',
  'https://images.unsplash.com/photo-1489515217757-5fd1be406fef?w=512&h=512&fit=crop',
  'Creative & Fun',
  'Place the image onto a professional product mockup, realistic perspective and shadows',
  '[{"name": "image", "type": "image", "label": "Upload your photo", "required": true}]'::jsonb,
  '1:1',
  false,
  22
);

INSERT INTO templates (id, name, description, thumbnail_url, category, prompt_template, input_fields, default_aspect_ratio, is_premium, "order")
VALUES (
  gen_random_uuid(),
  'AI Costume Generator',
  'Dress the subject in a creative costume with realistic fabric details.',
  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=512&h=512&fit=crop',
  'Creative & Fun',
  'Dress the person in creative costume, seamless integration, realistic fabric',
  '[{"name": "image", "type": "image", "label": "Upload your photo", "required": true}]'::jsonb,
  '1:1',
  false,
  23
);

INSERT INTO templates (id, name, description, thumbnail_url, category, prompt_template, input_fields, default_aspect_ratio, is_premium, "order")
VALUES (
  gen_random_uuid(),
  'AI Pet Portrait',
  'Turn a pet photo into a regal, artistic portrait with an elegant backdrop.',
  'https://images.unsplash.com/photo-1504208434309-cb69f4fe52b0?w=512&h=512&fit=crop',
  'Creative & Fun',
  'Transform the pet photo into an artistic royal portrait style, elegant background',
  '[{"name": "image", "type": "image", "label": "Upload your photo", "required": true}]'::jsonb,
  '1:1',
  false,
  24
);

INSERT INTO templates (id, name, description, thumbnail_url, category, prompt_template, input_fields, default_aspect_ratio, is_premium, "order")
VALUES (
  gen_random_uuid(),
  'AI Emoji Maker',
  'Create a cute, expressive emoji-style sticker from a face photo.',
  'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=512&h=512&fit=crop',
  'Creative & Fun',
  'Create a cute emoji/sticker from the face, simplified cartoon style, expressive',
  '[{"name": "image", "type": "image", "label": "Upload your photo", "required": true}]'::jsonb,
  '1:1',
  false,
  25
);
