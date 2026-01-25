---
title: "Artio - AI Image Generation SaaS Flutter App"
description: "Cross-platform AI art generation app with subscription + credits monetization"
status: pending
priority: P1
effort: 40h
branch: main
tags: [flutter, riverpod, supabase, ai, saas, payments]
created: 2026-01-25
---

# Artio Bootstrap Plan

## Overview

**Artio** - "Art Made Simple". Cross-platform AI image generation SaaS targeting mixed audience (creators + casual users). Two generation modes: text-to-image (Create tab) and template-based image-to-image (Home tab). Hybrid monetization: subscription + credits.

## Architecture

- **Pattern**: Feature-First + MVVM
- **State**: Riverpod + riverpod_generator + Freezed
- **Backend**: Supabase (auth, db, storage, edge functions, realtime)
- **Routing**: go_router with Riverpod auth guards
- **Payments**: RevenueCat (mobile) + Stripe (web) via abstraction layer
- **AI**: Gemini API (Imagen 4) via Nano Banana
- **Analytics**: Firebase Analytics

## Phase Overview

| Phase | Title | Effort | Status |
|-------|-------|--------|--------|
| 1 | [Project Setup](./phase-01-project-setup.md) | 3h | pending |
| 2 | [Core Infrastructure](./phase-02-core-infrastructure.md) | 6h | pending |
| 3 | [Auth Feature](./phase-03-auth-feature.md) | 5h | pending |
| 4 | [Template Engine](./phase-04-template-engine.md) | 8h | completed |
| 5 | [Gallery Feature](./phase-05-gallery-feature.md) | 4h | pending |
| 6 | [Subscription & Credits](./phase-06-subscription-credits.md) | 8h | pending |
| 7 | [Settings Feature](./phase-07-settings-feature.md) | 3h | pending |
| 8 | [Admin App](./phase-08-admin-app.md) | 3h | pending |

---

## Detailed Specifications

### Branding

| Element | Value |
|---------|-------|
| Name | Artio |
| Tagline | Art Made Simple |
| Tone | Minimal, Abstract |

### Design System

| Element | Light | Dark |
|---------|-------|------|
| Background | #FFFFFF | #0D1025 |
| Primary CTA | #3DD598 (mint) | #3DD598 |
| Accent | #9B87F5 (purple) | #9B87F5 |
| Cards | White + shadow | #1E2342 |
| Corners | 12-16px | 12-16px |
| Font | Inter / SF Pro | Inter / SF Pro |

### Navigation

| Tab | Function |
|-----|----------|
| Home | Templates (image-to-image, featured + browse) |
| Create | Text-to-image with custom prompt |
| Gallery | User's generated images + pending badge |
| Settings | Account, credits, subscription, theme, legal |

### Generation Modes

#### Text-to-Image (Create Tab)
- Form + style picker UI
- Prompt field (max 1000 chars) + optional negative prompt (hidden by default)
- Style presets: 5-10 basic styles (Realistic, Anime, 3D, etc.)
- Aspect ratios: 1:1, 16:9, 9:16, 4:3, 3:4
- Quality: 1K/2K/4K
- Recent prompts history (10 items)

#### Image-to-Image (Templates)
- Single image input per template
- No adjustable parameters (image only)
- Categories: Floor Plan 3D, Remove Filter, AI Mockup, Object Remover, Sketch to Photo, etc.
- Template detail screen (full screen with back button)
- Image upload: Gallery picker + Camera capture

### Credits System

| Type | Expiry | Policy |
|------|--------|--------|
| Purchased | Never | Full ownership |
| Subscription monthly | End of period | No rollover |
| Earned (ads) | 30 days | 5 credits/day max |
| Signup bonus (web) | Never | 10 credits |

#### Credit Pricing (output quality)

| Quality | Resolution | Credits | Cost (Nano Banana) |
|---------|------------|---------|-------------------|
| 1K | 1024x1024 | 1 | $0.039 |
| 2K | 2048x2048 | 2 | $0.137 |
| 4K | 4096x4096 | 4 | $0.24 |

#### Credit Packs (purchase)

| Pack | Price | Credits | $/credit |
|------|-------|---------|----------|
| Small | $1.99 | 50 | $0.04 |
| Medium | $3.99 | 100 | $0.04 |
| Large | $6.99 | 200 | $0.035 |

#### Rewarded Ads (Mobile only)
- 1 ad = 1 credit (marketing cost, accept small loss)
- Daily limit: 5 credits/day from ads
- Web users: Signup bonus only (10 credits)

### Subscription Tiers

| Tier | Price | Monthly Credits | Benefits |
|------|-------|-----------------|----------|
| Basic | $6.99/mo | 100 | Priority queue, exclusive templates, 2K max |
| Pro | $9.99/mo | 200 | All Basic + 4K resolution |

- No rollover of monthly credits
- Credits kept until period end on cancellation
- Priority queue for subscribers over free users

### Generation Processing

- Background job via Supabase Edge Functions
- Simple spinner during wait (no progress %)
- Push notification + app badge when complete
- Tap notification → Gallery
- Auto refund on failure (API error, content policy, timeout)
- Specific error messages with failure reason

### Gallery Features

- Albums/Folders organization
- Multi-select mode for batch delete
- History: output + template used
- Simple favorites (heart icon + filter)
- Storage: Free 30 days, Paid 1 year
- Basic editing: crop, rotate, filter

### Result Actions

- Download to device
- Share to social/apps
- Save to app Gallery
- Regenerate with same settings

### Image Rights

- Full ownership, no watermark
- Commercial use allowed

### Auth & Profile

| Method | Supported |
|--------|-----------|
| Email/Password | Yes |
| Google OAuth | Yes |
| Apple OAuth | Yes (required iOS) |

- Password reset: Email OTP
- Profile fields: Email, Display name (optional), Avatar (optional)
- Onboarding: 2-3 feature slides
- Delete account: Email confirmation required

### Settings

- Theme toggle (Light/Dark/System)
- Account/Billing info (credits, subscription status)
- Privacy Policy link
- Terms of Service link
- Delete account

### Admin App (Flutter Web)

- Card grid UI for template management
- Template fields: Name, Preset prompt, Category, Sample images
- Status workflow: Draft → Published
- Auth: Email/Password login

### Platform Strategy

- Launch: Mobile first (Android + iOS)
- Web: Later phase
- Single environment (prod)
- Full CI/CD pipeline (GitHub Actions + auto deploy)
- Full test suite (unit + widget + integration)

### Tech Stack

| Layer | Tech |
|-------|------|
| Framework | Flutter >= 3.27.0 |
| State | flutter_riverpod + riverpod_generator + freezed |
| Backend | supabase_flutter |
| Routing | go_router + go_router_builder |
| Payment (Mobile) | purchases_flutter (RevenueCat) |
| Payment (Web) | Stripe |
| Theme | flex_color_scheme |
| i18n | flutter_localizations (English only at launch) |
| HTTP | dio with interceptors |
| Ads | google_mobile_ads |
| Analytics | firebase_analytics |
| Push | FCM (mobile) + Supabase Realtime (web) |

### Folder Structure

```text
lib/
├── l10n/                           # Localization files
├── core/
│   ├── router/
│   │   ├── app_router.dart         # GoRouter config + redirect
│   │   └── routes.dart             # TypedGoRoute definitions
│   ├── theme/
│   │   └── app_theme.dart          # flex_color_scheme config
│   ├── network/
│   │   └── dio_client.dart         # Dio + interceptors
│   ├── exceptions/
│   │   └── app_exceptions.dart     # Custom exceptions
│   └── constants/
│       └── app_constants.dart      # API keys, endpoints
├── shared/
│   ├── providers/                  # Global providers (auth, credits)
│   ├── widgets/                    # Reusable widgets
│   └── utils/                      # Helpers, extensions
├── features/
│   ├── auth/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── auth_user.dart
│   │   │   └── repositories/
│   │   │       └── i_auth_repository.dart
│   │   ├── data/
│   │   │   ├── data_sources/
│   │   │   │   └── auth_remote_data_source.dart
│   │   │   ├── dtos/
│   │   │   │   └── user_dto.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── auth_provider.dart
│   │       ├── pages/
│   │       │   ├── login_page.dart
│   │       │   └── onboarding_page.dart
│   │       └── widgets/
│   │           └── auth_form.dart
│   ├── template_engine/
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   ├── create/                     # Text-to-image feature
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   ├── gallery/
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   ├── subscription/
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   └── settings/
│       ├── domain/
│       ├── data/
│       └── presentation/
└── main.dart
```

### Architecture Rules

1. **Feature Encapsulation**: Logic, models, UI internal to feature directory
2. **3-Layer Separation**: Domain → Data → Presentation per feature
3. **Dependency Rule**: Presentation → Domain ← Data (Domain has zero external deps)
4. **Cross-Feature**: Features only depend on Domain layer of other features
5. **No DTO Leakage**: Never expose DTOs to UI; return Domain Entities
6. **Riverpod**: Use `@riverpod` annotations, `ref.watch()` in build, `ref.read()` in callbacks
7. **GoRouter**: Use `TypedGoRoute` + `GoRouteData`, never raw path strings

### Content Moderation

- Trust AI provider (Gemini) built-in filters
- No additional moderation layer

### Rate Limiting

- Credits only (no per-minute/daily caps beyond credits)

---

## Reports

- [Research: Riverpod + Freezed](./reports/research-riverpod-freezed.md)
- [Research: Payment Abstraction](./reports/research-payment-abstraction.md)
- [Research: Supabase Edge Functions](./reports/research-edge-functions.md)

---

## Unresolved Questions

None - interview complete.
