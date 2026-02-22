# Core Module

Cross-cutting concerns shared across all features. DI hub for the app.

## STRUCTURE

```
core/
├── config/           # env_config, sentry_config
├── constants/        # ai_models, app_constants, generation_constants
├── design_system/    # Spacing, typography, gradients, shadows, animations, dimensions
├── exceptions/       # AppException (Freezed union type)
├── providers/        # Supabase client, connectivity (Riverpod DI)
├── services/         # haptic, image_upload, rewarded_ad
├── state/            # Global auth/credits/subscription providers
└── utils/            # Error mapper, validators, retry, watermark
```

## WHERE TO LOOK

| Task | Location |
|------|----------|
| Add Supabase table access | `providers/supabase_provider.dart` |
| New app-wide exception | `exceptions/app_exception.dart` (add Freezed union case) |
| Design token (spacing/color) | `design_system/app_spacing.dart`, `app_dimensions.dart` |
| Global reactive state | `state/` (auth, credits, subscription providers) |
| New service (app-wide) | `services/` + register via Riverpod provider |
| AI model constants | `constants/ai_models.dart` |
| Env variable access | `config/env_config.dart` |

## KEY PATTERNS

- **AppException**: Freezed union with `union_key: "type"`. All errors wrapped here before surfacing to UI.
- **Global state**: `state/` providers are user-scoped -- invalidated on logout via `user_scoped_providers.dart`.
- **Design system**: Use tokens from `design_system/` instead of raw values. Never hardcode spacing/colors.
- **Services**: Stateless, registered as Riverpod providers. No singletons.

## ANTI-PATTERNS

| Forbidden | Do Instead |
|-----------|------------|
| Raw `SupabaseClient` in features | Import from `providers/supabase_provider.dart` |
| Hardcoded spacing/colors | Use `AppSpacing`, `AppDimensions`, `AppGradients` |
| Catch-all error handling | Map to specific `AppException` variants |
| Service as singleton | Register as `@riverpod` provider |
