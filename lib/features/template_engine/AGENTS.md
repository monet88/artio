# Template Engine Feature

Core AI image generation feature. Handles template browsing, input collection, job submission, and progress tracking.

## Structure

```
template_engine/
├── domain/
│   ├── entities/          # 9 Freezed models (template, input_field, generation_job, etc.)
│   ├── repositories/      # ITemplateRepository, IGenerationRepository
│   └── policies/          # GenerationPolicy (rate limits, credits)
├── data/
│   └── repositories/      # Supabase implementations
└── presentation/
    ├── providers/         # @riverpod providers for templates, jobs
    ├── screens/           # HomeScreen, TemplateDetailScreen
    ├── widgets/           # TemplateCard, InputFieldBuilder
    └── view_models/       # Form state management
```

## Where to Look

| Task | Location |
|------|----------|
| Add new input type | `domain/entities/input_field_model.dart` + `presentation/widgets/input_field_builder.dart` |
| Modify generation flow | `data/repositories/generation_repository.dart` |
| Change rate limits | `domain/policies/generation_policy.dart` |
| Template list UI | `presentation/screens/home_screen.dart` |
| Generation progress | `presentation/providers/generation_job_provider.dart` |

## Key Entities

| Entity | Purpose |
|--------|---------|
| `TemplateModel` | AI template definition (prompts, inputs, preview) |
| `InputFieldModel` | Dynamic form field (text, number, dropdown, image) |
| `GenerationJobModel` | Job status tracking (pending, processing, completed, failed) |
| `GenerationPolicy` | Credits, rate limits, cooldowns |

## Conventions

- **Input types**: Extend `InputFieldType` enum for new field types
- **Job status**: Use Supabase Realtime for live updates
- **Error handling**: Wrap in `AppException`, surface via `AsyncValue.error`

## Anti-Patterns

| Forbidden | Do Instead |
|-----------|------------|
| Hardcode template IDs | Fetch from Supabase |
| Poll for job status | Use Realtime subscription |
| Skip policy checks | Always validate via `GenerationPolicy` |
