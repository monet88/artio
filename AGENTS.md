# PROJECT KNOWLEDGE BASE

**Generated:** 2026-02-22
**Commit:** 2e3e19e
**Branch:** master

## OVERVIEW

Artio: cross-platform AI image generation SaaS. Flutter 3.10+ frontend (Android/iOS/Web/Windows), Supabase backend (Auth, PostgreSQL, Storage, Edge Functions), Riverpod state management, feature-first Clean Architecture.

## 3 ACTIVE SURFACES

| Surface | Path | Stack | Purpose |
|---------|------|-------|---------|
| Main app | `/` | Flutter + Riverpod + GoRouter | End-user app |
| Admin app | `/admin` | Flutter (web-only) | Template CRUD dashboard |
| Backend | `/supabase` | Deno Edge Functions + PostgreSQL | Auth, generation, credits |

**Confirm which surface owns behavior before editing.**

## STRUCTURE

```
artio/
├── lib/                        # Main app source
│   ├── core/                  # Cross-cutting (config, design system, exceptions, providers, services, state, utils)
│   ├── features/              # Feature modules (auth, create, credits, gallery, settings, subscription, template_engine)
│   │   └── {feature}/         # Each: domain/ + data/ + presentation/
│   ├── routing/               # GoRouter + typed routes
│   ├── shared/widgets/        # 16 reusable widgets (MainShell, ErrorPage, GradientButton...)
│   ├── theme/                 # FlexColorScheme + custom tokens
│   └── main.dart              # Entry: Supabase, Sentry, Ads, RevenueCat init
├── admin/                     # Separate Flutter project (own pubspec)
├── supabase/                  # Backend: migrations + edge functions
│   ├── functions/             # generate-image, revenuecat-webhook, reward-ad
│   └── migrations/            # 14 SQL migrations
├── test/                      # 232 passing tests (unit + widget + integration)
├── integration_test/          # E2E flow tests
└── docs/                      # Architecture, standards, roadmap
```

## WHERE TO LOOK

| Task | Location |
|------|----------|
| Auth flow | `lib/features/auth/` |
| Template browsing + generation | `lib/features/template_engine/` |
| Text-to-image creation | `lib/features/create/` |
| Gallery (view/download/share) | `lib/features/gallery/` |
| Credit balance + enforcement | `lib/features/credits/` + `supabase/functions/generate-image/` |
| Subscription/purchase | `lib/features/subscription/` |
| Add shared widget | `lib/shared/widgets/` |
| Theme/colors | `lib/theme/` |
| Navigation/routes | `lib/routing/app_router.dart` |
| Supabase client DI | `lib/core/providers/supabase_provider.dart` |
| Error handling | `lib/core/exceptions/app_exception.dart` |
| Design tokens | `lib/core/design_system/` |
| Global state (auth/credits/sub) | `lib/core/state/` |
| Edge function (AI gen) | `supabase/functions/generate-image/index.ts` |
| DB schema changes | `supabase/migrations/` |
| Admin template editor | `admin/lib/features/templates/` |

## IMAGE GENERATION PIPELINE

Core product flow spanning Flutter + Supabase:

1. UI/ViewModel starts generation (create or template_engine VM)
2. Repository calls Edge Function `generate-image`
3. Edge Function: selects AI provider (Kie primary, Gemini fallback), generates, mirrors to Storage
4. `generation_jobs` table updated
5. Flutter listens via Supabase Realtime (`watchJob`), updates UI

Key files: `generation_repository.dart`, `create_view_model.dart`, `generation_view_model.dart`, `generation_job_manager.dart`, `supabase/functions/generate-image/index.ts`

## CONVENTIONS

| Convention | Rule |
|------------|------|
| Architecture | Feature-first Clean Architecture: domain -> data -> presentation |
| Dependency direction | Presentation -> Domain <- Data |
| State management | Riverpod with `@riverpod` code generation |
| Data models | Freezed + JSON Serializable |
| Routing | GoRouter with typed route annotations |
| Linting | `very_good_analysis` (admin uses `flutter_lints`) |
| Generated files | Committed: `*.g.dart`, `*.freezed.dart` |
| Freezed unions | `union_key: "type"`, `union_value_case: pascal` |
| Error handling | Wrap in `AppException`, surface via `AsyncValue.error` |
| File size | Split >200 LOC by responsibility (code files only) |

## ANTI-PATTERNS

| Forbidden | Do Instead |
|-----------|------------|
| Hand-edit `*.g.dart` / `*.freezed.dart` | Run `dart run build_runner build --delete-conflicting-outputs` |
| Hardcode template IDs | Fetch from Supabase |
| Poll for job status | Use Supabase Realtime subscription |
| Skip credit policy checks | Always validate via `GenerationPolicy` |
| Mock Supabase internals in tests | Mock repository interfaces |
| `Future.delayed` for loading state in tests | Use `Completer<T>()` |
| Suppress type errors | Fix the type |

## CODEGEN

After changing `@riverpod`, Freezed entities, or typed route annotations:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## COMMANDS

```bash
# Main app
flutter pub get
flutter run                    # Default device
flutter run -d chrome          # Web
flutter run -d windows         # Windows
flutter analyze
dart format .
flutter test                   # All tests
flutter test --coverage

# Admin (from repo root)
cd admin && flutter pub get
cd admin && flutter run -d chrome
cd admin && flutter analyze

# Integration tests
flutter test integration_test/template_e2e_test.dart
flutter test --tags integration
```

## ENVIRONMENT

- `.env` loaded via `flutter_dotenv`, keys: `SUPABASE_URL`, `SUPABASE_ANON_KEY`
- Env selection: `String.fromEnvironment('ENV', defaultValue: 'development')`
- Files: `.env`, `.env.development`, `.env.staging`, `.env.test`
- Sentry initialized in `main.dart` via `sentry_config.dart`

## DOCS

| Document | Content |
|----------|---------|
| `docs/system-architecture.md` | Architecture deep dive |
| `docs/code-standards.md` | Coding conventions |
| `docs/project-overview-pdr.md` | Product requirements |
| `docs/codebase-summary.md` | Code analysis |
| `docs/development-roadmap.md` | Phases and progress |

## NOTES

- AdMob IDs in `rewarded_ad_service.dart` are placeholders -- replace before production
- No CI/CD pipeline (`.github/workflows/` absent)
- 232 tests passing, 0 skipped, 0 failed
- Credits enforced in 2 layers: client pre-check (balance stream) + server-authoritative (Edge Function RPC)
