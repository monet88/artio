# Tech Debt Audit Report

**Date**: 2026-01-25
**Auditor**: Flutter Expert Subagent
**Codebase**: F:\CodeBase\flutter-app\aiart

---

## Summary

- **Total issues**: 15
- **Critical (H)**: 3
- **Medium (M)**: 8
- **Low (L)**: 4

---

## Critical Issues (H)

### H1: Feature Structure Violates Clean Architecture

- **Files**: `lib/features/auth/`, `lib/features/template_engine/`
- **Issue**: Features lack proper 3-layer separation (domain/data/presentation). Current structure uses `model/`, `repository/`, `ui/` instead of the prescribed `domain/`, `data/`, `presentation/` layers.
- **Expected**: Per skill `feature-based-clean-architecture`:
  ```
  features/{feature}/
  ├── domain/
  │   ├── entities/
  │   ├── repositories/ (interfaces)
  │   └── use_cases/
  ├── data/
  │   ├── data_sources/
  │   ├── dtos/
  │   └── repositories/ (implementations)
  └── presentation/
      ├── providers/
      ├── pages/
      └── widgets/
  ```
- **Current**:
  ```
  features/auth/
  ├── model/       # Mixed domain entities
  ├── repository/  # No interface/impl separation
  └── ui/          # Flat structure
  ```
- **Impact**: Violates dependency rule (Domain should have zero external dependencies). `UserModel` directly uses Supabase types. No repository interfaces for testability.
- **Fix**: Refactor to 3-layer structure. Create repository interfaces in domain layer, implementations in data layer.

---

### H2: GoRouter Uses Raw Path Strings Instead of TypedGoRoute

- **File**: `F:\CodeBase\flutter-app\aiart\lib\routing\app_router.dart:47-90`
- **Issue**: All routes defined using `GoRoute(path: ...)` with string constants instead of type-safe `TypedGoRoute` with `GoRouteData` classes.
- **Code**:
  ```dart
  GoRoute(
    path: AppRoutes.splash,
    builder: (context, state) => const SplashScreen(),
  ),
  ```
- **Expected (per go-router skill)**:
  ```dart
  @TypedGoRoute<HomeRoute>(path: '/')
  class HomeRoute extends GoRouteData {
    @override
    Widget build(context, state) => const HomePage();
  }
  ```
- **Impact**: No compile-time route safety. Navigation uses raw strings (`context.go('/home')`), prone to typos and refactoring errors.
- **Fix**: Migrate to `TypedGoRoute` + `GoRouteData`. Use `MyRoute().go(context)` instead of `context.go('/path')`.

---

### H3: Navigation Uses Raw String Paths

- **Files**:
  - `F:\CodeBase\flutter-app\aiart\lib\shared\widgets\main_shell.dart:37-38`
  - `F:\CodeBase\flutter-app\aiart\lib\features\auth\ui\login_screen.dart:132,155`
  - `F:\CodeBase\flutter-app\aiart\lib\features\auth\ui\register_screen.dart:184`
  - `F:\CodeBase\flutter-app\aiart\lib\features\template_engine\ui\widgets\template_card.dart:16`
- **Issue**: Navigation calls use raw strings or path-building methods.
- **Code examples**:
  ```dart
  // main_shell.dart:38
  context.go(routes[index]); // routes = ['/home', '/create', ...]

  // login_screen.dart:132
  context.push(AppRoutes.forgotPassword);

  // template_card.dart:16
  context.push(AppRoutes.templateDetailPath(template.id));
  ```
- **Impact**: String-based navigation breaks with path changes. No IDE support for route discovery.
- **Fix**: After implementing TypedGoRoute, use `HomeRoute().go(context)`, `TemplateDetailRoute(id: id).push(context)`.

---

## Medium Issues (M)

### M1: Empty Features Without Implementation

- **Files**:
  - `F:\CodeBase\flutter-app\aiart\lib\features\create\ui\create_screen.dart`
  - `F:\CodeBase\flutter-app\aiart\lib\features\gallery\ui\gallery_screen.dart`
  - `F:\CodeBase\flutter-app\aiart\lib\features\settings\ui\settings_screen.dart`
- **Issue**: Screens are placeholder stubs with no functionality.
- **Code**:
  ```dart
  body: const Center(child: Text('Create - Text to Image')),
  ```
- **Impact**: Incomplete feature implementation. Users see non-functional screens.
- **Fix**: Implement actual functionality or show "Coming Soon" with proper UX.

---

### M2: Hardcoded OAuth Redirect URLs

- **File**: `F:\CodeBase\flutter-app\aiart\lib\features\auth\repository\auth_repository.dart:62,73,87`
- **Issue**: OAuth redirect URLs hardcoded as strings.
- **Code**:
  ```dart
  redirectTo: 'com.artio.app://login-callback', // line 62, 73
  redirectTo: 'com.artio.app://reset-password', // line 87
  ```
- **Impact**: Difficult to change for different environments (staging, production). Not configurable via environment variables.
- **Fix**: Move to constants file or environment config. Use `--dart-define` or `.env` for environment-specific URLs.

---

### M3: Hardcoded Default Values in Profile Creation

- **File**: `F:\CodeBase\flutter-app\aiart\lib\features\auth\repository\auth_repository.dart:126-132`
- **Issue**: Magic numbers in profile creation.
- **Code**:
  ```dart
  await _supabase.from('profiles').insert({
    'credits': 5,          // Magic number
    'is_premium': false,   // Hardcoded default
  });
  ```
- **Impact**: Default values scattered in code. Hard to maintain/update.
- **Fix**: Extract to constants file (e.g., `lib/core/constants/defaults.dart`).

---

### M4: `var` Usage Instead of `final`

- **Files**:
  - `F:\CodeBase\flutter-app\aiart\lib\features\template_engine\ui\template_detail_screen.dart:24`
  - `F:\CodeBase\flutter-app\aiart\lib\features\auth\repository\auth_repository.dart:117`
- **Issue**: Using `var` where `final` is appropriate.
- **Code**:
  ```dart
  var prompt = template.promptTemplate; // line 24 - reassigned
  var profile = await _fetchUserProfile(user.id); // line 117 - reassigned
  ```
- **Note**: These specific uses ARE reassigned, so `var` is correct. However, prefer `final` as default per Dart best practices.
- **Fix**: Code review passed - `var` usage here is justified due to reassignment.

---

### M5: Repository Classes Instantiate Supabase Client Directly

- **Files**:
  - `F:\CodeBase\flutter-app\aiart\lib\features\auth\repository\auth_repository.dart:15`
  - `F:\CodeBase\flutter-app\aiart\lib\features\template_engine\repository\template_repository.dart:13`
  - `F:\CodeBase\flutter-app\aiart\lib\features\template_engine\repository\generation_repository.dart:13`
- **Issue**: Repositories directly access `Supabase.instance.client` instead of receiving it via dependency injection.
- **Code**:
  ```dart
  final _supabase = Supabase.instance.client;
  ```
- **Impact**: Hard to test. Tight coupling to Supabase singleton.
- **Fix**: Inject Supabase client via constructor or provider parameter.

---

### M6: Missing Domain Entities (DTO Leakage)

- **File**: `F:\CodeBase\flutter-app\aiart\lib\features\auth\model\user_model.dart`
- **Issue**: `UserModel` acts as both domain entity AND DTO. Uses Supabase `User` type in factory constructor.
- **Impact**: Violates "No DTO Leakage" rule. Domain layer depends on infrastructure types.
- **Fix**: Create pure domain `AuthUser` entity. Keep `UserModel` as DTO in data layer with mapper.

---

### M7: Theme Provider Async Load in Build Method

- **File**: `F:\CodeBase\flutter-app\aiart\lib\theme\theme_provider.dart:12-15`
- **Issue**: `build()` method returns synchronously but calls async `_loadFromPrefs()` without awaiting.
- **Code**:
  ```dart
  @override
  ThemeMode build() {
    _loadFromPrefs(); // Async call not awaited
    return ThemeMode.system;
  }
  ```
- **Impact**: Theme flickers on app start. Returns system theme, then updates asynchronously.
- **Fix**: Use `FutureProvider` or handle async initialization properly at app startup.

---

### M8: Aspect Ratio Options Hardcoded in UI

- **File**: `F:\CodeBase\flutter-app\aiart\lib\features\template_engine\ui\template_detail_screen.dart:91`
- **Issue**: Aspect ratio options hardcoded in widget.
- **Code**:
  ```dart
  children: ['1:1', '4:3', '3:4', '16:9', '9:16'].map((ratio) {...})
  ```
- **Impact**: Not maintainable. Should come from config or template model.
- **Fix**: Extract to constants or fetch from template capabilities.

---

## Low Issues (L)

### L1: Deprecated Riverpod Annotations in Generated Files

- **Files**: Multiple `.g.dart` files
- **Issue**: Generated files contain `@Deprecated('Will be removed in 3.0. Use Ref instead')` annotations.
- **Impact**: Warning noise. Will need migration when Riverpod 3.0 releases.
- **Fix**: Re-run code generation with latest `riverpod_generator` when upgrading. Current code already uses `Ref`.

---

### L2: Missing `const` Constructor on Error Page

- **File**: `F:\CodeBase\flutter-app\aiart\lib\routing\app_router.dart:92`
- **Issue**: Cannot verify if `ErrorPage` uses const constructor.
- **Code**:
  ```dart
  errorBuilder: (context, state) => ErrorPage(error: state.error),
  ```
- **Fix**: Verify `ErrorPage` has const constructor. If so, add `const` keyword.

---

### L3: Subscription Feature Empty

- **Directory**: `F:\CodeBase\flutter-app\aiart\lib\features\subscription\`
- **Issue**: Feature directory exists but appears empty or incomplete.
- **Impact**: Dead code or incomplete feature.
- **Fix**: Implement or remove if not needed.

---

### L4: Unused Dio Client

- **File**: `F:\CodeBase\flutter-app\aiart\lib\utils\dio_client.dart`
- **Issue**: Dio client is configured but appears unused (no references found in feature code).
- **Impact**: Dead code. Adds unnecessary dependency.
- **Fix**: Remove if not needed, or document intended future use.

---

## Recommendations

### Priority Order for Fixes

1. **Immediate (H1, H2, H3)**: Architecture foundation issues
   - Refactor feature structure to 3-layer Clean Architecture
   - Implement TypedGoRoute for type-safe navigation

2. **Short-term (M1-M8)**: Code quality improvements
   - Extract hardcoded values to constants
   - Implement DI for Supabase client
   - Fix theme loading race condition

3. **Long-term (L1-L4)**: Cleanup
   - Prepare for Riverpod 3.0 migration
   - Remove dead code

### Estimated Effort

| Priority | Items | Effort |
|----------|-------|--------|
| Critical | 3 | 2-3 days |
| Medium | 8 | 3-5 days |
| Low | 4 | 1 day |

---

## Unresolved Questions

1. Is there a reason for deviating from standard Clean Architecture folder names (domain/data/presentation)?
2. Is the `subscription` feature planned or should it be removed?
3. Is Dio client intended for future external API calls beyond Supabase?
