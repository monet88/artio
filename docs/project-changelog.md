# Project Changelog

**Project**: Artio - AI Image Generation SaaS
**Updated**: 2026-02-22
**Format**: Changelog follows [Keep a Changelog](https://keepachangelog.com/) conventions

---

## [Unreleased]

### Added
- **Image Input Flow** (2026-02-22):
  - `ImageUploadService` for parallel image compression + upload to Supabase Storage
  - `ImageInputWidget` for gallery/camera picker with preview and remove functionality
  - Image compression (max 2MB, JPEG quality 85%) before upload
  - Upload progress indicator during generation
  - `AiModelConfig.supportsImageInput` flag + `imageCapableModels` getter for model filtering
  - 3 new Imagen 4.0 models with image input support:
    - `imagen-4.0-generate-fast` (fast generation)
    - `imagen-4.0-generate-standard` (standard quality)
    - `imagen-4.0-generate-ultra` (best quality)
  - Edge Function updated: `generateViaImagen()` for Imagen 4.0, image field name mapping per model
  - `uuid` package added to pubspec.yaml for unique input file naming
  - `image_count_dropdown` widget for selecting 1-3 images per template
  - `ModelSelector` bidirectional filtering for image-capable models
  - `TemplateDetailScreen` wired with image state, upload-before-generate flow
  - Generation pipeline: `imageInputs`, `modelId`, `outputFormat` parameters passed through all layers

### Changed
- **Edge Function (`generate-image/index.ts`)**:
  - Now accepts `imageInputs` parameter (array of Storage paths)
  - Resolves paths to signed URLs (60-min expiry)
  - Maps image field names per model family (e.g., `input_urls`, `image_urls`, `image_input`)
  - Added `generateViaImagen()` for Imagen 4.0 models (separate `:predict` endpoint)
  - Updated model selection logic to support image-capable variants
  - Better error handling for image resolution failures

- **AiModelConfig**:
  - Added `supportsImageInput: bool` field (default: false)
  - Added `imageCapableModels` getter to filter models supporting image input
  - Existing models: `nano-banana-edit`, `nano-banana-pro`, `flux-2` variants, `gpt-image` variants, `seedream` edit models, `gemini-*` models updated with correct flags

- **Storage Organization**:
  - User uploads now stored in `generated-images/{userId}/inputs/{uuid}.jpg`
  - AI outputs stored at `generated-images/{userId}/{jobId}.jpg` (unchanged)
  - Consolidated to single bucket with subdirectories (previously planned dual-bucket)

- **Supabase Config**:
  - `verify_jwt = false` in `config.toml` (gateway-level HS256 verification handles auth)
  - Edge Function validates JWT via `supabase.auth.getUser(token)` internally

### Fixed
- Model selection now correctly filters based on image input capability
- Edge Function properly handles both text-to-image and image-to-image workflows

### Deprecated
- Nothing in this release

### Removed
- Nothing in this release

---

## [1.5.0] - 2026-02-20

### Added
- Exception hierarchy cleanup and standardization
- Sentry error tracking integration
- AdMob rewarded ads with server-side verification (SSV)
- Complete test coverage (651+ unit tests, 15 integration tests)

### Changed
- Tech debt cleanup and edge-case remediation
- Init resilience improvements

### Fixed
- Auth redirect flow on protected routes
- Force unauthenticated users to login page

---

## [1.4.0] - 2026-02-15

### Added
- Credits system (user_credits, credit_transactions tables)
- Credits display in UI
- Server-authoritative credit deduction via Edge Function
- Generation preview (pending animations)

### Changed
- Generation pipeline now deducts credits before calling AI providers
- Updated Edge Function to handle insufficient balance (402 response)

### Fixed
- Job status tracking accuracy
- Realtime subscription reliability

---

## [1.3.0] - 2026-02-08

### Added
- Text-to-Image creation flow (Create tab)
- Dynamic model selection UI
- Parameter selection (aspect ratio, output format)
- Integration with Kie API via Edge Function

### Changed
- Unified Edge Function for both template and create flows
- Consolidated image generation pipeline

---

## [1.2.0] - 2026-02-01

### Added
- Subscription system (RevenueCat integration)
- Premium tier support
- Subscription status in user profile

### Changed
- Model pricing tiers (free vs premium)
- Generation limits based on subscription status

---

## [1.1.0] - 2026-01-25

### Added
- Template Engine feature (core product)
- 25 curated templates across 5 categories
- Template browsing with category filters
- Dynamic input field rendering (text, dropdown, image)
- Template detail screen
- Generation job creation and tracking
- Realtime job status updates via Supabase Realtime
- Gallery display of generated images

### Changed
- Architecture refined to feature-first clean architecture
- All 7 features now follow 3-layer pattern

---

## [1.0.0] - 2026-01-15

### Added
- Initial Flutter app scaffold
- Authentication system (email/password, OAuth)
- User profile management
- Supabase backend integration
- GoRouter navigation with auth guards
- Design system and theming (light/dark modes)
- Settings screen
- Gallery feature (basic)

### Changed
- Established clean architecture foundation
- Implemented Riverpod state management pattern

---

## References

- **System Architecture**: `docs/system-architecture.md`
- **Development Roadmap**: `docs/development-roadmap.md`
- **Image Input Flow**: `docs/feature-image-input-flow.md`
