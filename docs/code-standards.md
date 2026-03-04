# Code Standards

**Project**: Artio - AI Image Generation SaaS
**Updated**: 2026-03-04
**Version**: 1.5

---

## Architecture Principles

### Feature-First Clean Architecture

All features follow **3-layer clean architecture**:

```
lib/features/{feature}/
├── domain/              # Business logic layer
│   ├── entities/        # Business models (Freezed)
│   └── repositories/    # Abstract interfaces
├── data/                # Data access layer
│   ├── models/          # DTOs with JSON serialization
│   ├── repositories/    # Concrete implementations
│   └── datasources/     # API clients (future)
└── presentation/        # UI layer
    ├── providers/       # Riverpod state management
    ├── screens/         # Full-page views
    └── widgets/         # Reusable components
```

### Dependency Rule

**Presentation → Domain ← Data**

- Presentation depends on Domain (interfaces only)
- Data depends on Domain (implements interfaces)
- Domain depends on nothing (pure business logic)
- Never import Data directly in Presentation

---

## File Structure

### Current Implementation

```
lib/
├── core/
│   ├── config/
│   │   ├── env_config.dart            # Environment configuration
│   │   └── sentry_config.dart         # Sentry error tracking config
│   ├── constants/
│   │   ├── app_constants.dart         # Centralized constants
│   │   └── ai_models.dart             # AI model configurations
│   ├── design_system/
│   │   ├── app_dimensions.dart        # Design system dimensions
│   │   └── app_spacing.dart           # Spacing constants
│   ├── exceptions/
│   │   └── app_exception.dart         # Sealed exception hierarchy
│   ├── providers/
│   │   └── supabase_provider.dart     # Global dependencies
│   ├── services/
│   │   ├── haptic_service.dart        # Haptic feedback
│   │   ├── rewarded_ad_service.dart   # AdMob SSV
│   │   ├── image_upload_service.dart   # Image compression + upload
│   │   ├── content_moderation_service.dart # Prompt keyword filter
│   │   ├── connectivity_service.dart   # Network monitoring
│   │   └── revenuecat_service.dart     # RevenueCat SDK wrapper
│   ├── state/
│   │   └── user_scoped_providers.dart # User-scoped state providers
│   └── utils/
│       ├── app_exception_mapper.dart  # User-friendly error messages
│       ├── date_time_utils.dart       # DateTime utilities
│       ├── email_validator.dart       # Email validation
│       ├── retry.dart                # Retry with backoff
│       └── watermark_util.dart        # Image watermark
├── features/
│   ├── auth/                          # ✓ 3-layer structure
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── i_auth_repository.dart
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── auth_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── auth_notifier_provider.dart
│   │       ├── screens/
│   │       │   ├── login_screen.dart
│   │       │   └── signup_screen.dart
│   │       └── widgets/
│   │           └── (auth-specific widgets)
│   ├── template_engine/               # ✓ 3-layer structure
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── template_model.dart
│   │   │   │   └── generation_job_model.dart
│   │   │   └── repositories/
│   │   │       ├── i_template_repository.dart
│   │   │       └── i_generation_repository.dart
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       ├── template_repository.dart
│   │   │       └── generation_repository.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   ├── template_list_provider.dart
│   │       │   └── generation_job_provider.dart
│   │       ├── screens/
│   │       │   ├── template_list_screen.dart
│   │       │   └── template_detail_screen.dart
│   │       └── widgets/
    │   │           ├── template_card.dart
    │   │           └── input_field_builder.dart
    │   ├── create/                        # ✓ 3-layer structure
    │   │   ├── domain/
    │   │   ├── data/
    │   │   └── presentation/
    │   ├── credits/                       # ✓ 3-layer structure
    │   │   ├── domain/
    │   │   ├── data/
    │   │   └── presentation/
    │   ├── gallery/                       # ✓ 3-layer structure
    │   │   ├── domain/
    │   │   ├── data/
    │   │   └── presentation/
    │   ├── settings/                      # ✓ 3-layer structure
    │   │   ├── domain/
    │   │   ├── data/
    │   │   └── presentation/
    │   └── subscription/                  # ✓ 3-layer structure
    │       ├── domain/
    │       ├── data/
    │       └── presentation/
    ├── routing/
│   ├── app_router.dart                # go_router configuration
│   └── routes/
│       └── app_routes.dart            # TypedGoRoute definitions
├── theme/
│   └── app_theme.dart                 # Material theme definitions
└── main.dart                          # App entry point
```

---

## Naming Conventions

### Files

| Type | Pattern | Example |
|------|---------|---------|
| Screens | `{name}_screen.dart` | `login_screen.dart` |
| Widgets | `{name}_widget.dart` or `{name}.dart` | `template_card.dart` |
| Models | `{name}_model.dart` | `user_model.dart` |
| Repositories (Interface) | `i_{name}_repository.dart` | `i_auth_repository.dart` |
| Repositories (Impl) | `{name}_repository.dart` | `auth_repository.dart` |
| Providers | `{name}_provider.dart` or `{name}_view_model.dart` | `auth_view_model_provider.dart` |
| ViewModels | `{name}_view_model.dart` | `auth_view_model.dart` |

### Classes

| Type | Pattern | Example |
|------|---------|---------|
| Screens | `{Name}Screen` | `LoginScreen` |
| Widgets | `{Name}Widget` or `{Name}` | `TemplateCard` |
| Models | `{Name}Model` | `UserModel` |
| Repositories (Interface) | `I{Name}Repository` | `IAuthRepository` |
| Repositories (Impl) | `{Name}Repository` | `AuthRepository` |
| ViewModels | `{Name}ViewModel` | `AuthViewModel` |
| Providers | `{name}Provider` | `authViewModelProvider` |

---

## Import Ordering

1. Dart SDK imports (`dart:...`)
2. Package imports (`package:flutter/...`, `package:riverpod/...`)
3. Project imports (`package:artio/...`)

---

## State Management (Riverpod)

### Provider Patterns

**Use `@riverpod` annotations (riverpod_generator), never manual providers:**

```dart
// ✓ CORRECT: Generated provider with @riverpod annotation
@riverpod
class AuthViewModel extends _$AuthViewModel {
  @override
  FutureOr<AuthUser?> build() => null;

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
      ref.read(authRepositoryProvider).signInWithEmail(email, password)
    );
  }
}

// ✗ WRONG: Manual provider (don't use this pattern)
final authProvider = StateNotifierProvider<AuthViewModel, AuthState>(...);
```

### Dependency Injection

**Inject repositories via Riverpod providers:**

```dart
// core/providers/supabase_provider.dart
@riverpod
SupabaseClient supabase(SupabaseRef ref) {
  return Supabase.instance.client;
}

// features/auth/data/repositories/auth_repository.dart
@riverpod
IAuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepository(ref.watch(supabaseProvider));
}

// features/auth/presentation/providers/auth_view_model.dart (or auth_view_model_provider.dart)
@riverpod
class AuthViewModel extends _$AuthViewModel {
  @override
  FutureOr<AuthUser?> build() {
    // Initialize auth state
    return null;
  }

  // Implement methods like signIn, signUp, signOut
}
```

---

## Data Models

### Freezed + JSON Serializable

**All domain entities use Freezed for immutability:**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    String? displayName,
    String? avatarUrl,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
```

### Known Trade-off: DTO Leakage

Domain entities include `fromJson`/`toJson` (impure). Acceptable for MVP:
- Future refactor: Split to distinct Domain entity + Data DTO + mapper (names TBD)
- Current benefit: Reduced boilerplate, faster iteration

---

## Error Handling

### Exception Hierarchy

**Use sealed `AppException` class:**

```dart
sealed class AppException implements Exception {
  const AppException({required this.message, this.code, this.details});

  final String message;
  final String? code;
  final Map<String, dynamic>? details;
}

class AuthException extends AppException { ... }
class NetworkException extends AppException { ... }
class StorageException extends AppException { ... }
class PaymentException extends AppException { ... }
class GenerationException extends AppException { ... }
class UnknownException extends AppException { ... }
```

### Error Mapping

**Map technical errors to user-friendly messages:**

```dart
// core/utils/app_exception_mapper.dart
class AppExceptionMapper {
  AppExceptionMapper._(); // Private constructor, static methods only

  /// Converts an error to a user-displayable message.
  /// Handles SocketException, TimeoutException, and all AppException variants.
  static String toUserMessage(Object error) {
    if (error is SocketException) return 'No internet connection...';
    if (error is TimeoutException) return 'Request timed out...';
    if (error is! AppException) return 'An unexpected error occurred...';
    return switch (error) {
      NetworkException(statusCode: int status) when status >= 500 =>
        'Server error. Please try again later.',
      AuthException(code: 'invalid_credentials') =>
        'Invalid email or password.',
      PaymentException() => error.message,
      GenerationException() => error.message,
      _ => 'Something went wrong. Please try again.',
    };
  }
}

// Usage in UI
catch (e) {
  showSnackbar(AppExceptionMapper.toUserMessage(e));
}
```

---

## Code Quality Rules

### Linting (analysis_options.yaml)

**Enabled lints:**
```yaml
linter:
  rules:
    prefer_const_constructors: true
    prefer_const_literals_to_create_immutables: true
    avoid_redundant_argument_values: true
    prefer_final_fields: true
    prefer_final_locals: true
```

### Variable Declaration Precedence

1. `const` - Compile-time constant (prefer)
2. `final` - Runtime constant (use when `const` not possible)
3. `var` - Reassignable (only when mutation needed)

```dart
// ✓ CORRECT
const padding = EdgeInsets.all(16);
final timestamp = DateTime.now();
var counter = 0; // Justifiable if incremented

// ✗ WRONG
var padding = EdgeInsets.all(16); // Should be const
final counter = 0; // Should be var if incremented
```

### @override Annotations

**Always annotate overridden methods:**

```dart
// ✓ CORRECT
class AuthRepository implements IAuthRepository {
  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    // implementation
  }
}

// ✗ WRONG
class AuthRepository implements IAuthRepository {
  Future<UserModel> signInWithEmail(String email, String password) async {
    // Missing @override - compiler won't catch signature changes
  }
}
```

---

## Navigation (go_router)

### Current Implementation (TypedGoRoute)

**Uses TypedGoRoute with route definitions in separate file:**

```dart
// routing/routes/app_routes.dart
class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomeScreen();
}

class TemplateDetailRoute extends GoRouteData {
  final String id;
  const TemplateDetailRoute({required this.id});

  @override
  Widget build(BuildContext context, GoRouterState state) =>
    TemplateDetailScreen(templateId: id);
}

// routing/app_router.dart
final appRouter = GoRouter(
  routes: $appRoutes, // Generated from TypedGoRoute
  redirect: _authGuard,
);
```

**Navigation Usage:**
```dart
const HomeRoute().go(context);
TemplateDetailRoute(id: templateId).push(context);
```

---

## Constants Management

### Centralized Constants

**All magic values extracted to `core/constants/app_constants.dart`:**

```dart
class AppConstants {
  // OAuth
  static const String googleRedirectUrl = 'com.artio.app://';
  static const String appleRedirectUrl = 'com.artio.app://';

  // Defaults
  static const String defaultDisplayName = 'Artio User';
  static const String defaultAvatarUrl = 'https://via.placeholder.com/150';

  // Aspect Ratios
  static const Map<String, String> aspectRatios = {
    '1:1': '1024x1024',
    '16:9': '1920x1080',
    '9:16': '1080x1920',
    '4:3': '1024x768',
    '3:4': '768x1024',
  };
}
```

---

## Testing

### Current Status

- **Test files**:
  - Main app: 82 unit/widget + 5 integration files
  - Admin app: 2 unit files
- **Test count**: 712+ total
- **Analyzer**: 0 errors (both main + admin)
- **Target**: 80%+ line coverage for production readiness

### Test Coverage Areas

- Repository tests (auth, template, gallery, generation, credits, subscription)
- ViewModel/Provider tests
- Widget tests for core components
- Exception mapper tests (SocketException, TimeoutException)
- Model sync tests (exact ID + cost validation)
- Integration tests for template generation flow
- Admin template model and reorder tests

### Required Test Structure

```
test/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── auth_repository_test.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── auth_notifier_test.dart
│   │       └── screens/
│   │           └── login_screen_test.dart
│   └── template_engine/
│       └── (similar structure)
├── core/
│   └── utils/
│       └── app_exception_mapper_test.dart
└── widget_test.dart
```

### Test Patterns

```dart
// Repository unit test
void main() {
  late MockSupabaseClient mockClient;
  late IAuthRepository repository;

  setUp(() {
    mockClient = MockSupabaseClient();
    repository = AuthRepository(mockClient);
  });

  group('signInWithEmail', () {
    test('returns UserModel on success', () async {
      when(() => mockClient.auth.signInWithPassword(...))
        .thenAnswer((_) async => mockAuthResponse);

      final result = await repository.signInWithEmail('test@test.com', 'pass');

      expect(result, isA<UserModel>());
    });

    test('throws AuthException on invalid credentials', () async {
      when(() => mockClient.auth.signInWithPassword(...))
        .thenThrow(AuthException('Invalid credentials'));

      expect(
        () => repository.signInWithEmail('bad@test.com', 'bad'),
        throwsA(isA<AppException>()),
      );
    });
  });
}
```

---

## Security Standards

### No Secrets in Code

- Never commit API keys, tokens, credentials
- Use environment variables for sensitive config
- Supabase keys injected via `supabase_flutter` initialization

### OAuth Configuration

- Redirect URLs centralized in `AppConstants`
- Platform-specific URL schemes in native config
- No hardcoded URLs in business logic

### Error Message Sanitization

- Never expose stack traces to users
- Map technical errors to generic messages
- Log detailed errors for debugging (server-side)

---

## Credits & Monetization

### Frontend Surface

- `features/credits/domain/entities/credit_balance.dart` models the `user_credits.balance` row used by `CreditBalanceNotifier` (`features/credits/presentation/providers/credit_balance_provider.dart`).
- `insufficient_credits_sheet.dart` and `premium_model_sheet.dart` provide the 402 + premium model gating UI for the create flow.
- `CreateViewModel` (not listed here) now reacts to 402 responses by prompting the sheets and preventing generation until credits are replenished.

### Backend Enforcement

- The Supabase Edge Function `supabase/functions/generate-image/index.ts` deducts credits, polls Kie/Gemini, mirrors outputs to `generated-images`, and updates `generation_jobs` with completed/failure status.
- A server-side model-cost map constant in `supabase/functions/generate-image/index.ts` defines cost tiers that match `core/constants/ai_models.dart`, ensuring the same model+quality pairing is priced consistently.
- The Edge Function returns HTTP 402 + `{required}` when `deduct_credits` fails, triggering the premium/insufficient UI.

### Supabase Schema

- Migration `supabase/migrations/20260218000000_create_credit_system.sql` adds `user_credits`, `ad_views`, tighter `credit_transactions` constraints, and the `deduct_credits`/`refund_credits` RPCs.
- The `handle_new_user` trigger now seeds `user_credits` with a 20-credit welcome bonus and logs a `welcome_bonus` transaction.
- All RPCs are `SECURITY DEFINER` with execute **revoked** from `authenticated` — only the Edge Function (via `service_role` key) can call them. This prevents direct RPC manipulation from clients.

---

## Known Technical Debt

### Phase 1 Completed (Tech Debt Cleanup - 2026-02-20)

| Issue | Description | Priority | Status |
|-------|-------------|----------|--------|
| ~~Navigation Type Safety~~ | ~~Raw goRouter strings~~ | ~~Medium~~ | ✓ Resolved (TypedGoRoute) |
| ~~ImagePicker Provider~~ | ~~Unused provider in codebase~~ | ~~Low~~ | ✓ Resolved (removed) |
| ~~Model Sync Tests~~ | ~~Count-only validation~~ | ~~Medium~~ | ✓ Resolved (exact ID + cost validation) |
| ~~timingSafeEqual Type Error~~ | ~~revenuecat-webhook missing~~ | ~~Medium~~ | ✓ Resolved (added to deno check) |
| ~~Large Files~~ | ~~image_viewer_page >200 LOC~~ | ~~Medium~~ | ✓ Resolved (refactored) |
| ~~DTO Leakage~~ | ~~Domain entities have JSON logic~~ | ~~Medium~~ | ✓ Resolved (accepted for MVP) |
| ~~DataSource Layer~~ | ~~Repos call Supabase directly~~ | ~~Low~~ | ✓ Resolved (YAGNI - accepted) |

### Deferred Items

| Issue | Description | Priority | Future Action |
|-------|-------------|----------|---------------|
| Repository methods lack dartdocs | API clarity | Medium | Pending |

### Accepted Trade-offs

- **Pragmatic Architecture:** DTO in domain acceptable for MVP velocity
- **No DataSource Layer:** YAGNI until backend diversity required

---

## Code Review Checklist

Before submitting code:

- [ ] Follows 3-layer architecture (domain/data/presentation)
- [ ] Repository injection via Riverpod
- [ ] Uses `@riverpod` annotations (not manual providers)
- [ ] Models use Freezed + JSON serializable
- [ ] Errors use `AppException` hierarchy
- [ ] Error messages mapped to user-friendly strings
- [ ] All magic values extracted to `AppConstants`
- [ ] `const` used where possible
- [ ] `@override` annotations on all overridden methods
- [ ] File naming follows conventions
- [ ] File size under 200 LOC (or justified exception)
- [ ] No secrets in code
- [ ] `flutter analyze` reports 0 errors
- [ ] Tests written and passing

---

## Tools

### Code Generation

```bash
# Run after modifying Freezed/Riverpod annotations
dart run build_runner build --delete-conflicting-outputs

# Watch mode for development
dart run build_runner watch
```

### Analysis

```bash
# Check for linting errors
flutter analyze

# Run tests
flutter test

# Check package updates
flutter pub outdated
```

---

## References

- **Architecture Guide:** `AGENTS.md`
- **Error Handling:** `lib/core/exceptions/app_exception.dart`
- **Constants:** `lib/core/constants/app_constants.dart`

---

**Last Updated**: 2026-03-04
