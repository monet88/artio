# Code Standards

**Project**: Artio - AI Image Generation SaaS
**Updated**: 2026-01-28
**Version**: 1.1

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
│   ├── constants/
│   │   └── app_constants.dart         # Centralized constants
│   ├── exceptions/
│   │   └── app_exception.dart         # Sealed exception hierarchy
│   ├── providers/
│   │   └── supabase_provider.dart     # Global dependencies
│   └── utils/
│       ├── app_exception_mapper.dart  # User-friendly error messages
│       └── logger_service.dart        # Logging abstraction
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
    │   ├── gallery/                       # ✓ 3-layer structure
    │   │   ├── domain/
    │   │   ├── data/
    │   │   └── presentation/
    │   └── settings/                      # ✓ 3-layer structure
    │       ├── domain/
    │       ├── data/
    │       └── presentation/
    ├── router/
│   └── app_router.dart                # go_router configuration
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
| Providers | `{name}_provider.dart` | `auth_notifier_provider.dart` |
| Notifiers | `{name}_notifier.dart` | `auth_notifier.dart` |

### Classes

| Type | Pattern | Example |
|------|---------|---------|
| Screens | `{Name}Screen` | `LoginScreen` |
| Widgets | `{Name}Widget` or `{Name}` | `TemplateCard` |
| Models | `{Name}Model` | `UserModel` |
| Repositories (Interface) | `I{Name}Repository` | `IAuthRepository` |
| Repositories (Impl) | `{Name}Repository` | `AuthRepository` |
| Notifiers | `{Name}Notifier` | `AuthNotifier` |
| Providers | `{name}Provider` | `authNotifierProvider` |

---

## State Management (Riverpod)

### Provider Patterns

**Use `@riverpod` annotations (riverpod_generator), never manual providers:**

```dart
// ✓ CORRECT: Generated provider
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<AuthUser?> build() => null;

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
      ref.read(authRepositoryProvider).signInWithEmail(email, password)
    );
  }
}

// ✗ WRONG: Manual provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(...);
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

// features/auth/presentation/providers/auth_notifier_provider.dart
@riverpod
class AuthNotifier extends _$AuthNotifier {
  // Access via ref.read(authRepositoryProvider)
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
- Future refactor: Split to `UserEntity` (Domain) + `UserDto` (Data) + mapper
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
class ValidationException extends AppException { ... }
class StorageException extends AppException { ... }
class UnknownException extends AppException { ... }
```

### Error Mapping

**Map technical errors to user-friendly messages:**

```dart
// core/utils/app_exception_mapper.dart
class AppExceptionMapper {
  static String toUserMessage(AppException exception) {
    return switch (exception) {
      AuthException(code: 'invalid_credentials') => 'Invalid email or password.',
      NetworkException(statusCode: int status) when status >= 500 =>
        'Server error. Please try again later.',
      _ => 'Something went wrong. Please try again.',
    };
  }
}

// Usage in UI
catch (e) {
  if (e is AppException) {
    showSnackbar(AppExceptionMapper.toUserMessage(e));
  }
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

### Current Implementation (Raw Strings)

```dart
// router/app_router.dart
final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const TemplateListScreen(),
    ),
    GoRoute(
      path: '/template/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return TemplateDetailScreen(templateId: id);
      },
    ),
  ],
);
```

### Known Tech Debt

**H2/H3 Tech Debt:** GoRouter uses raw string paths instead of `TypedGoRoute`.
- **Reason:** `go_router_builder` compatibility concerns
- **Future Fix:** Migrate to typed routes when stable
- **Tracking:** Separate plan required

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

## Testing (Pending)

### Current Status

- **Coverage:** ~5-10% (1 widget test)
- **Target:** 80%+ for production readiness

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

## Known Technical Debt

### Deferred Items

| Issue | Description | Priority | Future Action |
|-------|-------------|----------|---------------|
| H2, H3 | GoRouter raw strings | High | Migrate to TypedGoRoute when stable |
| Test Coverage | 5-10% vs 80% target | High | Add comprehensive test suite (6-8h) |
| DTO Leakage | Domain entities have JSON logic | Medium | Split to Entity + DTO + mapper when scaling |
| DataSource Layer | Repos call Supabase directly | Low | Add DataSource abstraction if backend swap needed |
| Placeholder Features | create/gallery/settings not 3-layer | Low | Restructure when implementing |

### Accepted Trade-offs

- **Pragmatic Architecture:** DTO in domain acceptable for MVP velocity
- **No DataSource Layer:** YAGNI until backend diversity required
- **Raw Navigation Strings:** Wait for go_router_builder stability

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
- [ ] No secrets in code
- [ ] `flutter analyze` reports 0 errors
- [ ] Tests pass (when comprehensive suite exists)

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

- **Architecture Guide:** `.claude/skills/flutter/feature-based-clean-architecture/skill.md`
- **Riverpod Patterns:** `.claude/skills/flutter/riverpod-state-management/skill.md`
- **Error Handling:** `lib/core/exceptions/app_exception.dart`
- **Constants:** `lib/core/constants/app_constants.dart`
- **Phase 4.6 Plan:** `plans/260125-1516-phase46-architecture-hardening/plan.md`
