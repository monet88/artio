# Gemini Image Generation (Nano Banana)

**Source**: [ai.google.dev/gemini-api/docs/image-generation](https://ai.google.dev/gemini-api/docs/image-generation)
**Updated**: 2026-02-28

Gemini's native image generation capabilities, branded as **Nano Banana**. Generates and processes images conversationally with text, images, or both.

## Models

| Brand Name | Model ID | Optimized For |
|---|---|---|
| **Nano Banana 2** | `gemini-3.1-flash-image-preview` | Speed, high-volume, best all-around |
| **Nano Banana Pro** | `gemini-3-pro-image-preview` | Professional assets, complex instructions, thinking |
| **Nano Banana** | `gemini-2.5-flash-image` | Speed/efficiency, low-latency |

All generated images include a [SynthID watermark](https://ai.google.dev/responsible/docs/safeguards/synthid).

---

## API Usage (JavaScript/TypeScript)

### Text-to-Image

```javascript
const response = await ai.models.generateContent({
  model: "gemini-3.1-flash-image-preview",
  contents: "Create a picture of a banana dish in a fancy restaurant",
});

for (const part of response.candidates[0].content.parts) {
  if (part.text) {
    console.log(part.text);
  } else if (part.inlineData) {
    const buffer = Buffer.from(part.inlineData.data, "base64");
    fs.writeFileSync("output.png", buffer);
  }
}
```

### Image Editing (Image + Text Input)

```javascript
const prompt = [
  { text: "Add a wizard hat on the cat" },
  {
    inlineData: {
      mimeType: "image/png",
      data: base64Image,
    },
  },
];

const response = await ai.models.generateContent({
  model: "gemini-3.1-flash-image-preview",
  contents: prompt,
});
```

---

## Gemini 3 Image Model Features

- **High-resolution output**: 512px (0.5K), 1K, 2K, and 4K generation
  - 512px only on Gemini 3.1 Flash Image
- **Advanced text rendering**: Legible, stylized text for infographics, menus, diagrams, marketing
- **Grounding with Google Search**: Use real-time data (weather, news, events) in generated images
  - Gemini 3.1 Flash Image adds **Image Search Grounding** alongside Web Search
- **Thinking mode**: Generates interim "thought images" to refine composition before final output (enabled by default, cannot be disabled)
- **Up to 14 reference images**: Mix multiple images for character consistency and object fidelity

### Reference Image Limits

| Gemini 3.1 Flash Image Preview | Gemini 3 Pro Image Preview |
|---|---|
| Up to 10 objects with high-fidelity | Up to 6 objects with high-fidelity |
| Up to 4 characters for consistency | Up to 5 characters for consistency |

### Google Search Grounding (JavaScript)

```javascript
const response = await ai.models.generateContent({
  model: "gemini-3.1-flash-image-preview",
  contents: "Visualize today's weather in San Francisco as a modern chart",
  config: {
    responseModalities: ["Text", "Image"],
    imageConfig: { aspectRatio: "16:9", imageSize: "2K" },
    tools: [{ googleSearch: {} }],
  },
});
```

### Image Search Grounding (3.1 Flash only)

```javascript
const response = await ai.models.generateContent({
  model: "gemini-3.1-flash-image-preview",
  contents: "A detailed painting of a Timareta butterfly on a flower",
  config: {
    responseModalities: ["IMAGE"],
    tools: [{
      googleSearch: {
        searchTypes: {
          webSearch: {},
          imageSearch: {},
        },
      },
    }],
  },
});
```

### Checking Thinking Output

```javascript
for (const part of response.candidates[0].content.parts) {
  if (part.thought) {
    if (part.text) console.log(part.text);
    else if (part.inlineData) { /* thought image */ }
  }
}
```

---

## Prompting Guide

> **Describe the scene, don't just list keywords.** A narrative, descriptive paragraph produces better, more coherent images than disconnected words.

### Generation Prompts

#### 1. Photorealistic Scenes

Use photography terms: camera angles, lens types, lighting, fine details.

**Template:**
```
A photorealistic [shot type] of [subject], [action or expression], set in
[environment]. Illuminated by [lighting description], creating a [mood]
atmosphere. Captured with [camera/lens details], emphasizing [key textures].
[aspect ratio] format.
```

**Example:**
```
A photorealistic close-up portrait of an elderly Japanese ceramicist with
deep, sun-etched wrinkles and a warm, knowing smile. He is carefully
inspecting a freshly glazed tea bowl. The setting is his rustic, sun-drenched
workshop. Illuminated by soft, golden hour light streaming through a window.
Captured with an 85mm portrait lens, soft bokeh background. Vertical portrait.
```

#### 2. Stylized Illustrations and Stickers

Be explicit about style. Request transparent/white background for assets.

**Template:**
```
A [style] sticker of a [subject], featuring [key characteristics] and a
[color palette]. The design should have [line style] and [shading style].
The background must be transparent.
```

**Example:**
```
A kawaii-style sticker of a happy red panda wearing a tiny bamboo hat. It's
munching on a green bamboo leaf. Bold, clean outlines, simple cel-shading,
vibrant color palette. White background.
```

#### 3. Accurate Text in Images

Clear about text content, font style, and design. Use Gemini 3 Pro for professional text.

**Template:**
```
Create a [image type] for [brand/concept] with the text "[text to render]"
in a [font style]. The design should be [style description], with a
[color scheme].
```

**Example:**
```
Create a modern, minimalist logo for a coffee shop called 'The Daily Grind'.
Clean, bold, sans-serif font. Black and white color scheme. Circle shape.
Use a coffee bean in a clever way.
```

#### 4. Product Mockups and Commercial Photography

**Template:**
```
A high-resolution, studio-lit product photograph of a [product description]
on a [background surface]. Lighting: [setup] to [purpose]. Camera angle:
[angle] to showcase [feature]. Ultra-realistic, sharp focus on [detail].
[Aspect ratio].
```

**Example:**
```
A high-resolution, studio-lit product photograph of a minimalist ceramic
coffee mug in matte black, on polished concrete. Three-point softbox setup,
soft diffused highlights. Slightly elevated 45-degree shot. Sharp focus on
steam rising from coffee. Square image.
```

#### 5. Minimalist and Negative Space Design

**Template:**
```
A minimalist composition featuring a single [subject] positioned in the
[position] of the frame. Background: vast, empty [color] canvas with
significant negative space. Soft, subtle lighting. [Aspect ratio].
```

#### 6. Sequential Art (Comic Panel / Storyboard)

**Template:**
```
Make a 3 panel comic in a [style]. Put the character in a [type of scene].
```

#### 7. Grounding with Google Search

```
Make a simple but stylish graphic of last night's Arsenal game in the
Champion's League
```

### Editing Prompts

#### 1. Adding and Removing Elements

**Template:**
```
Using the provided image of [subject], please [add/remove/modify] [element]
to/from the scene. Ensure the change [integration description].
```

#### 2. Inpainting (Semantic Masking)

**Template:**
```
Using the provided image, change only the [specific element] to [new
element]. Keep everything else exactly the same, preserving style,
lighting, and composition.
```

#### 3. Style Transfer

**Template:**
```
Transform the provided photograph of [subject] into the artistic style of
[artist/art style]. Preserve original composition but render with
[description of stylistic elements].
```

#### 4. Advanced Composition (Combining Multiple Images)

**Template:**
```
Create a new image by combining elements from the provided images. Take
[element from image 1] and place it with [element from image 2]. The final
image should be [description].
```

#### 5. High-Fidelity Detail Preservation

**Template:**
```
Using the provided images, place [element from image 2] onto [element from
image 1]. Ensure features of [element from image 1] remain completely
unchanged. The added element should [integration description].
```

#### 6. Bring Something to Life

**Template:**
```
Turn this rough [medium] sketch of a [subject] into a [style] photo. Keep
[specific features] from the sketch but add [new details/materials].
```

#### 7. Character Consistency (360 View)

**Template:**
```
A studio portrait of [person] against [background], [looking forward / in
profile looking right / etc.]
```

---

## Best Practices

- **Be Hyper-Specific:** Instead of "fantasy armor," describe: "ornate elven plate armor, etched with silver leaf patterns, high collar and falcon-wing pauldrons."
- **Provide Context and Intent:** Explain the purpose. "Create a logo for a high-end, minimalist skincare brand" beats "Create a logo."
- **Iterate and Refine:** Use conversational follow-ups: "That's great, but make the lighting warmer."
- **Use Step-by-Step Instructions:** For complex scenes, break into steps: "First, create background... Then, add... Finally, place..."
- **Use Semantic Negative Prompts:** Instead of "no cars," describe positively: "an empty, deserted street with no signs of traffic."
- **Control the Camera:** Use photographic/cinematic language: `wide-angle shot`, `macro shot`, `low-angle perspective`.

---

## Limitations

- Best performance in: EN, ar-EG, de-DE, es-MX, fr-FR, hi-IN, id-ID, it-IT, ja-JP, ko-KR, pt-BR, ru-RU, ua-UA, vi-VN, zh-CN
- No audio or video inputs
- Model won't always match exact requested number of image outputs
- `gemini-2.5-flash-image`: up to 3 input images; `gemini-3-pro-image-preview`: 5 high-fidelity + up to 14 total; `gemini-3.1-flash-image-preview`: 4 characters + 10 objects fidelity
- For best text generation: generate text first, then ask for image with the text

---

## Configuration

### Output Types

Default: text + image (`responseModalities: ['Text', 'Image']`). For image-only:

```javascript
const response = await ai.models.generateContent({
  model: "gemini-3.1-flash-image-preview",
  contents: prompt,
  config: { responseModalities: ["Image"] },
});
```

### Aspect Ratio and Image Size

```javascript
// gemini-2.5-flash-image (no imageSize option)
config: { imageConfig: { aspectRatio: "16:9" } }

// gemini-3.1-flash-image-preview / gemini-3-pro-image-preview
config: { imageConfig: { aspectRatio: "16:9", imageSize: "2K" } }
```

### Resolution Tables

#### Gemini 3.1 Flash Image Preview

| Ratio | 512px | 0.5K tokens | 1K | 1K tokens | 2K | 2K tokens | 4K | 4K tokens |
|---|---|---|---|---|---|---|---|---|
| 1:1 | 512x512 | 747 | 1024x1024 | 1120 | 2048x2048 | 1120 | 4096x4096 | 2000 |
| 1:4 | 256x1024 | 747 | 512x2048 | 1120 | 1024x4096 | 1120 | 2048x8192 | 2000 |
| 1:8 | 192x1536 | 747 | 384x3072 | 1120 | 768x6144 | 1120 | 1536x12288 | 2000 |
| 2:3 | 424x632 | 747 | 848x1264 | 1120 | 1696x2528 | 1120 | 3392x5056 | 2000 |
| 3:2 | 632x424 | 747 | 1264x848 | 1120 | 2528x1696 | 1120 | 5056x3392 | 2000 |
| 3:4 | 448x600 | 747 | 896x1200 | 1120 | 1792x2400 | 1120 | 3584x4800 | 2000 |
| 4:1 | 1024x256 | 747 | 2048x512 | 1120 | 4096x1024 | 1120 | 8192x2048 | 2000 |
| 4:3 | 600x448 | 747 | 1200x896 | 1120 | 2400x1792 | 1120 | 4800x3584 | 2000 |
| 4:5 | 464x576 | 747 | 928x1152 | 1120 | 1856x2304 | 1120 | 3712x4608 | 2000 |
| 5:4 | 576x464 | 747 | 1152x928 | 1120 | 2304x1856 | 1120 | 4608x3712 | 2000 |
| 8:1 | 1536x192 | 747 | 3072x384 | 1120 | 6144x768 | 1120 | 12288x1536 | 2000 |
| 9:16 | 384x688 | 747 | 768x1376 | 1120 | 1536x2752 | 1120 | 3072x5504 | 2000 |
| 16:9 | 688x384 | 747 | 1376x768 | 1120 | 2752x1536 | 1120 | 5504x3072 | 2000 |
| 21:9 | 792x168 | 747 | 1584x672 | 1120 | 3168x1344 | 1120 | 6336x2688 | 2000 |

#### Gemini 3 Pro Image Preview

| Ratio | 1K | 1K tokens | 2K | 2K tokens | 4K | 4K tokens |
|---|---|---|---|---|---|---|
| 1:1 | 1024x1024 | 1120 | 2048x2048 | 1120 | 4096x4096 | 2000 |
| 2:3 | 848x1264 | 1120 | 1696x2528 | 1120 | 3392x5056 | 2000 |
| 3:2 | 1264x848 | 1120 | 2528x1696 | 1120 | 5056x3392 | 2000 |
| 3:4 | 896x1200 | 1120 | 1792x2400 | 1120 | 3584x4800 | 2000 |
| 4:3 | 1200x896 | 1120 | 2400x1792 | 1120 | 4800x3584 | 2000 |
| 4:5 | 928x1152 | 1120 | 1856x2304 | 1120 | 3712x4608 | 2000 |
| 5:4 | 1152x928 | 1120 | 2304x1856 | 1120 | 4608x3712 | 2000 |
| 9:16 | 768x1376 | 1120 | 1536x2752 | 1120 | 3072x5504 | 2000 |
| 16:9 | 1376x768 | 1120 | 2752x1536 | 1120 | 5504x3072 | 2000 |
| 21:9 | 1584x672 | 1120 | 3168x1344 | 1120 | 6336x2688 | 2000 |

#### Gemini 2.5 Flash Image

| Ratio | Resolution | Tokens |
|---|---|---|
| 1:1 | 1024x1024 | 1290 |
| 2:3 | 832x1248 | 1290 |
| 3:2 | 1248x832 | 1290 |
| 3:4 | 864x1184 | 1290 |
| 4:3 | 1184x864 | 1290 |
| 4:5 | 896x1152 | 1290 |
| 5:4 | 1152x896 | 1290 |
| 9:16 | 768x1344 | 1290 |
| 16:9 | 1344x768 | 1290 |
| 21:9 | 1536x672 | 1290 |

---

## Model Selection

- **Gemini 3.1 Flash Image Preview (Nano Banana 2)** -- Go-to model. Best all-around performance-to-cost-to-latency balance. [Pricing](https://ai.google.dev/gemini-api/docs/pricing#gemini-3.1-flash-image-preview) | [Capabilities](https://ai.google.dev/gemini-api/docs/models/gemini-3.1-flash-image-preview)

- **Gemini 3 Pro Image Preview (Nano Banana Pro)** -- Professional asset production and complex instructions. Built-in "Thinking" process, Google Search grounding, up to 4K. [Pricing](https://ai.google.dev/gemini-api/docs/pricing#gemini-3-pro-image-preview) | [Capabilities](https://ai.google.dev/gemini-api/docs/models/gemini-3-pro-image-preview)

- **Gemini 2.5 Flash Image (Nano Banana)** -- Speed and efficiency. High-volume, low-latency tasks. 1024px max resolution. [Pricing](https://ai.google.dev/gemini-api/docs/pricing#gemini-2.5-flash-image) | [Capabilities](https://ai.google.dev/gemini-api/docs/models/gemini-2.5-flash-image)

### When to Use Imagen Instead

Use [Imagen](https://ai.google.dev/gemini-api/docs/imagen) (separate model via Gemini API) when:
- **Imagen 4**: Go-to for starting image generation with Imagen
- **Imagen 4 Ultra**: Advanced use-cases or best image quality (one image at a time)

---

## References

- [Cookbook guide](https://colab.research.google.com/github/google-gemini/cookbook/blob/main/quickstarts/Get_Started_Nano_Banana.ipynb)
- [Batch API for high-volume](https://ai.google.dev/gemini-api/docs/batch-api#image-generation)
- [Veo guide (video generation)](https://ai.google.dev/gemini-api/docs/video)
