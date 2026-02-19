# Artio - AI Image Generation SaaS

## Purpose
Cross-platform AI image generation app (Flutter 3.10+, Dart 3.10+). Users create images via AI templates, manage gallery, auth flows.

## Tech Stack
- **Framework**: Flutter 3.10+ / Dart 3.10+
- **State Management**: Riverpod with `@riverpod` code generation
- **Navigation**: GoRouter with ShellRoute for bottom nav
- **Data Models**: Freezed with JSON serialization
- **Backend**: Supabase (Auth, PostgreSQL+RLS, Storage, Edge Functions, Realtime)
- **Error Handling**: AppException -> AppExceptionMapper
- **Env**: `.env` loaded as Flutter assets, `EnvConfig` class

## Architecture
Feature-first Clean Architecture with 3-layer pattern per feature:
```
features/{name}/
  domain/     # Entities (Freezed), Repository interfaces
  data/       # Concrete Supabase implementations
  presentation/ # @riverpod providers, screens, widgets
```
**Dependency rule**: Presentation -> Domain <- Data. Never import Data in Presentation.

## Key Directories
```
lib/
  core/          # Config, constants, design system, exceptions, providers, services, state, utils
  features/      # auth, template_engine, create, gallery, settings, credits, subscription
  routing/       # GoRouter config (app_router.dart)
  shared/        # MainShell, ErrorPage, reusable widgets
  theme/         # Theme management (colors, button themes, component themes)
  main.dart      # Entry point
```
  routing/       # GoRouter config (app_router.dart)
  shared/        # MainShell, ErrorPage
  theme/         # Theme management
  main.dart      # Entry point
```

## Feature Status
- Auth: Complete
- Template Engine: Complete
- Gallery: Complete
- Settings: Complete
- Create: Complete
- Credits: Complete
- Subscription: Complete

## Key Files
- Entry: lib/main.dart
- Router: lib/routing/app_router.dart
- Supabase provider: lib/core/providers/supabase_provider.dart
- Error mapper: lib/core/utils/app_exception_mapper.dart
- Constants: lib/core/constants/app_constants.dart
- Env config: lib/core/config/env_config.dart
- Connectivity: lib/core/providers/connectivity_provider.dart
- Haptic: lib/core/services/haptic_service.dart
- Rewarded Ads: lib/core/services/rewarded_ad_service.dart
- Design System: lib/core/design_system/ (animations, dimensions, gradients, shadows, spacing, typography)

## AI Model API Docs
Source of truth: `docs/kie-api/` (Google/Imagen, Flux-2, GPT Image, Seedream)
