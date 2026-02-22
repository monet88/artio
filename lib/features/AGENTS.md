# Features Directory

7 feature modules, each following Clean Architecture (domain/data/presentation).

## ADDING A NEW FEATURE

```
lib/features/{feature_name}/
├── domain/
│   ├── entities/        # Freezed models (@freezed + @JsonSerializable)
│   └── repositories/    # Abstract interfaces (I{Name}Repository)
├── data/
│   └── repositories/    # Supabase implementations
└── presentation/
    ├── providers/       # @riverpod providers
    ├── view_models/     # @riverpod class ViewModels (stateful logic)
    ├── screens/         # Full-page widgets
    └── widgets/         # Feature-specific widgets
```

## FEATURE MAP

| Feature | Domain | Has Data Layer | Key Entity |
|---------|--------|----------------|------------|
| `auth` | Login, register, OAuth, password reset | Yes | User session |
| `create` | Text-to-image prompt UI | No (uses template_engine repo) | Create parameters |
| `credits` | Balance display, insufficient credit sheets | Yes | CreditBalance |
| `gallery` | Masonry grid, viewer, download/share/delete | Yes | GalleryImage |
| `settings` | Theme switcher, account management | Yes | AppSettings |
| `subscription` | RevenueCat/Stripe purchase flows | Yes | SubscriptionPlan |
| `template_engine` | Template browsing, generation, job tracking | Yes | TemplateModel, GenerationJob |

## CONVENTIONS

| Rule | Detail |
|------|--------|
| Dependency direction | Presentation -> Domain <- Data (never reverse) |
| Repository naming | Interface: `I{Name}Repository`, Impl: `{Name}Repository` |
| Provider location | Feature-scoped in `presentation/providers/` |
| Cross-feature state | Use `lib/core/state/` (auth, credits, subscription) |
| Shared widgets | If used by 2+ features, move to `lib/shared/widgets/` |

## ANTI-PATTERNS

| Forbidden | Do Instead |
|-----------|------------|
| Feature importing another feature's data layer | Share via domain interface or core state |
| Business logic in widgets/screens | Put in view_model or domain entity |
| Feature-specific widget in `shared/` | Keep in feature's `presentation/widgets/` |
