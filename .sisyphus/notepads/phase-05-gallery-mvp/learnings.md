# Gallery MVP Learnings

## 2026-01-28 Initial Analysis

### Architecture Patterns (from auth & template_engine)
- **3-layer architecture**: `domain/` -> `data/` -> `presentation/`
- **Domain layer**: entities (freezed models), repository interfaces (abstract classes)
- **Data layer**: repository implementations with `@riverpod` annotation, inject SupabaseClient via constructor
- **Presentation layer**: view_models/providers, screens, widgets

### Key Observations
- `cached_network_image` already installed in pubspec.yaml
- Gallery feature exists but only has placeholder `ui/gallery_screen.dart`
- GenerationJobModel has `resultUrls` field containing generated image URLs
- Router uses `AppRoutes` constants + ShellRoute for main tabs
- share_plus NOT installed - need to add

### Reference Files
- Entity pattern: `lib/features/template_engine/domain/entities/generation_job_model.dart`
- Repository pattern: `lib/features/template_engine/data/repositories/generation_repository.dart`
- Interface pattern: `lib/features/auth/domain/repositories/i_auth_repository.dart`
- Router: `lib/routing/app_router.dart`

### Database Schema (from generation_repository.dart)
- Table: `generation_jobs`
- Key fields: id, user_id, template_id, prompt, status, result_urls, created_at
- RLS enabled (user can only see own jobs)

### Design Decisions
- Reuse GenerationJobModel from template_engine (contains all gallery item data)
- Gallery items = completed generation_jobs with result_urls
- Each job can have multiple images (result_urls is List<String>)
