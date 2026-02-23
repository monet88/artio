# PROJECT KNOWLEDGE BASE

**Project:** Artio — Cross-platform AI image generation SaaS
**Stack:** Flutter 3.10+ · Dart 3.10+ · Riverpod 2.6+ (codegen) · GoRouter 14.6+ (codegen) · Supabase · Freezed
**Branch:** master

---

## SURFACES

3 active surfaces — **confirm which surface owns behavior before editing.**

| Surface | Path | Stack | Purpose |
|---------|------|-------|---------|
| Main app | `/` | Flutter + Riverpod + GoRouter | End-user app (Android/iOS/Web/Windows) |
| Admin app | `/admin` | Flutter (web-only, own pubspec) | Template CRUD dashboard |
| Backend | `/supabase` | Deno Edge Functions + PostgreSQL | Auth, generation, credits |

---

## WHERE TO LOOK

| Task | Location |
|------|----------|
| Auth flow (login/signup/OAuth) | `lib/features/auth/` |
| Auth state + router redirect | `lib/features/auth/presentation/view_models/auth_view_model.dart` |
| Template browsing + generation | `lib/features/template_engine/` |
| Text-to-image creation | `lib/features/create/` |
| Gallery (view/download/share) | `lib/features/gallery/` |
| Credit balance + enforcement | `lib/features/credits/` + `supabase/functions/generate-image/` |
| Subscription/purchase | `lib/features/subscription/` |
| Settings (theme, account) | `lib/features/settings/` |
| Shared widgets | `lib/shared/widgets/` |
| Theme/colors | `lib/theme/` |
| Design system tokens | `lib/core/design_system/` (animations, dimensions, gradients, shadows, spacing, typography) |
| Navigation/routes | `lib/routing/app_router.dart` + `lib/routing/routes/app_routes.dart` |
| Supabase client DI | `lib/core/providers/supabase_provider.dart` |
| Error handling | `lib/core/exceptions/app_exception.dart` |
| Error message mapping | `lib/core/utils/app_exception_mapper.dart` |
| Global state (auth/credits/sub) | `lib/core/state/` |
| AI model configs + costs | `lib/core/constants/ai_models.dart` |
| App constants | `lib/core/constants/app_constants.dart` |
| Edge function (AI gen) | `supabase/functions/generate-image/index.ts` |
| Edge function shared utils | `supabase/functions/_shared/` (cors, credit_logic, model_config) |
| DB schema changes | `supabase/migrations/` (16 migrations) |
| Admin template editor | `admin/lib/features/templates/` |

---

## IMAGE GENERATION PIPELINE

Core product flow spanning Flutter + Supabase:

```
UI/ViewModel → Repository → Edge Function (generate-image) → AI provider (Kie/Gemini)
  → Storage mirror → generation_jobs update → Realtime stream (watchJob) → UI update
```

**Key files:**
- Client repo: `lib/features/template_engine/data/repositories/generation_repository.dart`
- Template VM: `lib/features/template_engine/presentation/view_models/generation_view_model.dart`
- Create VM: `lib/features/create/presentation/view_models/create_view_model.dart`
- Job orchestration: `lib/features/template_engine/presentation/helpers/generation_job_manager.dart`
- Edge function: `supabase/functions/generate-image/index.ts`

**Credit guardrails (2 layers):**
1. Client pre-check: balance stream via credits provider
2. Server-authoritative: Edge Function calls `deduct_credits` RPC → HTTP 402 + `{required}` on insufficient balance → triggers `insufficient_credits_sheet` or `premium_model_sheet`

**Generation flow detail:** DB insert (Step 1) → Edge Function call (Step 2). `retry()` wraps only Step 2 to prevent duplicate DB rows.

---

## ARCHITECTURE

Feature-first Clean Architecture. Each feature: `domain/ → data/ → presentation/`

**Dependency rule:** Presentation → Domain ← Data (never import Data directly in Presentation)

```
lib/
├── core/                          # Cross-cutting concerns
│   ├── config/                   # env_config, sentry_config
│   ├── constants/                # ai_models, app_constants, generation_constants
│   ├── design_system/            # AppAnimations, AppDimensions, AppGradients, AppShadows, AppSpacing, AppTypography
│   ├── exceptions/               # AppException sealed hierarchy
│   ├── providers/                # Supabase client DI
│   ├── services/                 # haptic, image_upload, rewarded_ad, storage_url
│   ├── state/                    # auth_view_model, credit_balance, subscription state
│   └── utils/                    # Error mapper, logger, retry, watermark
├── features/                      # 7 feature modules
│   ├── auth/                     # Email/password, Google OAuth, Apple Sign-In
│   ├── template_engine/          # CORE: template-based image generation
│   ├── create/                   # Text-to-image generation
│   ├── gallery/                  # Masonry grid, image viewer, download/share/delete
│   ├── credits/                  # Balance display, deduct/refund, 402 handling
│   ├── subscription/             # RevenueCat + Stripe purchase flows
│   └── settings/                 # Theme switcher, account management
├── routing/                       # GoRouter config + typed routes
├── shared/widgets/                # Reusable widgets (MainShell, ErrorPage, GradientButton...)
├── theme/                         # FlexColorScheme + custom tokens
└── main.dart                      # Entry: Supabase, Sentry, Ads, RevenueCat init
```

**Navigation/Auth orchestration:**
- Router: `lib/routing/app_router.dart`, routes: `lib/routing/routes/app_routes.dart`
- `AuthViewModel` implements `Listenable` — drives GoRouter refresh/redirect behavior

**Supabase Edge Functions:**
```
supabase/functions/
├── _shared/              # cors.ts, credit_logic.ts, model_config.ts
├── generate-image/       # Main generation endpoint (Kie + Gemini)
├── revenuecat-webhook/   # Subscription event handler
└── reward-ad/            # Rewarded ad credit grant
```

---

## CONVENTIONS

| Convention | Rule |
|------------|------|
| Architecture | Feature-first Clean Architecture: domain → data → presentation |
| Dependency direction | Presentation → Domain ← Data |
| State management | Riverpod with `@riverpod` code generation (never manual providers) |
| Data models | Freezed + JSON Serializable |
| Routing | GoRouter with `@TypedGoRoute` codegen |
| Linting | `very_good_analysis` (relaxed `public_member_api_docs` + `lines_longer_than_80_chars`) |
| Admin linting | `flutter_lints` |
| Generated files | Committed: `*.g.dart`, `*.freezed.dart` (excluded from analysis) |
| Freezed config | `union_key: "type"`, `union_value_case: pascal` (in `build.yaml`) |
| Error handling | Wrap in `AppException`, surface via `AsyncValue.error` |
| Error messages | Map via `AppExceptionMapper.toUserMessage()` — never expose stack traces |
| File size | Split >200 LOC by responsibility (code files only) |
| Variable precedence | `const` > `final` > `var` |
| Design tokens | Use `AppColors`, `AppGradients`, `AppSpacing`, `AppDimensions`, `AppTypography` — never hardcode |
| Naming: interfaces | `I{Name}Repository` (e.g. `IAuthRepository`) |
| Naming: screens | `{Name}Screen` in `{name}_screen.dart` |
| Naming: view models | `{Name}ViewModel` in `{name}_view_model.dart` |

---

## ANTI-PATTERNS

| Forbidden | Do Instead |
|-----------|------------|
| Hand-edit `*.g.dart` / `*.freezed.dart` | Run `dart run build_runner build --delete-conflicting-outputs` |
| Manual Riverpod providers | Use `@riverpod` annotations |
| Hardcode template IDs | Fetch from Supabase |
| Poll for job status | Use Supabase Realtime subscription |
| Skip credit policy checks | Always validate via `GenerationPolicy` |
| Mock Supabase internals in tests | Mock repository interfaces |
| `Future.delayed` for loading state in tests | Use `Completer<T>()` |
| Suppress type errors (`as any`, `@ts-ignore`) | Fix the type |
| Hardcode colors/spacing | Use design system tokens from `core/design_system/` |
| `SECURITY DEFINER` on trigger functions checking `current_user` | Returns definer role, not actual user |
| Import Data layer in Presentation | Depend on Domain interfaces only |

---

## GOTCHAS

- **Mocktail stubs**: `PostgrestBuilder`/`PostgrestFilterBuilder`/`PostgrestTransformBuilder` implement `Future<T>` — use `thenAnswer`, not `thenReturn`.
- **`AppColors.premium`** = `Color(0xFFFFA500)` (orange). `AppColors.premiumBadgeBackground` = 15% alpha orange.
- **Login screen theming**: Must use `isDark` conditional for background/gradient — supports both light and dark themes.
- **SQL security**: `authenticator` is PostgREST pool role, not admin. All credit RPCs are `SECURITY DEFINER` with execute revoked from `authenticated` — only Edge Function (via `service_role`) can call them.
- **`CreateFormState.toGenerationParams()`**: Provides defaults (modelId, outputFormat) — verify calls must match these defaults.
- **DTO leakage**: Domain entities include `fromJson`/`toJson` (accepted trade-off for MVP velocity).

---

## TESTING

**Suite:** 232+ tests passing, 0 skipped, 0 failed.

**Structure:**
```
test/
├── features/{feature}/    # Mirrors lib/features/ (unit + widget)
├── core/                  # Infrastructure tests
├── shared/                # Shared widget tests
├── routing/               # Router tests
└── integration/           # Integration checks
integration_test/          # E2E flow tests
```

**Patterns:**
- Mocking: `mocktail` (preferred) + `mockito`
- Stubs: `any(named: 'paramName')` in stubs, actual values in `verify()`, `any()` in `verifyNever()`
- When fixing behavior: run narrowest relevant test file first, then full suite

---

## CODEGEN

After changing `@riverpod`, Freezed entities, `@TypedGoRoute`, or JSON models:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Watch mode: `dart run build_runner watch`

---

## DB SCHEMA (key tables)

| Table | Purpose | Key migration |
|-------|---------|---------------|
| `profiles` | User profiles | `20260128000000` |
| `templates` | AI generation templates | `20260127000000` |
| `generation_jobs` | Generation job tracking (status, result) | `20260128115551` |
| `user_credits` | Credit balance per user (seeded 20 on signup) | `20260218000000` |
| `credit_transactions` | Credit debit/credit history | `20260218000000` |
| `ad_views` | Rewarded ad tracking | `20260218000000` |
| `pending_ad_rewards` | Pending ad reward queue | `20260220160000` |

RPCs: `deduct_credits`, `refund_credits`, `reward_ad` — all `SECURITY DEFINER`, callable only via `service_role`.

---

## DOCS

| Document | Content |
|----------|---------|
| `docs/system-architecture.md` | Architecture deep dive |
| `docs/code-standards.md` | Coding conventions (**read before implementation**) |
| `docs/project-overview-pdr.md` | Product requirements |
| `docs/codebase-summary.md` | Code analysis |
| `docs/development-roadmap.md` | Phases and progress |
| `docs/ai-models-reference.md` | AI model configs and costs |
| `docs/feature-image-input-flow.md` | Image input feature spec |

---

## NOTES

- AdMob IDs in `rewarded_ad_service.dart` are placeholders — replace before production
- No CI/CD pipeline (`.github/workflows/` absent)
- Credits enforced in 2 layers: client pre-check (balance stream) + server-authoritative (Edge Function RPC)
- Model costs in Edge Function must match `core/constants/ai_models.dart`
