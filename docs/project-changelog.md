# Project Changelog

**Project**: Artio - AI Image Generation SaaS
**Updated**: 2026-03-04
**Format**: Changelog follows [Keep a Changelog](https://keepachangelog.com/) conventions

---

## [Unreleased]

### Fixed — RevenueCat Integration Blocking Bugs (2026-03-04)
- **7 blocking bugs** resolved from red-team review of RevenueCat integration
- Fixed subscription status sync between RevenueCat webhook and Supabase
- Fixed credit grant on INITIAL_PURCHASE and RENEWAL events
- Fixed entitlement expiration handling (CANCELLATION / EXPIRATION events)
- Corrected `revenuecat_events` table logging with proper app_user_id mapping
- Fixed `grant_subscription_credits` RPC with idempotency check
- Fixed webhook signature validation with `REVENUECAT_WEBHOOK_SECRET`

### Fixed — Supabase Security Audit (2026-03-04)
- **Critical**: Added `SET search_path = public` to all `SECURITY DEFINER` functions
- **High**: Fixed overly permissive RLS policies for storage buckets — scoped to `{user_id}/` prefix
- **High**: Normalized function signatures across all database RPCs
- **Medium**: Restricted `profiles` UPDATE policy to specific columns only
- **Medium**: Revoked public schema usage from `anon` and `authenticated` roles
- **Low**: Added missing indexes for RevenueCat event queries
- 5 new migration files applied: `20260304000001` through `20260304100000`

### Fixed — Backlog Issues #48–#53 (2026-03-04)
- **#49**: Assert `TemplateModel.toJson()` emits `sort_order` key, not `order` key — prevents regression on domain model serialization
- **#51**: Add per-item try-catch in `watchTemplates()` realtime stream — matches error handling pattern in `_fetchTemplatesFromNetwork()`, prevents single malformed item from breaking entire stream
- **#52**: Strengthen `template_seed_test` with not-all-zero assertion — catches incomplete seed data scenarios where all sort_order values remain zero
- **#53**: Replace hardcoded template counts in `template_e2e_test` with flexible assertions — allows test to pass when admin adds new templates without modifying test constants
- **#48**: Create `AdminTemplateModel` unit tests (9 tests) — covers fromJson/toJson, key mapping (sort_order), defaults (isPremium, isActive, aspectRatio, inputFields)
- **#50**: Create reorder() notifier tests (5 tests) — covers upsert payload generation, empty list handling, state rollback on error

### Added — CI/CD (2026-03-03)
- Scheduled GitHub Actions cron job to keep Supabase free tier alive

### Added — Sprint 2: UX Improvements (2026-02-22)
- **Onboarding flow** — 3-slide dark gradient intro screen shown to ALL first-time users (guest or logged-in). Persisted via SharedPreferences. Slides: "Create Stunning AI Art" / "Fast & Easy" / "Free Credits to Start"
- **Guest mode** — removed forced login on app open. Users browse home/gallery/templates freely; auth required only at action points (Generate, Ads, IAP)
- **Paywall redesign** — dark gradient, glowing diamond hero, benefit chips grid, animated plan cards (Pro/Ultra), gradient CTA, Restore Purchases in header
- **Credit History screen** — transaction list with type icons, color-coded amounts (green=earn, red=spend), date formatting, empty state. Accessible via Settings → Account → Credit History
- **Settings improvements** — Legal section (Privacy Policy, ToS, Open Source Licenses), Support section (Help & FAQ, Report a Problem), Credit History tile in Account section
- **Content Moderation** — client-side prompt keyword filter before generation. Blocks inappropriate content via `ContentModerationService`
- **iOS ATT Consent** — App Tracking Transparency dialog before AdMob init (iOS only)
- **iOS PrivacyInfo.xcprivacy** — declared accessed APIs and data types for iOS 17+ App Store
- **SKAdNetwork IDs** — Google AdMob attribution IDs in `Info.plist`

### Fixed — Sprint 3: Bug Fixes (2026-02-22)
- **Google Sign-In stuck loading** — `AndroidManifest.xml` was missing `intent-filter` for `com.artio.app://` deep link scheme. OAuth browser callback couldn't return to app → `AuthState` stuck at `authenticating` forever. Fixed by adding `<data android:scheme="com.artio.app"/>` intent-filter
- **Generate button hidden by nav bar** — Samsung A53's gesture navigation bar covered the Generate button. Fixed with `MediaQuery.of(context).viewPadding.bottom` padding on `SingleChildScrollView`
- **Onboarding redirect loop** — After "Get Started", `markOnboardingDone()` saved to disk but `AuthViewModel._onboardingDone` stayed `false` in memory → infinite `/home → /onboarding` loop. Fixed by adding `completeOnboarding()` to `AuthViewModel` that updates memory flag + notifies router
- **Compile errors in providers** — Missing `flutter_riverpod` import caused `Undefined class 'Ref'` in `onboarding_provider.dart` and `credit_history_provider.dart`.  Fixed `.timeout()` call on `Refreshable` → `ref.read(provider.future).timeout()`

### Added — Image Input Flow (2026-02-22)
- `ImageUploadService` for parallel image compression + upload to Supabase Storage
- `ImageInputWidget` for gallery/camera picker with preview and remove functionality
- Image compression (max 2MB, JPEG quality 85%) before upload
- Upload progress indicator during generation
- `AiModelConfig.supportsImageInput` flag + `imageCapableModels` getter for model filtering
- 3 new Imagen 4.0 models with image input support

---

## [1.5.0] - 2026-02-20

### Added
- Exception hierarchy cleanup and standardization
- Sentry error tracking integration
- AdMob rewarded ads with server-side verification (SSV)
- Complete test coverage (712 tests: 698 main + 14 admin)

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
