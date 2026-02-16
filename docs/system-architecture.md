# System Architecture

**Project**: Artio - AI Image Generation SaaS
**Updated**: 2026-02-16
**Version**: 1.3

---

## High-Level Overview

Artio is a cross-platform (Android, iOS, Web, Windows) AI image generation SaaS with dual generation modes:
- **Template Engine** (Home tab): Image-to-image with curated templates (Portrait, Art Style, Editing, etc.)
- **Text-to-Image** (Create tab): Custom prompt generation (UI and flow wiring present; backend coverage still in progress)

### Technology Stack

```
┌─────────────────────────────────────────────────────┐
│                   Flutter App                       │
│  (Android, iOS, Web, Windows - Single Codebase)     │
│  • Riverpod State Management                        │
│  • GoRouter Navigation                              │
│  • Freezed + JSON Serializable                      │
└─────────────────────────────────────────────────────┘
                        ↓↑
┌─────────────────────────────────────────────────────┐
│               Supabase Backend                      │
│  • PostgreSQL (templates, jobs, profiles)           │
│  • Auth (email/password, Google, Apple OAuth)       │
│  • Storage (user uploads, generated images)         │
│  • Realtime (job progress updates)                  │
│  • Edge Functions (KIE API integration)             │
└─────────────────────────────────────────────────────┘
                        ↓↑
┌─────────────────────────────────────────────────────┐
│           Kie API (Primary AI Provider)             │
│  • Google Imagen 4 & Nano Banana                    │
│  • Flux-2 (Flex & Pro variants)                     │
│  • GPT Image 1.5                                    │
│  • Seedream 4.5                                     │
└─────────────────────────────────────────────────────┘
                        ↓↑
┌─────────────────────────────────────────────────────┐
│         Gemini API (Fallback AI Provider)           │
│  • Multimodal image analysis and generation         │
└─────────────────────────────────────────────────────┘

**AI Model Reference**: See `docs/kie-api/` for complete model specifications
```

---

## Application Architecture

### Feature-First Clean Architecture

```
lib/
├── core/                    # Shared infrastructure
│   ├── config/              # Environment and service configs
│   ├── constants/           # App-wide constants
│   ├── design_system/       # Design tokens (spacing, dimensions)
│   ├── exceptions/          # Exception hierarchy
│   ├── providers/           # Global dependencies (Supabase)
│   ├── state/               # User-scoped state providers
│   └── utils/               # Helpers (error mapper, logger)
├── features/                # Feature modules
│   ├── auth/                # Authentication feature
│   │   ├── domain/          # Business logic
│   │   │   ├── entities/    # User models
│   │   │   └── repositories/# IAuthRepository interface
│   │   ├── data/            # Data access
│   │   │   └── repositories/# AuthRepository impl
│   │   └── presentation/    # UI layer
│   │       ├── providers/   # Auth state (Riverpod)
│   │       ├── screens/     # Login/Signup screens
│   │       └── widgets/     # Auth-specific widgets
│   └── template_engine/     # Image generation feature
│       ├── domain/          # Business logic
│       │   ├── entities/    # Template, GenerationJob models
│       │   └── repositories/# ITemplateRepository, IGenerationRepository
│       ├── data/            # Data access
│       │   └── repositories/# Supabase implementations
│       └── presentation/    # UI layer
│           ├── providers/   # Template, generation state
│           ├── screens/     # List, detail, progress screens
│           └── widgets/     # Template card, input builder
├── routing/                 # Navigation configuration
│   ├── app_router.dart      # GoRouter setup with auth guards
│   └── routes/
│       └── app_routes.dart  # TypedGoRoute definitions
├── theme/                   # Material theme
│   └── app_theme.dart       # Light/dark theme definitions
└── main.dart                # App entry point
```

### Dependency Flow (Clean Architecture)

```
┌─────────────────────┐
│   Presentation      │  • Screens, Widgets, Providers
│   (UI Layer)        │  • Depends on Domain (interfaces)
└─────────────────────┘
          ↓
┌─────────────────────┐
│      Domain         │  • Entities (models)
│  (Business Logic)   │  • Repository interfaces
│                     │  • Pure Dart (no framework deps)
└─────────────────────┘
          ↑
┌─────────────────────┐
│       Data          │  • Repository implementations
│  (Data Access)      │  • API clients (Supabase)
│                     │  • Depends on Domain (implements interfaces)
└─────────────────────┘
```

**Key Rules:**
- Presentation calls Domain interfaces (never Data directly)
- Data implements Domain interfaces
- Domain has no external dependencies

---

## State Management (Riverpod)

### Provider Hierarchy

```dart
// Global Dependencies
supabaseProvider           → SupabaseClient (singleton)

// Auth Feature
authRepositoryProvider     → IAuthRepository (DI from Supabase)
authNotifierProvider       → AuthNotifier (manages auth state)

// Template Engine Feature
templateRepositoryProvider → ITemplateRepository
generationRepositoryProvider → IGenerationRepository
templateListProvider       → AsyncValue<List<TemplateModel>>
generationJobProvider(id)  → Stream<GenerationJobModel>
```

### State Flow Example (Sign In)

```
User taps "Sign In"
      ↓
LoginScreen calls ref.read(authNotifierProvider.notifier).signIn(...)
      ↓
AuthNotifier updates state to AsyncLoading
      ↓
AuthNotifier calls ref.read(authRepositoryProvider).signInWithEmail(...)
      ↓
AuthRepository calls Supabase.auth.signInWithPassword(...)
      ↓
On success: AuthNotifier updates state to AsyncData(UserModel)
On error: AuthNotifier updates state to AsyncError(AppException)
      ↓
LoginScreen rebuilds via ref.watch(authNotifierProvider)
      ↓
UI shows success (navigate) or error (snackbar)
```

---

## Data Models

### Freezed Pattern

**All domain entities use Freezed for immutability + JSON serialization:**

```dart
@freezed
class TemplateModel with _$TemplateModel {
  const factory TemplateModel({
    required String id,
    required String name,
    required String category,
    @JsonKey(name: 'thumbnail_url') required String thumbnailUrl,
    @JsonKey(name: 'input_fields') required List<InputField> inputFields,
    @JsonKey(name: 'prompt_template') String? promptTemplate,
    @JsonKey(name: 'default_aspect_ratio') String? defaultAspectRatio,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    int? order,
    String? description,
  }) = _TemplateModel;

  factory TemplateModel.fromJson(Map<String, dynamic> json) =>
      _$TemplateModelFromJson(json);
}
```

**Key Models:**

| Model | Purpose | Location |
|-------|---------|----------|
| `UserModel` | Auth user + profile | `features/auth/domain/entities/` |
| `TemplateModel` | Template metadata | `features/template_engine/domain/entities/` |
| `GenerationJobModel` | Job status tracking | `features/template_engine/domain/entities/` |
| `InputField` | Dynamic form field config | `features/template_engine/domain/entities/` |

---

## Database Schema (Supabase)

### Tables

```sql
-- User profiles (linked to auth.users)
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  display_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Templates
CREATE TABLE templates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  description TEXT,
  thumbnail_url TEXT NOT NULL,
  input_fields JSONB NOT NULL,  -- Array of InputField specs
  prompt_template TEXT,
  default_aspect_ratio TEXT,
  is_active BOOLEAN DEFAULT true,
  "order" INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Generation jobs
CREATE TABLE generation_jobs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  template_id UUID REFERENCES templates(id) ON DELETE SET NULL,
  status TEXT NOT NULL CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
  input_data JSONB NOT NULL,     -- User-provided values for input_fields
  provider_used TEXT,            -- AI provider (kie, gemini)
  result_urls TEXT[],            -- Array of generated image URLs
  error_message TEXT,
  deleted_at TIMESTAMPTZ,        -- Soft delete timestamp
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_jobs_user_id ON generation_jobs(user_id);
CREATE INDEX idx_jobs_status ON generation_jobs(status);
```

### Row Level Security (RLS)

```sql
-- Profiles: Users can read all, update own
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Profiles are viewable by everyone"
  ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE USING (auth.uid() = id);

-- Templates: Read-only for users, admin writes via separate policy
ALTER TABLE templates ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Templates are viewable by everyone"
  ON templates FOR SELECT USING (true);

-- Generation jobs: Users can CRUD own jobs
ALTER TABLE generation_jobs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own jobs"
  ON generation_jobs FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own jobs"
  ON generation_jobs FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own jobs"
  ON generation_jobs FOR UPDATE USING (auth.uid() = user_id);
```

---

## Storage Buckets (Supabase)

```
user_uploads/             # User-uploaded input images
  {user_id}/
    {job_id}/
      input.jpg

generated-images/         # AI-generated outputs (note: hyphen, not underscore)
  {user_id}/
    {job_id}/
      output.png
```

**RLS Policies:**
- `user_uploads`: Users can upload/read own files
- `generated-images`: Users can read own files, Edge Function writes

---

## Authentication Flow

### Email/Password

```
User submits email/password
      ↓
AuthRepository.signInWithEmail()
      ↓
Supabase.auth.signInWithPassword()
      ↓
On success:
  - Supabase returns User + Session
  - AuthRepository fetches/creates profile from profiles table
  - Returns UserModel (merged user + profile data)
      ↓
AuthNotifier updates state → AsyncData(UserModel)
      ↓
Router redirects to Home (auth guard detects session)
```

### OAuth (Google/Apple)

```
User taps "Sign in with Google"
      ↓
AuthRepository.signInWithGoogle()
      ↓
Supabase.auth.signInWithOAuth(provider: 'google', redirectTo: AppConstants.googleRedirectUrl)
      ↓
Opens browser → Google consent screen
      ↓
Redirects to app via deep link (com.artio.app://)
      ↓
Supabase handles callback, creates auth.users entry
      ↓
AuthRepository.onAuthStateChange() stream emits new user
      ↓
AuthNotifier fetches profile, updates state
      ↓
Router redirects to Home
```

**Deep Link Configuration:**
- iOS: `CFBundleURLSchemes` in `Info.plist`
- Android: `intent-filter` in `AndroidManifest.xml`
- Web: Browser redirect to origin domain

---

## Image Generation Flow

### Template-Based Generation

```
User selects template
      ↓
Template detail screen loads template data
      ↓
Dynamic input form renders (text, image upload, dropdown)
      ↓
User fills inputs, taps "Generate"
      ↓
Generation repository starts a job
  1. Creates generation_jobs row (status: 'pending')
  2. Uploads input images to Storage (if any)
  3. Calls Edge Function: generate_image
      ↓
Edge Function:
  1. Fetches template config
  2. Builds KIE API payload (image-to-image)
  3. Calls KIE API
  4. On response: Downloads result, uploads to Storage
  5. Updates generation_jobs (status: 'completed', result_urls)
      ↓
Realtime subscription streams job updates to UI
  - Pending → "Queued..."
  - Processing → "Generating..."
  - Completed → Shows result image
  - Failed → Shows error message (via AppExceptionMapper)
```

### Text-to-Image Generation

**Current Status**:
- Create screen UI implemented with prompt input
- Parameter selection UI implemented
- Generation flow wiring exists; backend behavior depends on Edge Function support

**Planned Flow**:
- No image upload required
- Edge Function calls Imagen 4 (or Flux-2, GPT Image, Seedream)
- Longer processing time (~30-60s)

**Notes**:
- Exact request payload fields and model selection logic need verification in Edge Function implementation.

---

## Navigation (go_router)

### Route Structure (TypedGoRoute)

```
/ (home)                      → HomeScreen (auth required)
/template/:id                 → TemplateDetailScreen (auth required)
/login                        → LoginScreen (redirect to / if authenticated)
/register                     → RegisterScreen (redirect to / if authenticated)
/forgot-password              → ForgotPasswordScreen
/gallery                      → GalleryPage (auth required)
/create                       → CreateScreen (auth required)
/settings                     → SettingsScreen (auth required)
```

**Navigation**: Uses TypedGoRoute classes in `lib/routing/routes/app_routes.dart`

### Auth Guards

```dart
redirect: (context, state) {
  final isAuthenticated = supabase.auth.currentUser != null;
  final isLoginPage = state.matchedLocation == '/login' || state.matchedLocation == '/signup';

  if (!isAuthenticated && !isLoginPage) {
    return '/login';  // Redirect unauthenticated to login
  }
  if (isAuthenticated && isLoginPage) {
    return '/';  // Redirect authenticated away from login
  }
  return null;  // No redirect
}
```

---

## Error Handling

### Exception Hierarchy

```dart
sealed class AppException {
  const AppException({required this.message, this.code, this.details});
  final String message;
  final String? code;
  final Map<String, dynamic>? details;
}

class AuthException extends AppException { ... }      // Auth failures
class NetworkException extends AppException { ... }   // HTTP errors
class ValidationException extends AppException { ... } // Input validation
class StorageException extends AppException { ... }   // File upload/download
class UnknownException extends AppException { ... }   // Unexpected errors
```

### Error Propagation

```
Data Layer (Repository)
      ↓ throws AppException
Domain Layer (use case)
      ↓ throws AppException (or wraps)
Presentation Layer (Notifier)
      ↓ catches, sets state to AsyncError(exception)
UI (Screen/Widget)
      ↓ ref.watch() → AsyncError case
      ↓ Shows user-friendly message via AppExceptionMapper
```

**User-Facing Messages:**
```dart
AppExceptionMapper.toUserMessage(exception) →
  AuthException('invalid_credentials') → "Invalid email or password."
  NetworkException(statusCode: 500) → "Server error. Please try again later."
  StorageException() → "Failed to upload image. Check your connection."
```

---

## Theming

### Material Theme Setup

```dart
MaterialApp.router(
  theme: AppTheme.lightTheme,       // Light mode
  darkTheme: AppTheme.darkTheme,    // Dark mode
  themeMode: ThemeMode.system,      // Follow system preference
  // ...
)
```

**Theme Switching:**
- Stored in persistent preferences (implementation needs verification)
- Managed by `themeProvider` (Riverpod)
- Updates `MaterialApp.themeMode` reactively

---

## Edge Functions (Supabase)

### generate_image Function

**Trigger:** HTTP POST from Flutter app

**Input:**
```json
{
  "job_id": "uuid",
  "template_id": "uuid",
  "input_data": {
    "prompt": "a red car",
    "style": "photorealistic",
    "image_url": "https://storage.supabase.co/..."
  }
}
```

**Flow:**
1. Authenticate request (verify JWT)
2. Fetch template config from `templates` table (template flows)
3. Build KIE API request (model varies by mode)
4. Call KIE API
5. Download result image
6. Upload to `generated-images` Storage bucket
7. Update `generation_jobs` table (status: 'completed', result_urls)

**Output (example shape):**
```json
{
  "job_id": "uuid",
  "status": "completed",
  "result_urls": ["https://storage.supabase.co/.../output.png"]
}
```

**Error Handling:**
- KIE API failures → Update job status to 'failed', set error_message
- Retry logic for transient errors
- Rate limit handling (exponential backoff)

---

## Realtime Updates

### Job Status Streaming

```dart
// Repository
Stream<GenerationJobModel> watchJob(String jobId) {
  return supabase
    .from('generation_jobs')
    .stream(primaryKey: ['id'])
    .eq('id', jobId)
    .map((rows) => GenerationJobModel.fromJson(rows.first));
}

// Provider
@riverpod
Stream<GenerationJobModel> generationJob(GenerationJobRef ref, String jobId) {
  return ref.watch(generationRepositoryProvider).watchJob(jobId);
}

// UI
ref.listen(generationJobProvider(jobId), (prev, next) {
  next.when(
    data: (job) {
      if (job.status == 'completed') {
        showSnackbar('Image ready!');
        context.go('/gallery');
      }
    },
    error: (err, stack) => showSnackbar('Generation failed'),
  );
});
```

---

## Security Considerations

### Secrets Management

- **Supabase URL/Anon Key:** Public (safe, enforced by RLS)
- **Kie API Key:** Server-side only (Edge Function env vars)
- **Gemini API Key:** Server-side only (Edge Function env vars)
- **OAuth Credentials:** Native app config (iOS/Android)
- **No secrets in code:** All config via Supabase dashboard or `.env` (excluded from git)

### RLS Enforcement

- All tables have RLS enabled
- Users can only access own data (jobs, profiles)
- Templates are read-only for users
- Admin writes via service role key (not exposed to client)

### Input Validation

- Client-side: Flutter form validators
- Server-side: Edge Function validates input_data against template schema
- SQL injection: PostgreSQL prepared statements (Supabase client handles)

---

## Deployment

### Flutter App

**Platforms:**
- iOS: Xcode build → App Store Connect → TestFlight/Production
- Android: Gradle build → Google Play Console → Internal/Production
- Web: `flutter build web` → Firebase Hosting / Vercel
- Windows: `flutter build windows` → Desktop installer (development/testing)

**Environment Config:**
- Dev: `.env.dev` via `EnvConfig` (staging Supabase project)
- Prod: `.env` via `EnvConfig` (production Supabase project)

### Supabase Backend

**Infrastructure:**
- PostgreSQL: Managed by Supabase (auto-scaling)
- Storage: S3-compatible (CDN cached)
- Edge Functions: Deno runtime (auto-deploy on push)

**CI/CD:**
- GitHub Actions → Supabase CLI → Deploy Edge Functions
- Database migrations: Supabase CLI (`supabase db push`)

---

## Performance Optimization

### Image Loading

- `cached_network_image` for thumbnails (in-memory + disk cache)
- Progressive loading (low-res placeholder → full-res)
- Lazy loading in gallery (pagination)

### State Management

- Riverpod auto-dispose for unused providers
- `family` modifiers for parameterized providers (e.g., `templateProvider(id)`)
- `keepAlive()` for persistent providers (auth state)

### Database Queries

- Indexed columns: `user_id`, `status` on `generation_jobs`
- RLS policies use indexed columns for performance
- Pagination: `limit` + `offset` for gallery

---

## Monitoring (Planned)

### Metrics to Track

- Generation success rate (completed / total jobs)
- Average generation time (processing → completed)
- Error rate by exception type
- User retention (DAU/MAU)

### Tools (not all verified in code)

- Sentry: Error tracking (client + Edge Functions)
- Supabase Analytics: Database query performance
- Firebase Analytics: User behavior (mobile)
- PostHog: Product analytics (web)

---

## Scalability Considerations

### Current Limits (MVP)

- Supabase free tier: needs verification against current plan
- Kie API: rate limits TBD
- Gemini API: rate limits per project tier
- Edge Functions: invocations/month depends on plan tier

### Future Scaling

- **Database:** Upgrade Supabase plan, add read replicas
- **Storage:** CDN in front of Storage (Cloudflare)
- **Generation Queue:** Redis queue for job processing (prevent Edge Function timeouts)
- **Caching:** Redis for template metadata, user profiles

---

## References

- **Architecture Skill:** `.claude/skills/flutter/feature-based-clean-architecture/skill.md`
- **Riverpod Patterns:** `.claude/skills/flutter/riverpod-state-management/skill.md`
- **Database Schema:** `supabase/migrations/` (future)
- **API Documentation:** `docs/kie-api-llms.txt`
- **Phase 4 Plan:** `plans/260125-0120-artio-bootstrap/phase-04-template-engine.md`
- **Phase 4.6 Plan:** `plans/260125-1516-phase46-architecture-hardening/plan.md`

---

**AI Model Documentation**: `docs/kie-api/` (source of truth for model specs, parameters, Edge Function integration)

**Last Updated**: 2026-02-10
